import { Client, TablesDB, Messaging, ID, Query } from 'node-appwrite';

/**
 * Notify Service Request - Appwrite Function
 * 
 * Trigger: Event - `databases.godropme_db.tables.service_requests.rows.*.create` (Tables DB)
 *          Event - `databases.godropme_db.tables.service_requests.rows.*.update` (Tables DB)
 * 
 * Purpose: Send notifications for service request lifecycle:
 * - CREATE: Notify driver of new request (request_received)
 * - UPDATE status='accepted': Notify parent (request_accepted)
 * - UPDATE status='rejected': Notify parent (request_rejected)
 * 
 * NOTE: For Tables DB, the row data is NOT sent in req.body. We must extract 
 * the row ID from the event string and fetch the row data from the database.
 * 
 * IMPORTANT: notifications.type enum values:
 * ['trip_started', 'driver_arrived', 'child_picked', 'child_dropped', 'request_received', 
 *  'request_accepted', 'request_rejected', 'new_message', 'system']
 */

/**
 * Extract row/document ID from event string
 * Supports BOTH:
 * - Tables DB format: databases.{dbId}.tables.{tableId}.rows.{rowId}.{action}
 * - Documents API format: databases.{dbId}.collections.{collId}.documents.{docId}.{action}
 * @param {string} event - The event string
 * @returns {string|null} - The row/document ID or null if not found
 */
function extractRowIdFromEvent(event) {
    // Try Tables DB format first: rows.{rowId}.update
    let match = event.match(/rows\.([^.]+)\.(update|create|delete)/);
    if (match) return match[1];
    
    // Try Documents API format: documents.{docId}.update
    match = event.match(/documents\.([^.]+)\.(update|create|delete)/);
    return match ? match[1] : null;
}

