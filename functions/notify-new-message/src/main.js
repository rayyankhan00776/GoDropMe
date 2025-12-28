import { Client, TablesDB, Messaging, ID } from 'node-appwrite';

/**
 * Notify New Message - Appwrite Function
 * 
 * Trigger: Event - `databases.godropme_db.tables.messages.rows.*.create` (Tables DB)
 * 
 * Purpose: Send push notification when a new chat message is received:
 * - If sender is parent → notify driver
 * - If sender is driver → notify parent
 * 
 * Uses notification type: 'new_message'
 * 
 * NOTE: For Tables DB, the row data is NOT sent in req.body. We must extract 
 * the row ID from the event string and fetch the row data from the database.
 * 
 * IMPORTANT: messages.senderRole enum values:
 * ['parent', 'driver']
 * 
 * IMPORTANT: messages.messageType enum values:
 * ['text', 'image', 'location']
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

/**
 * Get message preview based on message type
 * @param {Object} message - The message object
 * @returns {string} - Preview text
 */
function getMessagePreview(message) {
    switch (message.messageType) {
        case 'text':
            // Truncate long messages
            const text = message.text || '';
            return text.length > 50 ? text.substring(0, 50) + '...' : text;
        case 'image':
            return '📷 Sent an image';
        case 'location':
            return '📍 Shared a location';
        default:
            return 'New message';
    }
}

