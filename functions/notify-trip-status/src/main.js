import { Client, TablesDB, Messaging, ID, Query } from 'node-appwrite';

/**
 * Notify Trip Status - Appwrite Function
 * 
 * Trigger: Event - `databases.godropme_db.tables.trips.rows.*.update` (Tables DB)
 * 
 * Purpose: Send notifications for trip STATUS changes (NOT geofence/distance-based):
 * - status='driver_enroute' (from 'scheduled'): Notify parent (trip_started)
 * - status='picked' (from 'arrived'): Notify parent (child_picked)
 * - status='dropped' (from 'in_transit'): Notify parent (child_dropped)
 * 
 * Uses notification flags on trips table to prevent duplicates:
 * - pickedNotified: set when child_picked notification sent
 * - droppedNotified: set when child_dropped notification sent
 * 
 * NOTE: For Tables DB, the row data is NOT sent in req.body. We must extract 
 * the row ID from the event string and fetch the row data from the database.
 * 
 * NOTE: Geofence-based notifications (driver_arrived at 500m/100m) are handled by
 * process-geofence function, NOT this one.
 * 
 * IMPORTANT: trips.status enum values:
 * ['scheduled', 'driver_enroute', 'arrived', 'picked', 'in_transit', 'dropped', 'cancelled', 'absent']
 * 
 * IMPORTANT: notifications.type enum values:
 * ['trip_started', 'driver_arrived', 'child_picked', 'child_dropped', 'request_received', 
 *  'request_accepted', 'request_rejected', 'new_message', 'system']
 */

/**
 * Extract row ID from Tables DB event string
 * Event format: databases.{dbId}.tables.{tableId}.rows.{rowId}.{action}
 * @param {string} event - The event string
 * @returns {string|null} - The row ID or null if not found
 */
function extractRowIdFromEvent(event) {
    // Match pattern: rows.{rowId}.update or rows.{rowId}.create
    const match = event.match(/rows\.([^.]+)\.(update|create|delete)/);
    return match ? match[1] : null;
}