export default async ({ req, res, log, error }) => {
    log('='.repeat(60));
    log('[notify-service-request] Function started');
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

        // Check if this is a service_requests event
        // Support BOTH Tables DB format (tables.*.rows) AND Documents API format (collections.*.documents)
        // This handles both API formats during migration
        const isTablesDBEvent = event.includes('tables.service_requests.rows');
        const isDocumentsAPIEvent = event.includes('collections.service_requests.documents');
        
        if (!isTablesDBEvent && !isDocumentsAPIEvent) {
            log('[INFO] Not a service_requests event, exiting');
            return res.json({ success: true, message: 'Not a service_requests event' });
        }
        
        log(`[DEBUG] Event format: ${isTablesDBEvent ? 'TablesDB' : 'Documents API'}`);

        // Extract row/document ID from event
        const requestId = extractRowIdFromEvent(event);
        if (!requestId) {
            log('[ERROR] Could not extract request ID from event');
            return res.json({ success: false, message: 'Could not extract request ID from event' });
        }
        log(`[DEBUG] Extracted Service Request ID: ${requestId}`);

        // Fetch the service request data from database (Tables DB uses getRow)
        let serviceRequest;
        try {
            serviceRequest = await tablesDB.getRow({
                databaseId: databaseId,
                tableId: 'service_requests',
                rowId: requestId
            });
            log(`[DEBUG] Service request fetched successfully`);
        } catch (e) {
            log(`[ERROR] Could not fetch service request: ${e.message}`);
            return res.json({ success: false, message: `Could not fetch service request: ${e.message}` });
        }

        log(`[DEBUG] Service Request ID: ${serviceRequest.$id}`);
        log(`[DEBUG] Service Request Status: ${serviceRequest.status}`);
        log(`[DEBUG] Parent Row ID: ${serviceRequest.parentId}`);
        log(`[DEBUG] Driver Row ID: ${serviceRequest.driverId}`);

        // IMPORTANT: serviceRequest.parentId and driverId are row IDs in parents/drivers tables
        // We need to fetch the actual userId from those tables for notifications/FCM
        let parentUserId = null;
        let driverUserId = null;
        
        try {
            const parent = await tablesDB.getRow({
                databaseId: databaseId,
                tableId: 'parents',
                rowId: serviceRequest.parentId
            });
            parentUserId = parent.userId;
            log(`[DEBUG] Parent user ID: ${parentUserId}`);
        } catch (e) {
            log(`[WARN] Could not fetch parent: ${e.message}`);
        }
        
        try {
            const driver = await tablesDB.getRow({
                databaseId: databaseId,
                tableId: 'drivers',
                rowId: serviceRequest.driverId
            });
            driverUserId = driver.userId;
            log(`[DEBUG] Driver user ID: ${driverUserId}`);
        } catch (e) {
            log(`[WARN] Could not fetch driver: ${e.message}`);
        }

        // Determine notification type based on event and status
        let notificationType = null;
        let targetUserId = null;
        let targetRole = null;
        let title = '';
        let body = '';
        let notificationData = {};

        // Check if this is a CREATE or UPDATE event
        const isCreate = event.includes('.create');
        const isUpdate = event.includes('.update');
        
        log(`[DEBUG] Is Create: ${isCreate}, Is Update: ${isUpdate}`);

        if (isCreate) {
            // New request - notify the driver
            notificationType = 'request_received';
            targetUserId = driverUserId;  // Use actual users table ID
            targetRole = 'driver';
            title = '🚗 New Service Request';
            body = 'A parent has requested your services for school pickup/drop.';
            notificationData = {
                requestId: serviceRequest.$id,
                parentId: serviceRequest.parentId,
                action: 'view_request',
            };
            log(`[DEBUG] CREATE event - notifying driver: ${targetUserId}`);
        } else if (isUpdate) {
            const status = serviceRequest.status;
            log(`[DEBUG] UPDATE event - status: ${status}`);

            if (status === 'accepted') {
                // Request accepted - notify the parent
                notificationType = 'request_accepted';
                targetUserId = parentUserId;  // Use actual users table ID
                targetRole = 'parent';
                title = '✅ Request Accepted';
                body = 'Your service request has been accepted by the driver!';
                notificationData = {
                    requestId: serviceRequest.$id,
                    driverId: serviceRequest.driverId,
                    action: 'view_request',
                };
                log(`[DEBUG] Request ACCEPTED - notifying parent: ${targetUserId}`);
            } else if (status === 'rejected') {
                // Request rejected - notify the parent
                notificationType = 'request_rejected';
                targetUserId = parentUserId;  // Use actual users table ID
                targetRole = 'parent';
                title = '❌ Request Declined';
                body = 'Your service request has been declined. You can try other drivers.';
                notificationData = {
                    requestId: serviceRequest.$id,
                    driverId: serviceRequest.driverId,
                    action: 'find_drivers',
                };
                log(`[DEBUG] Request REJECTED - notifying parent: ${targetUserId}`);
            } else {
                log(`[INFO] Status "${status}" does not trigger notification`);
                return res.json({ success: true, message: `Status ${status} does not trigger notification` });
            }
        } else {
            log('[INFO] Not a create or update event, exiting');
            return res.json({ success: true, message: 'Not a create or update event' });
        }

        // Validate we have all required data
        if (!notificationType || !targetUserId) {
            log('[ERROR] Missing notification type or target user');
            return res.json({ success: false, message: 'Missing notification data' });
        }

        // Create notification in database
        log(`[DEBUG] Creating notification: type=${notificationType}, userId=${targetUserId}`);
        const createdNotif = await tablesDB.createRow({
            databaseId: databaseId,
            tableId: 'notifications',
            rowId: ID.unique(),
            data: {
                userId: targetUserId,
                targetRole: targetRole,
                title: title,
                body: body,
                type: notificationType,
                payload: JSON.stringify(notificationData),
                isRead: false,
            }
        });
        log(`[SUCCESS] Created notification: ${createdNotif.$id}`);

        // Send FCM push notification via Appwrite Messaging
        try {
            log(`[DEBUG] Sending FCM push to user: ${targetUserId}`);
            await messaging.createPush(
                ID.unique(),                              // messageId
                title,                                    // title
                body,                                     // body
                [],                                       // topics (optional)
                [targetUserId],                           // users (target by user ID)
                [],                                       // targets (optional)
                {                                         // data payload (object, not string)
                    type: notificationType,
                    notificationId: createdNotif.$id,
                    requestId: notificationData.requestId || '',
                    action: notificationData.action || '',
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
            log(`[SUCCESS] FCM push sent to user: ${targetUserId}`);
        } catch (fcmError) {
            log(`[WARN] FCM push failed (non-critical): ${fcmError.message}`);
            // Don't fail the function if FCM fails - notification is still in DB
        }

        log('[notify-service-request] Function completed successfully');
        return res.json({
            success: true,
            notificationType: notificationType,
            targetUserId: targetUserId,
            notificationId: createdNotif.$id,
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