export default async ({ req, res, log, error }) => {
    log('='.repeat(60));
    log('[notify-new-message] Function started');
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
        
        // Only process messages create events (supports both Tables DB and Collections formats)
        const isTablesDBEvent = event.includes('tables.messages.rows') && event.includes('.create');
        const isCollectionsEvent = event.includes('collections.messages.documents') && event.includes('.create');
        
        if (!isTablesDBEvent && !isCollectionsEvent) {
            log('[INFO] Not a messages create event, exiting');
            return res.json({ success: true, message: 'Not a messages create event' });
        }
        log(`[DEBUG] Event format: ${isTablesDBEvent ? 'TablesDB' : 'Collections'}`);

        // Extract row ID from event (Tables DB doesn't send body data)
        const messageId = extractRowIdFromEvent(event);
        if (!messageId) {
            log('[ERROR] Could not extract message ID from event');
            return res.json({ success: false, message: 'Could not extract message ID from event' });
        }
        log(`[DEBUG] Extracted Message ID: ${messageId}`);

        // Fetch the message data from database
        let message;
        try {
            message = await tablesDB.getRow({
                databaseId: databaseId,
                tableId: 'messages',
                rowId: messageId
            });
            log(`[DEBUG] Message fetched successfully`);
        } catch (e) {
            log(`[ERROR] Could not fetch message: ${e.message}`);
            return res.json({ success: false, message: `Could not fetch message: ${e.message}` });
        }

        log(`[DEBUG] Message ID: ${message.$id}`);
        log(`[DEBUG] Chat Room ID: ${message.chatRoomId}`);
        log(`[DEBUG] Sender ID: ${message.senderId}`);
        log(`[DEBUG] Sender Role: ${message.senderRole}`);
        log(`[DEBUG] Message Type: ${message.messageType}`);

        // Fetch the chat room to get parent and driver IDs
        let chatRoom;
        try {
            chatRoom = await tablesDB.getRow({
                databaseId: databaseId,
                tableId: 'chat_rooms',
                rowId: message.chatRoomId
            });
            log(`[DEBUG] Chat room fetched: ${chatRoom.$id}`);
            log(`[DEBUG] Parent ID in chat room: ${chatRoom.parentId}`);
            log(`[DEBUG] Driver ID in chat room: ${chatRoom.driverId}`);
        } catch (e) {
            log(`[ERROR] Could not fetch chat room: ${e.message}`);
            return res.json({ success: false, message: `Could not fetch chat room: ${e.message}` });
        }

        // Determine recipient based on sender role
        let recipientUserId = null;
        let recipientRole = null;
        let senderName = 'Someone';
        
        if (message.senderRole === 'parent') {
            // Parent sent message → notify driver
            // chatRoom.driverId is the drivers table row ID, need to get userId
            try {
                const driver = await tablesDB.getRow({
                    databaseId: databaseId,
                    tableId: 'drivers',
                    rowId: chatRoom.driverId
                });
                recipientUserId = driver.userId;
                recipientRole = 'driver';
                log(`[DEBUG] Recipient (driver) user ID: ${recipientUserId}`);
            } catch (e) {
                log(`[ERROR] Could not fetch driver: ${e.message}`);
                return res.json({ success: false, message: `Could not fetch driver: ${e.message}` });
            }
            
            // Get sender (parent) name
            try {
                const parent = await tablesDB.getRow({
                    databaseId: databaseId,
                    tableId: 'parents',
                    rowId: chatRoom.parentId
                });
                senderName = parent.fullName || 'A parent';
                log(`[DEBUG] Sender (parent) name: ${senderName}`);
            } catch (e) {
                log(`[WARN] Could not fetch parent name: ${e.message}`);
            }
        } else if (message.senderRole === 'driver') {
            // Driver sent message → notify parent
            // chatRoom.parentId is the parents table row ID, need to get userId
            try {
                const parent = await tablesDB.getRow({
                    databaseId: databaseId,
                    tableId: 'parents',
                    rowId: chatRoom.parentId
                });
                recipientUserId = parent.userId;
                recipientRole = 'parent';
                log(`[DEBUG] Recipient (parent) user ID: ${recipientUserId}`);
            } catch (e) {
                log(`[ERROR] Could not fetch parent: ${e.message}`);
                return res.json({ success: false, message: `Could not fetch parent: ${e.message}` });
            }
            
            // Get sender (driver) name
            try {
                const driver = await tablesDB.getRow({
                    databaseId: databaseId,
                    tableId: 'drivers',
                    rowId: chatRoom.driverId
                });
                senderName = driver.fullName || 'Your driver';
                log(`[DEBUG] Sender (driver) name: ${senderName}`);
            } catch (e) {
                log(`[WARN] Could not fetch driver name: ${e.message}`);
            }
        } else {
            log(`[ERROR] Unknown sender role: ${message.senderRole}`);
            return res.json({ success: false, message: `Unknown sender role: ${message.senderRole}` });
        }

        if (!recipientUserId) {
            log('[ERROR] Could not determine recipient user ID');
            return res.json({ success: false, message: 'Could not determine recipient' });
        }

        // Prepare notification content
        const messagePreview = getMessagePreview(message);
        const title = `💬 ${senderName}`;
        const body = messagePreview;

        log(`[DEBUG] Notification title: ${title}`);
        log(`[DEBUG] Notification body: ${body}`);

        // Create notification in database
        log(`[DEBUG] Creating notification in database...`);
        const createdNotif = await tablesDB.createRow({
            databaseId: databaseId,
            tableId: 'notifications',
            rowId: ID.unique(),
            data: {
                userId: recipientUserId,
                targetRole: recipientRole,
                title: title,
                body: body,
                type: 'new_message',
                payload: JSON.stringify({
                    chatRoomId: message.chatRoomId,
                    messageId: message.$id,
                    senderId: message.senderId,
                    senderRole: message.senderRole,
                    senderName: senderName,
                    action: 'open_chat',
                }),
                isRead: false,
            }
        });
        log(`[SUCCESS] Created notification: ${createdNotif.$id}`);

        // Send FCM push notification
        let pushSent = false;
        try {
            log(`[DEBUG] Sending FCM push to user: ${recipientUserId}`);
            await messaging.createPush(
                ID.unique(),                              // messageId
                title,                                    // title
                body,                                     // body
                [],                                       // topics
                [recipientUserId],                        // users (by user ID)
                [],                                       // targets
                {                                         // data payload
                    type: 'new_message',
                    notificationId: createdNotif.$id,
                    chatRoomId: message.chatRoomId,
                    messageId: message.$id,
                    senderRole: message.senderRole,
                    action: 'open_chat',
                },
                undefined,                                // action
                undefined,                                // image
                undefined,                                // icon
                undefined,                                // sound
                undefined,                                // color
                undefined,                                // tag
                undefined,                                // badge
                false,                                    // draft
            );
            pushSent = true;
            log(`[SUCCESS] FCM push sent to user: ${recipientUserId}`);
        } catch (fcmError) {
            log(`[WARN] FCM push failed (non-critical): ${fcmError.message}`);
        }

        log('[notify-new-message] Function completed successfully');
        return res.json({
            success: true,
            messageId: message.$id,
            recipientUserId: recipientUserId,
            recipientRole: recipientRole,
            notificationId: createdNotif.$id,
            pushSent: pushSent,
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
