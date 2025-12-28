import { Client, TablesDB, Messaging, ID, Users } from 'node-appwrite';

/**
 * Notify Application Status - Appwrite Function
 * 
 * Trigger: Event - `databases.godropme_db.tables.users.rows.*.update` (Tables DB)
 * 
 * Purpose: Send notifications when driver application status changes:
 * - pending → active (Approved) - Push + Email ✅
 * - pending → rejected (Rejected) - Push + Email ❌
 * - active → suspended (Suspended) - Push + Email ⚠️
 * 
 * Uses notification type: 'system'
 * 
 * NOTE: For Tables DB, the row data is NOT sent in req.body. We must extract 
 * the row ID from the event string and fetch the row data from the database.
 * 
 * IMPORTANT: users.status enum values:
 * ['pending', 'active', 'suspended', 'rejected']
 * 
 * IMPORTANT: users.role enum values:
 * ['parent', 'driver']
 */

/**
 * Extract row ID from event string
 * Event formats:
 * - Tables DB: databases.{dbId}.tables.{tableId}.rows.{rowId}.{action}
 * - Collections: databases.{dbId}.collections.{collectionId}.documents.{docId}.{action}
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
 * Get notification content based on status change
 * @param {string} newStatus - New status value
 * @param {string} statusReason - Optional reason provided by admin
 * @param {string} driverName - Driver's full name
 * @returns {Object} - { title, body, emailSubject, emailContent }
 */
function getNotificationContent(newStatus, statusReason, driverName) {
    const firstName = driverName?.split(' ')[0] || 'Driver';
    
    switch (newStatus) {
        case 'active':
            return {
                title: '🎉 Application Approved!',
                body: 'Congratulations! Your driver application has been approved. You can now start accepting ride requests.',
                emailSubject: '🎉 GoDropMe - Your Driver Application is Approved!',
                emailContent: `
Dear ${driverName},

Great news! Your driver application for GoDropMe has been APPROVED! 🎉

You are now officially a GoDropMe driver and can start accepting service requests from parents in your area.

What's next?
1. Open the GoDropMe app
2. Go online and start receiving requests

Thank you for joining the GoDropMe family. We're excited to have you on board!

Safe driving! 🚗

Best regards,
The GoDropMe Team
                `.trim()
            };
            
        case 'rejected':
            return {
                title: '❌ Application Not Approved',
                body: statusReason || 'We regret to inform you that your driver application was not approved at this time.',
                emailSubject: '❌ GoDropMe - Driver Application Update',
                emailContent: `
Dear ${driverName},

Thank you for your interest in becoming a GoDropMe driver.

After careful review, we regret to inform you that your application has not been approved at this time.

${statusReason ? `Reason: ${statusReason}` : ''}

If you believe this was an error or would like to reapply with updated information, please contact our support team.

We appreciate your understanding.

Best regards,
The GoDropMe Team
                `.trim()
            };
            
        case 'suspended':
            return {
                title: '⚠️ Account Suspended',
                body: 'Your driver account has been suspended. Please contact support for more information.',
                emailSubject: '⚠️ GoDropMe - Account Suspended',
                emailContent: `
Dear ${driverName},

We need to inform you that your GoDropMe driver account has been SUSPENDED.

${statusReason ? `Reason: ${statusReason}` : 'Please contact our support team for more details.'}

During this suspension:
- You will not receive new service requests
- Your profile will not be visible to parents
- Existing active services may be affected

If you have questions or wish to appeal this decision, please contact our support team.

Best regards,
The GoDropMe Team
                `.trim()
            };
            
        default:
            return null;
    }
}