export default async ({ req, res, log, error }) => {
    log('='.repeat(60));
    log('[notify-trip-status] Function started');
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
        
        // Only process trip update events (Tables DB format)
        if (!event.includes('tables.trips.rows') || !event.includes('.update')) {
            log('[INFO] Not a trips table row update event, exiting');
            return res.json({ success: true, message: 'Not a trips update event' });
        }

        // Extract row ID from event (Tables DB doesn't send body data)
        const tripId = extractRowIdFromEvent(event);
        if (!tripId) {
            log('[ERROR] Could not extract trip ID from event');
            return res.json({ success: false, message: 'Could not extract trip ID from event' });
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
            return res.json({ success: false, message: `Could not fetch trip: ${e.message}` });
        }

        log(`[DEBUG] Trip ID: ${trip.$id}`);
        log(`[DEBUG] Trip Status: ${trip.status}`);
        log(`[DEBUG] Trip Type: ${trip.tripType}`);
        log(`[DEBUG] Trip Direction: ${trip.tripDirection}`);
        log(`[DEBUG] Parent Row ID: ${trip.parentId}`);
        log(`[DEBUG] Child ID: ${trip.childId}`);
        log(`[DEBUG] Driver Row ID: ${trip.driverId}`);

        // IMPORTANT: trip.parentId is the parents table row ID, NOT the users table ID
        // We need to fetch the parent row to get the actual userId for notifications/FCM
        let parentUserId = null;
        try {
            const parent = await tablesDB.getRow({
                databaseId: databaseId,
                tableId: 'parents',
                rowId: trip.parentId
            });
            parentUserId = parent.userId;
            log(`[DEBUG] Parent user ID (for notifications): ${parentUserId}`);
        } catch (e) {
            log(`[ERROR] Could not fetch parent: ${e.message}`);
            return res.json({ success: false, message: `Could not fetch parent: ${e.message}` });
        }

        // Fetch child details for personalized messages
        let childName = 'Your child';
        try {
            const child = await tablesDB.getRow({
                databaseId: databaseId,
                tableId: 'children',
                rowId: trip.childId
            });
            childName = child.name || 'Your child';
            log(`[DEBUG] Child name: ${childName}`);
        } catch (e) {
            log(`[WARN] Could not fetch child details: ${e.message}`);
        }

        const notifications = [];
        const updates = {};

        // Determine trip type description for notifications
        const tripTypeDesc = trip.tripType === 'morning' 
            ? 'morning pickup' 
            : 'afternoon drop-off';
        const destination = trip.tripDirection === 'home_to_school' 
            ? 'school' 
            : 'home';

        // STATUS: driver_enroute → trip_started notification
        // This is the first status change indicating driver has started the trip
        if (trip.status === 'driver_enroute') {
            log('[DEBUG] Trip status is driver_enroute - checking if trip_started notification needed');
            
            // We don't have a tripStartedNotified flag, but driverEnrouteAt being set 
            // indicates this transition just happened. We can check if notification was sent
            // by querying existing notifications or just send once per trip lifecycle.
            // For now, we'll send the notification and rely on the status change being recent.
            
            notifications.push({
                userId: parentUserId,  // Use the actual users table ID
                type: 'trip_started',
                title: '🚐 Trip Started',
                body: `The ${tripTypeDesc} trip for ${childName} has started. Track in real-time!`,
                data: {
                    tripId: trip.$id,
                    childId: trip.childId,
                    driverId: trip.driverId,
                    tripType: trip.tripType,
                    tripDirection: trip.tripDirection,
                    action: 'track_trip',
                },
            });
            log('[DEBUG] Queued trip_started notification');
        }

        // STATUS: picked → child_picked notification
        if (trip.status === 'picked' && !trip.pickedNotified) {
            log('[DEBUG] Trip status is picked - sending child_picked notification');
            
            notifications.push({
                userId: parentUserId,  // Use the actual users table ID
                type: 'child_picked',
                title: '✅ Child Picked Up',
                body: `${childName} has been safely picked up by the driver.`,
                data: {
                    tripId: trip.$id,
                    childId: trip.childId,
                    childName: childName,
                    driverId: trip.driverId,
                    pickedAt: trip.pickedAt,
                    action: 'view_trip',
                },
            });
            
            updates.pickedNotified = true;
            log('[DEBUG] Queued child_picked notification');
        }

        // STATUS: dropped → child_dropped notification
        if (trip.status === 'dropped' && !trip.droppedNotified) {
            log('[DEBUG] Trip status is dropped - sending child_dropped notification');
            
            notifications.push({
                userId: parentUserId,  // Use the actual users table ID
                type: 'child_dropped',
                title: '🏫 Child Dropped Off',
                body: `${childName} has been safely dropped off at ${destination}.`,
                data: {
                    tripId: trip.$id,
                    childId: trip.childId,
                    childName: childName,
                    driverId: trip.driverId,
                    droppedAt: trip.droppedAt,
                    destination: destination,
                    action: 'view_trip',
                },
            });
            
            updates.droppedNotified = true;
            log('[DEBUG] Queued child_dropped notification');
        }

        // If no notifications to send, exit early
        if (notifications.length === 0) {
            log('[INFO] No notifications to send for this trip update');
            return res.json({ success: true, message: 'No notifications needed' });
        }

        log(`[DEBUG] Sending ${notifications.length} notifications`);

        // Create notification records AND send FCM push
        const results = [];
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
                        payload: JSON.stringify(notif.data),
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
                            childId: notif.data.childId || '',
                            action: notif.data.action || '',
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
                }

                results.push({ userId: notif.userId, type: notif.type, success: true });
            } catch (e) {
                error(`[ERROR] Failed to create notification: ${e.message}`);
                results.push({ userId: notif.userId, type: notif.type, success: false, error: e.message });
            }
        }

        // Update trip notification flags
        if (Object.keys(updates).length > 0) {
            try {
                log(`[DEBUG] Updating trip ${trip.$id} with flags: ${JSON.stringify(updates)}`);
                await tablesDB.updateRow({
                    databaseId: databaseId,
                    tableId: 'trips',
                    rowId: trip.$id,
                    data: updates
                });
                log('[SUCCESS] Updated trip notification flags');
            } catch (e) {
                log(`[WARN] Could not update notification flags: ${e.message}`);
            }
        }

        log('[notify-trip-status] Function completed successfully');
        return res.json({
            success: true,
            notificationsSent: results.filter(r => r.success).length,
            updatedFlags: Object.keys(updates),
            results: results,
        });

    } catch (e) {
        error(`[CRITICAL] Function failed: ${e.message}`);
        error(`[DEBUG] Stack: ${e.stack}`);
        return res.json({
            success: false,
            error: e.message,
        });
    }
};
