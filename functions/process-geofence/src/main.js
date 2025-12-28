import { Client, TablesDB, Messaging, ID, Query } from 'node-appwrite';

/**
 * Process Geofence - Appwrite Function
 * 
 * Trigger: Event - `databases.godropme_db.tables.trips.rows.*.update` (Tables DB)
 * 
 * Purpose: Check driver proximity to target and send GEOFENCE-BASED notifications only.
 * This function handles LOCATION-based (distance) events, NOT status change events.
 * 
 * Geofence Radii:
 * - 500m: "Driver is approaching" notification (driver_arrived type with 'approaching' event)
 * - 100m: "Driver has arrived" notification (driver_arrived type with 'arrived' event)
 * 
 * Creates geofence_events for analytics and prevents duplicate notifications using flags:
 * - approachingNotified: set when 500m notification sent
 * - arrivedNotified: set when 100m notification sent
 * 
 * NOTE: For Tables DB, the row data is NOT sent in req.body. We must extract 
 * the row ID from the event string and fetch the row data from the database.
 * 
 * NOTE: Status-based notifications (trip_started, child_picked, child_dropped) 
 * are handled by the notify-trip-status function, NOT this one.
 * 
 * IMPORTANT: geofence_events.eventType enum values:
 * ['approaching_pickup', 'arrived_pickup', 'approaching_drop', 'arrived_drop', 'left_geofence']
 * 
 * IMPORTANT: notifications.type enum values:
 * ['trip_started', 'driver_arrived', 'child_picked', 'child_dropped', 'request_received', 
 *  'request_accepted', 'request_rejected', 'new_message', 'system']
 */

/**
 * Extract row/document ID from event string
 * Supports BOTH:
 * - Tables DB format: databases.{dbId}.tables.{tableId}.rows.{rowId}.{action}
 * - Collections format: databases.{dbId}.collections.{collId}.documents.{docId}.{action}
 * @param {string} event - The event string
 * @returns {string|null} - The row/document ID or null if not found
 */
function extractRowIdFromEvent(event) {
    // Try Tables DB format first: rows.{rowId}.update
    let match = event.match(/rows\.([^.]+)\.(update|create|delete)/);
    if (match) return match[1];
    
    // Try Collections format: documents.{docId}.update
    match = event.match(/documents\.([^.]+)\.(update|create|delete)/);
    return match ? match[1] : null;
}