export default async ({ req, res, log, error }) => {
    log('='.repeat(60));
    log('[notify-application-status] Function started');
    log(`[DEBUG] Execution time: ${new Date().toISOString()}`);
    
    // Initialize Appwrite client
    const client = new Client()
        .setEndpoint(process.env.APPWRITE_ENDPOINT || 'https://fra.cloud.appwrite.io/v1')
        .setProject(process.env.APPWRITE_FUNCTION_PROJECT_ID)
        .setKey(process.env.APPWRITE_API_KEY);

    const tablesDB = new TablesDB(client);
    const messaging = new Messaging(client);
    const users = new Users(client);
    const databaseId = 'godropme_db';
    
    log(`[DEBUG] Database ID: ${databaseId}`);
    log(`[DEBUG] Project ID: ${process.env.APPWRITE_FUNCTION_PROJECT_ID}`);

    try {
        // Parse the event from request headers
        const event = req.headers['x-appwrite-event'] || '';
        log(`[DEBUG] Event: ${event}`);
        
        // Only process users update events (supports both Tables DB and Collections formats)
        const isTablesDBEvent = event.includes('tables.users.rows') && event.includes('.update');
        const isCollectionsEvent = event.includes('collections.users.documents') && event.includes('.update');
        
        if (!isTablesDBEvent && !isCollectionsEvent) {
            log('[INFO] Not a users update event, exiting');
            return res.json({ success: true, message: 'Not a users update event' });
        }
        log(`[DEBUG] Event type: ${isTablesDBEvent ? 'TablesDB' : 'Collections'}`);

        // Extract row ID from event (Tables DB doesn't send body data)
        const userRowId = extractRowIdFromEvent(event);
        if (!userRowId) {
            log('[ERROR] Could not extract user row ID from event');
            return res.json({ success: false, message: 'Could not extract user row ID from event' });
        }
        log(`[DEBUG] Extracted User Row ID: ${userRowId}`);

        // Fetch the user data from database
        let userRow;
        try {
            userRow = await tablesDB.getRow({
                databaseId: databaseId,
                tableId: 'users',
                rowId: userRowId
            });
            log(`[DEBUG] User row fetched successfully`);
        } catch (e) {
            log(`[ERROR] Could not fetch user row: ${e.message}`);
            return res.json({ success: false, message: `Could not fetch user row: ${e.message}` });
        }

        log(`[DEBUG] User Row ID: ${userRow.$id}`);
        log(`[DEBUG] User Role: ${userRow.role}`);
        log(`[DEBUG] User Status: ${userRow.status}`);
        log(`[DEBUG] Last Notified Status: ${userRow.lastNotifiedStatus || '(none)'}`);
        log(`[DEBUG] User Email: ${userRow.email}`);
        log(`[DEBUG] Status Reason: ${userRow.statusReason || '(none)'}`);

        // Only process driver status changes
        if (userRow.role !== 'driver') {
            log('[INFO] Not a driver user, exiting');
            return res.json({ success: true, message: 'Not a driver user' });
        }

        // Check if status is one we should notify about
        const notifiableStatuses = ['active', 'rejected', 'suspended'];
        if (!notifiableStatuses.includes(userRow.status)) {
            log(`[INFO] Status "${userRow.status}" does not trigger notification`);
            return res.json({ success: true, message: `Status ${userRow.status} does not trigger notification` });
        }

        // CRITICAL: Check if status has actually changed from last notified status
        // This prevents duplicate notifications when other fields (like fcmToken) are updated
        if (userRow.lastNotifiedStatus === userRow.status) {
            log(`[INFO] Status "${userRow.status}" already notified (lastNotifiedStatus matches), skipping`);
            return res.json({ success: true, message: 'Status already notified, skipping duplicate' });
        }
        log(`[DEBUG] Status change detected: ${userRow.lastNotifiedStatus || 'none'} → ${userRow.status}`)

        // Fetch driver profile to get full name
        let driverName = 'Driver';
        let driverRowId = null;
        try {
            // Query drivers table by userId
            const driversResult = await tablesDB.listRows({
                databaseId: databaseId,
                tableId: 'drivers'
            });
            const driverRow = driversResult.rows.find(d => d.userId === userRow.$id);
            if (driverRow) {
                driverName = driverRow.fullName || 'Driver';
                driverRowId = driverRow.$id;
                log(`[DEBUG] Driver name: ${driverName}`);
            }
        } catch (e) {
            log(`[WARN] Could not fetch driver details: ${e.message}`);
        }

        // Get notification content
        const content = getNotificationContent(
            userRow.status,
            userRow.statusReason,
            driverName
        );

        if (!content) {
            log('[ERROR] Could not generate notification content');
            return res.json({ success: false, message: 'Could not generate notification content' });
        }

        log(`[DEBUG] Notification title: ${content.title}`);
        log(`[DEBUG] Notification body: ${content.body}`);

        // Create notification in database
        log(`[DEBUG] Creating notification in database...`);
        const createdNotif = await tablesDB.createRow({
            databaseId: databaseId,
            tableId: 'notifications',
            rowId: ID.unique(),
            data: {
                userId: userRow.$id,
                targetRole: 'driver',
                title: content.title,
                body: content.body,
                type: 'system',
                payload: JSON.stringify({
                    status: userRow.status,
                    statusReason: userRow.statusReason || '',
                    action: 'view_status',
                }),
                isRead: false,
            }
        });
        log(`[SUCCESS] Created notification: ${createdNotif.$id}`);

        // Send FCM push notification
        let pushSent = false;
        try {
            log(`[DEBUG] Sending FCM push to user: ${userRow.$id}`);
            await messaging.createPush(
                ID.unique(),                              // messageId
                content.title,                            // title
                content.body,                             // body
                [],                                       // topics
                [userRow.$id],                            // users (by user row ID)
                [],                                       // targets
                {                                         // data payload
                    type: 'system',
                    notificationId: createdNotif.$id,
                    status: userRow.status,
                    action: 'view_status',
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
            log(`[SUCCESS] FCM push sent to user: ${userRow.$id}`);
        } catch (fcmError) {
            log(`[WARN] FCM push failed (non-critical): ${fcmError.message}`);
        }

        // Send email notification
        let emailSent = false;
        if (userRow.email) {
            try {
                log(`[DEBUG] Sending email to: ${userRow.email}`);
                
                // Get the user's email target from Appwrite Users API
                // First, we need to find the Appwrite Auth user ID
                // The userRow.$id is the users table row ID, but we need the Auth account ID
                // Since we store userId in drivers table which references users table,
                // and users table row ID should match Appwrite Auth user ID
                
                // Try to get user targets for email
                const userTargets = await users.listTargets(userRow.$id);
                const emailTarget = userTargets.targets.find(t => t.providerType === 'email');
                
                if (emailTarget) {
                    await messaging.createEmail(
                        ID.unique(),                          // messageId
                        content.emailSubject,                 // subject
                        content.emailContent,                 // content
                        [],                                   // topics
                        [],                                   // users
                        [emailTarget.$id],                    // targets (email target ID)
                        [],                                   // cc
                        [],                                   // bcc
                        [],                                   // attachments
                        false,                                // draft
                        false,                                // html
                        undefined,                            // scheduledAt
                    );
                    emailSent = true;
                    log(`[SUCCESS] Email sent to: ${userRow.email}`);
                } else {
                    log(`[WARN] No email target found for user`);
                }
            } catch (emailError) {
                log(`[WARN] Email failed (non-critical): ${emailError.message}`);
            }
        } else {
            log(`[WARN] User has no email address`);
        }

        // Update lastNotifiedStatus to prevent duplicate notifications
        try {
            log(`[DEBUG] Updating lastNotifiedStatus to: ${userRow.status}`);
            await tablesDB.updateRow({
                databaseId: databaseId,
                tableId: 'users',
                rowId: userRow.$id,
                data: {
                    lastNotifiedStatus: userRow.status,
                }
            });
            log(`[SUCCESS] Updated lastNotifiedStatus to: ${userRow.status}`);
        } catch (updateError) {
            log(`[WARN] Could not update lastNotifiedStatus: ${updateError.message}`);
        }

        log('[notify-application-status] Function completed successfully');
        return res.json({
            success: true,
            status: userRow.status,
            userId: userRow.$id,
            notificationId: createdNotif.$id,
            pushSent: pushSent,
            emailSent: emailSent,
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
