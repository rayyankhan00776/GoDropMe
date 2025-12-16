import { Client, Databases, ID, Query } from 'node-appwrite';
/**
 * Generate Morning Trips - Appwrite Function
 * 
 * Trigger: CRON (Daily at 5:00 AM PKT - `0 5 * * *` in Asia/Karachi)
 * Purpose: Create MORNING trip records from active services
 * 
 * Morning trips = Home → School
 * - pickupLocation = child's home (pickLocation from children table)
 * - dropLocation = school (dropLocation from children table)
 * 
 * NOTE: driver_services table columns:
 * - driverId, serviceCategory, serviceAreaCenter, serviceAreaRadiusKm, 
 * - serviceAreaPolygon, serviceAreaAddress, monthlyPricePkr, extraNotes, schoolIds
 * - NO operatingDays, serviceWindow, or time window columns
 */

// Default operating days (Mon-Sat, skip Sunday)
const DEFAULT_OPERATING_DAYS = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];

// Default time windows for trips
const DEFAULT_MORNING_START = '05:00';
const DEFAULT_MORNING_END = '09:00';

export default async ({ req, res, log, error }) => {
    log('='.repeat(60));
    log('[generate-morning-trips] Function started');
    log(`[DEBUG] Execution time: ${new Date().toISOString()}`);
    
    // Initialize Appwrite client
    const client = new Client()
        .setEndpoint(process.env.APPWRITE_ENDPOINT || 'https://fra.cloud.appwrite.io/v1')
        .setProject(process.env.APPWRITE_FUNCTION_PROJECT_ID)
        .setKey(process.env.APPWRITE_API_KEY);
    const databases = new Databases(client);
    const databaseId = 'godropme_db';
    
    log(`[DEBUG] Database ID: ${databaseId}`);
    log(`[DEBUG] Project ID: ${process.env.APPWRITE_FUNCTION_PROJECT_ID}`);
    
    try {
        const today = new Date();
        const dayOfWeek = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'][today.getDay()];
        
        log(`[INFO] Generating morning trips for ${today.toDateString()} (${dayOfWeek})`);
        log(`[DEBUG] Today date: ${today.toISOString()}`);
        
        // Skip Sunday (no school in Pakistan)
        if (dayOfWeek === 'sunday') {
            log('[INFO] Sunday - no school, skipping trip generation');
            return res.json({
                success: true,
                message: 'Sunday - no trips generated',
                tripsCreated: 0,
            });
        }
        
        // Check if today is an operating day
        if (!DEFAULT_OPERATING_DAYS.includes(dayOfWeek)) {
            log(`[INFO] ${dayOfWeek} is not an operating day, skipping`);
            return res.json({
                success: true,
                message: `${dayOfWeek} is not an operating day`,
                tripsCreated: 0,
            });
        }
        
        // Get all active services
        log('[DEBUG] Fetching active services...');
        const activeServices = await databases.listDocuments(
            databaseId,
            'active_services',
            [Query.equal('status', 'active'), Query.limit(500)]
        );
        
        log(`[INFO] Found ${activeServices.total} active services`);
        log(`[DEBUG] Active services IDs: ${activeServices.documents.map(s => s.$id).join(', ')}`);
        
        if (activeServices.total === 0) {
            log('[WARN] No active services found, nothing to generate');
            return res.json({
                success: true,
                message: 'No active services found',
                tripsCreated: 0,
            });
        }
        
        let tripsCreated = 0;
        let skipped = 0;
        const errors = [];
        const createdTripIds = [];
        
        for (const service of activeServices.documents) {
            log(`[DEBUG] Processing service: ${service.$id}`);
            log(`[DEBUG] Service details - driverId: ${service.driverId}, childId: ${service.childId}, parentId: ${service.parentId}`);
            
            try {
                // Get child data for pickup/drop locations
                let child;
                try {
                    log(`[DEBUG] Fetching child document: ${service.childId}`);
                    child = await databases.getDocument(databaseId, 'children', service.childId);
                    log(`[DEBUG] Child found: ${child.name}`);
                    log(`[DEBUG] Child pickLocation: ${JSON.stringify(child.pickLocation)}`);
                    log(`[DEBUG] Child dropLocation: ${JSON.stringify(child.dropLocation)}`);
                } catch (e) {
                    log(`[ERROR] Error fetching child ${service.childId}: ${e.message}`);
                    errors.push({ serviceId: service.$id, error: `Child not found: ${e.message}` });
                    continue;
                }
                
                // Validate required locations
                if (!child.pickLocation) {
                    log(`[ERROR] Child ${service.childId} missing pickLocation`);
                    errors.push({ serviceId: service.$id, error: 'Child missing pickLocation' });
                    continue;
                }
                if (!child.dropLocation) {
                    log(`[ERROR] Child ${service.childId} missing dropLocation`);
                    errors.push({ serviceId: service.$id, error: 'Child missing dropLocation' });
                    continue;
                }
                
                // Check if trip already exists for today
                const todayStart = new Date(today);
                todayStart.setHours(0, 0, 0, 0);
                const tomorrowStart = new Date(todayStart);
                tomorrowStart.setDate(tomorrowStart.getDate() + 1);
                
                log(`[DEBUG] Checking for existing trips from ${todayStart.toISOString()} to ${tomorrowStart.toISOString()}`);
                
                const existingTrips = await databases.listDocuments(
                    databaseId,
                    'trips',
                    [
                        Query.equal('activeServiceId', service.$id),
                        Query.equal('tripType', 'morning'),
                        Query.greaterThanEqual('scheduledDate', todayStart.toISOString()),
                        Query.lessThan('scheduledDate', tomorrowStart.toISOString()),
                        Query.limit(1)
                    ]
                );
                
                if (existingTrips.total > 0) {
                    log(`[INFO] Morning trip already exists for service ${service.$id}, trip ID: ${existingTrips.documents[0].$id}`);
                    skipped++;
                    continue;
                }
                
                // Get child's school time windows if available
                const windowStartTime = child.schoolOpenTime || DEFAULT_MORNING_START;
                const windowEndTime = child.schoolOffTime || DEFAULT_MORNING_END;
                
                log(`[DEBUG] Time window: ${windowStartTime} - ${windowEndTime}`);
                
                // Create morning trip (Home → School)
                const tripData = {
                    activeServiceId: service.$id,
                    driverId: service.driverId,
                    childId: service.childId,
                    parentId: service.parentId,
                    tripType: 'morning',
                    tripDirection: 'home_to_school',
                    status: 'scheduled',
                    scheduledDate: today.toISOString(),
                    windowStartTime: windowStartTime,
                    windowEndTime: windowEndTime,
                    pickupLocation: child.pickLocation, // Home (point type)
                    dropLocation: child.dropLocation, // School (point type)
                    liveTrackingEnabled: false,
                    parentConfirmed: false,
                    approachingNotified: false,
                    arrivedNotified: false,
                    pickedNotified: false,
                    droppedNotified: false,
                };
                
                log(`[DEBUG] Creating trip with data: ${JSON.stringify(tripData)}`);
                
                const createdTrip = await databases.createDocument(databaseId, 'trips', ID.unique(), tripData);
                tripsCreated++;
                createdTripIds.push(createdTrip.$id);
                
                log(`[SUCCESS] Created morning trip ${createdTrip.$id} for child ${child.name}`);
                
            } catch (e) {
                error(`[ERROR] Error processing service ${service.$id}: ${e.message}`);
                log(`[DEBUG] Error stack: ${e.stack}`);
                errors.push({ serviceId: service.$id, error: e.message });
            }
        }
        
        log('='.repeat(60));
        log(`[SUMMARY] Morning trip generation complete`);
        log(`[SUMMARY] Created: ${tripsCreated}, Skipped: ${skipped}, Errors: ${errors.length}`);
        log(`[SUMMARY] Created trip IDs: ${createdTripIds.join(', ')}`);
        if (errors.length > 0) {
            log(`[SUMMARY] Error details: ${JSON.stringify(errors)}`);
        }
        log('='.repeat(60));
        
        return res.json({
            success: true,
            tripType: 'morning',
            date: today.toISOString(),
            dayOfWeek: dayOfWeek,
            tripsCreated: tripsCreated,
            createdTripIds: createdTripIds,
            skipped: skipped,
            errors: errors.length,
            errorDetails: errors.slice(0, 10), // Limit error details
        });
        
    } catch (e) {
        error(`[FATAL] Fatal error in generate-morning-trips: ${e.message}`);
        log(`[DEBUG] Fatal error stack: ${e.stack}`);
        return res.json({
            success: false,
            error: e.message,
            stack: e.stack,
        }, 500);
    }
};