export default async ({ req, res, log, error }) => {
    log('='.repeat(60));
    log('[process-geofence] Function started');
    log(`[DEBUG] Execution time: ${new Date().toISOString()}`);
    
    // Initialize Appwrite client
    const client = new Client()
        .setEndpoint(process.env.APPWRITE_ENDPOINT || 'https://fra.cloud.appwrite.io/v1')
        .setProject(process.env.APPWRITE_FUNCTION_PROJECT_ID)
        .setKey(process.env.APPWRITE_API_KEY);

    const tablesDB = new TablesDB(client);
    const messaging = new Messaging(client);
    const databaseId = 'godropme_db';
    
    log(`[DEBUG] Database ID: ${databaseId}`);
    log(`[DEBUG] Project ID: ${process.env.APPWRITE_FUNCTION_PROJECT_ID}`);

    try {
        // Parse the event from request headers
        const event = req.headers['x-appwrite-event'] || '';
        log(`[DEBUG] Event: ${event}`);

        // Only process trip update events (supports both Tables DB and Collections formats)
        const isTablesDBEvent = event.includes('tables.trips.rows') && event.includes('.update');
        const isCollectionsEvent = event.includes('collections.trips.documents') && event.includes('.update');
        
        if (!isTablesDBEvent && !isCollectionsEvent) {
            log('[INFO] Not a trips update event, exiting');
            return res.json({ skipped: true, reason: 'Not a trips update event' });
        }
        log(`[DEBUG] Event format: ${isTablesDBEvent ? 'TablesDB' : 'Collections'}`);

        // Extract row ID from event (Tables DB doesn't send body data)
        const tripId = extractRowIdFromEvent(event);
        if (!tripId) {
            log('[ERROR] Could not extract trip ID from event');
            return res.json({ skipped: true, reason: 'Could not extract trip ID from event' });
        }
        log(`[DEBUG] Extracted Trip ID: ${tripId}`);

        // Fetch the trip data from database (Tables DB uses getRow)
        let trip;
        try {
            trip = await tablesDB.getRow({
                databaseId: databaseId,
                tableId: 'trips',
                rowId: tripId
            });
            log(`[DEBUG] Trip fetched successfully`);
        } catch (e) {
            log(`[ERROR] Could not fetch trip: ${e.message}`);
            return res.json({ skipped: true, reason: `Could not fetch trip: ${e.message}` });
        }

        log(`[INFO] Processing geofence for trip ${trip.$id}`);
        log(`[DEBUG] Trip status: ${trip.status}`);
        log(`[DEBUG] Trip type: ${trip.tripType}, direction: ${trip.tripDirection}`);
        log(`[DEBUG] Parent Row ID: ${trip.parentId}`);

        // IMPORTANT: trip.parentId is the row ID in parents table, not the users table ID
        // We need to fetch the actual userId for notifications/FCM
        let parentUserId = null;
        try {
            const parent = await tablesDB.getRow({
                databaseId: databaseId,
                tableId: 'parents',
                rowId: trip.parentId
            });
            parentUserId = parent.userId;
            log(`[DEBUG] Parent user ID: ${parentUserId}`);
        } catch (e) {
            log(`[WARN] Could not fetch parent: ${e.message}`);
        }

        // Only process if trip is in active status (has driver moving)
        const activeStatuses = ['driver_enroute', 'arrived', 'picked', 'in_transit'];
        if (!activeStatuses.includes(trip.status)) {
            log(`[INFO] Trip status ${trip.status} is not active, skipping`);
            return res.json({ skipped: true, reason: `Status ${trip.status} not active` });
        }

        // Check if driver location is available
        const driverLocation = trip.currentDriverLocation;
        log(`[DEBUG] Driver location: ${JSON.stringify(driverLocation)}`);
        
        if (!driverLocation || driverLocation.length < 2) {
            log('[WARN] No driver location available');
            return res.json({ skipped: true, reason: 'No driver location' });
        }

        // Determine target location based on trip status
        // driver_enroute/arrived = going to pickup
        // picked/in_transit = going to drop
        let targetLocation;
        let isGoingToPickup;
        let locationDescription;

        if (trip.status === 'driver_enroute' || trip.status === 'arrived') {
            // Going to pickup location
            targetLocation = trip.pickupLocation;
            isGoingToPickup = true;
            locationDescription = trip.tripDirection === 'home_to_school' ? 'home (pickup)' : 'school (pickup)';
        } else {
            // Picked or in_transit - going to drop location
            targetLocation = trip.dropLocation;
            isGoingToPickup = false;
            locationDescription = trip.tripDirection === 'home_to_school' ? 'school (drop)' : 'home (drop)';
        }
        
        log(`[DEBUG] Target location (${locationDescription}): ${JSON.stringify(targetLocation)}`);
        log(`[DEBUG] Is going to pickup: ${isGoingToPickup}`);

        if (!targetLocation || targetLocation.length < 2) {
            log('[WARN] No target location available');
            return res.json({ skipped: true, reason: 'No target location' });
        }

        // Calculate distance using Haversine formula
        const distance = calculateHaversineDistance(driverLocation, targetLocation);
        log(`[INFO] Distance to target (${locationDescription}): ${distance.toFixed(0)}m`);

        const notifications = [];
        const geofenceEvents = [];
        const updates = {};

        // 500m - Approaching notification
        if (distance <= 500 && !trip.approachingNotified) {
            log('[INFO] Driver is approaching (< 500m)');

            const minutesAway = Math.ceil(distance / 333); // ~20km/h = 333m/min
            const locationName = locationDescription.split(' ')[0]; // "home" or "school"

            notifications.push({
                userId: parentUserId,  // Use actual users table ID, not parents table row ID
                title: '🚗 Driver Approaching',
                body: `Driver is about ${Math.max(1, minutesAway)} minutes away from ${locationName}.`,
                // Using 'driver_arrived' with 'approaching' event in data to distinguish
                type: 'driver_arrived',
                data: { 
                    tripId: trip.$id, 
                    event: 'approaching',
                    distanceMeters: Math.round(distance),
                    estimatedMinutes: Math.max(1, minutesAway),
                }
            });

            // Use correct eventType: 'approaching_pickup' or 'approaching_drop'
            const eventType = isGoingToPickup ? 'approaching_pickup' : 'approaching_drop';
            
            geofenceEvents.push({
                tripId: trip.$id,
                driverId: trip.driverId,
                eventType: eventType,
                driverLocation: driverLocation,
                targetLocation: targetLocation,
                distanceMeters: Math.round(distance),
                notificationSent: true,
            });

            updates.approachingNotified = true;
            log(`[DEBUG] Geofence event type: ${eventType}`);
        }

        // 100m - Arrived notification
        if (distance <= 100 && !trip.arrivedNotified) {
            log('[INFO] Driver has arrived (< 100m)');

            const locationName = locationDescription.split(' ')[0]; // "home" or "school"

            notifications.push({
                userId: parentUserId,  // Use actual users table ID, not parents table row ID
                title: '📍 Driver Arrived',
                body: `Driver has arrived at ${locationName}!`,
                type: 'driver_arrived',
                data: { 
                    tripId: trip.$id, 
                    event: 'arrived',
                    location: locationName,
                }
            });

            // Use correct eventType: 'arrived_pickup' or 'arrived_drop'
            const eventType = isGoingToPickup ? 'arrived_pickup' : 'arrived_drop';
            
            geofenceEvents.push({
                tripId: trip.$id,
                driverId: trip.driverId,
                eventType: eventType,
                driverLocation: driverLocation,
                targetLocation: targetLocation,
                distanceMeters: Math.round(distance),
                notificationSent: true,
            });

            updates.arrivedNotified = true;
            updates.arrivedAt = new Date().toISOString();
            log(`[DEBUG] Geofence event type: ${eventType}`);
        }

        // Create geofence events
        for (const event of geofenceEvents) {
            try {
                log(`[DEBUG] Creating geofence event: ${JSON.stringify(event)}`);
                const createdEvent = await tablesDB.createRow({
                    databaseId: databaseId,
                    tableId: 'geofence_events',
                    rowId: ID.unique(),
                    data: event
                });
                log(`[SUCCESS] Logged geofence event: ${event.eventType}, ID: ${createdEvent.$id}`);
            } catch (e) {
                error(`[ERROR] Failed to log geofence event: ${e.message}`);
                log(`[DEBUG] Event data that failed: ${JSON.stringify(event)}`);
            }
        }

        // Create notification records AND send FCM push
        for (const notif of notifications) {
            try {
                log(`[DEBUG] Creating notification: type=${notif.type}, userId=${notif.userId}`);
                
                // 1. Create notification record in database
                const createdNotif = await tablesDB.createRow({
                    databaseId: databaseId,
                    tableId: 'notifications',
                    rowId: ID.unique(),
                    data: {
                        userId: notif.userId,
                        targetRole: 'parent',
                        title: notif.title,
                        body: notif.body,
                        type: notif.type,
                        payload: JSON.stringify(notif.data), // RENAMED from 'data' to 'payload' to avoid Appwrite SDK conflict
                        isRead: false,
                    }
                });
                log(`[SUCCESS] Created notification: ${notif.type}, ID: ${createdNotif.$id}`);
                
                // 2. Send FCM push notification via Appwrite Messaging
                try {
                    log(`[DEBUG] Sending FCM push to user: ${notif.userId}`);
                    await messaging.createPush(
                        ID.unique(),                              // messageId
                        notif.title,                              // title
                        notif.body,                               // body
                        [],                                       // topics (optional)
                        [notif.userId],                           // users (target by user ID)
                        [],                                       // targets (optional)
                        {                                         // data payload (object, not string)
                            type: notif.type,
                            notificationId: createdNotif.$id,
                            tripId: notif.data.tripId || '',
                            event: notif.data.event || '',
                        },
                        undefined,                                // action (optional)
                        undefined,                                // image (optional)
                        undefined,                                // icon (optional)
                        undefined,                                // sound (optional)
                        undefined,                                // color (optional)
                        undefined,                                // tag (optional)
                        undefined,                                // badge (optional - must be integer or undefined)
                        false,                                    // draft
                    );
                    log(`[SUCCESS] FCM push sent to user: ${notif.userId}`);
                } catch (fcmError) {
                    log(`[WARN] FCM push failed (non-critical): ${fcmError.message}`);
                    // Don't fail the function if FCM fails - notification is still in DB
                }
            } catch (e) {
                error(`[ERROR] Failed to create notification: ${e.message}`);
                log(`[DEBUG] Notification data that failed: type=${notif.type}, userId=${notif.userId}`);
            }
        }

        // Update trip notification flags
        if (Object.keys(updates).length > 0) {
            try {
                log(`[DEBUG] Updating trip ${trip.$id} with: ${JSON.stringify(updates)}`);
                await tablesDB.updateRow({
                    databaseId: databaseId,
                    tableId: 'trips',
                    rowId: trip.$id,
                    data: updates
                });
                log(`[SUCCESS] Updated trip flags: ${JSON.stringify(updates)}`);
            } catch (e) {
                error(`[ERROR] Failed to update trip: ${e.message}`);
            }
        }

        log('='.repeat(60));
        log(`[SUMMARY] Process geofence complete for trip ${trip.$id}`);
        log(`[SUMMARY] Distance: ${Math.round(distance)}m, Notifications: ${notifications.length}, Events: ${geofenceEvents.length}`);
        log('='.repeat(60));

        return res.json({
            success: true,
            tripId: trip.$id,
            distanceMeters: Math.round(distance),
            notificationsSent: notifications.length,
            eventsLogged: geofenceEvents.length,
            updatedFlags: Object.keys(updates),
        });

    } catch (e) {
        error(`[FATAL] Fatal error in process-geofence: ${e.message}`);
        log(`[DEBUG] Fatal error stack: ${e.stack}`);
        return res.json({
            success: false,
            error: e.message,
            stack: e.stack,
        }, 500);
    }
};

/**
 * Calculate distance between two points using Haversine formula
 * @param {number[]} point1 - [longitude, latitude]
 * @param {number[]} point2 - [longitude, latitude]
 * @returns {number} Distance in meters
 */
function calculateHaversineDistance(point1, point2) {
    const R = 6371000; // Earth radius in meters

    const lat1 = point1[1] * Math.PI / 180;
    const lat2 = point2[1] * Math.PI / 180;
    const deltaLat = (point2[1] - point1[1]) * Math.PI / 180;
    const deltaLon = (point2[0] - point1[0]) * Math.PI / 180;

    const a = Math.sin(deltaLat / 2) * Math.sin(deltaLat / 2) +
        Math.cos(lat1) * Math.cos(lat2) *
        Math.sin(deltaLon / 2) * Math.sin(deltaLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c; // Distance in meters
}
