import { Client, TablesDB, ID, Query } from 'node-appwrite';
/**
 * Generate Afternoon Trips - Appwrite Function
 * 
 * Trigger: CRON (Daily at 11:00 AM PKT - `0 6 * * *` UTC)
 * Purpose: Create AFTERNOON trip records from active services
 * 
 * Afternoon trips = School → Home
 * - pickupLocation = school (dropLocation from children table)
 * - dropLocation = child's home (pickLocation from children table)
 * 
 * IMPORTANT: Skips generating afternoon trip if morning trip was marked 'absent'
 * 
 * NOTE: Uses TablesDB API (not the old Databases API)
 */

// Default operating days (Mon-Sat, skip Sunday)
const DEFAULT_OPERATING_DAYS = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];

// Default time windows for trips (PKT - Pakistan Standard Time)
const DEFAULT_AFTERNOON_START = '11:00 AM';
const DEFAULT_AFTERNOON_END = '3:00 PM';

export default async ({ req, res, log, error }) => {
    log('='.repeat(60));
    log('[generate-afternoon-trips] Function started');
    log(`[DEBUG] Execution time: ${new Date().toISOString()}`);
    
    // Initialize Appwrite client
    const client = new Client()
        .setEndpoint(process.env.APPWRITE_ENDPOINT || 'https://fra.cloud.appwrite.io/v1')
        .setProject(process.env.APPWRITE_FUNCTION_PROJECT_ID)
        .setKey(process.env.APPWRITE_API_KEY);
    
    // Use TablesDB instead of Databases
    const tablesDB = new TablesDB(client);
    const databaseId = 'godropme_db';
    
    log(`[DEBUG] Database ID: ${databaseId}`);
    log(`[DEBUG] Project ID: ${process.env.APPWRITE_FUNCTION_PROJECT_ID}`);
    
    try {
        const today = new Date();
        const dayOfWeek = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'][today.getDay()];
        
        log(`[INFO] Generating afternoon trips for ${today.toDateString()} (${dayOfWeek})`);
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
        
        // Get all active services using TablesDB
        log('[DEBUG] Fetching active services...');
        const activeServices = await tablesDB.listRows({
            databaseId: databaseId,
            tableId: 'active_services',
            queries: [Query.equal('status', 'active'), Query.limit(500)]
        });
        
        log(`[INFO] Found ${activeServices.total} active services`);
        log(`[DEBUG] Active services IDs: ${activeServices.rows.map(s => s.$id).join(', ')}`);
        
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
        
        let absentSkipped = 0;
        
        for (const service of activeServices.rows) {
            log(`[DEBUG] Processing service: ${service.$id}`);
            log(`[DEBUG] Service details - driverId: ${service.driverId}, childId: ${service.childId}, parentId: ${service.parentId}`);
            
            try {
                // Get child data for pickup/drop locations
                let child;
                try {
                    log(`[DEBUG] Fetching child row: ${service.childId}`);
                    child = await tablesDB.getRow({
                        databaseId: databaseId,
                        tableId: 'children',
                        rowId: service.childId
                    });
                    log(`[DEBUG] Child found: ${child.name}`);
                    log(`[DEBUG] Child pickLocation (Home): ${JSON.stringify(child.pickLocation)}`);
                    log(`[DEBUG] Child dropLocation (School): ${JSON.stringify(child.dropLocation)}`);
                } catch (e) {
                    log(`[ERROR] Error fetching child ${service.childId}: ${e.message}`);
                    errors.push({ serviceId: service.$id, error: `Child not found: ${e.message}` });
                    continue;
                }
                
                // Validate required locations
                if (!child.pickLocation) {
                    log(`[ERROR] Child ${service.childId} missing pickLocation (Home)`);
                    errors.push({ serviceId: service.$id, error: 'Child missing pickLocation' });
                    continue;
                }
                if (!child.dropLocation) {
                    log(`[ERROR] Child ${service.childId} missing dropLocation (School)`);
                    errors.push({ serviceId: service.$id, error: 'Child missing dropLocation' });
                    continue;
                }
                
                // Check if trip already exists for today
                const todayStart = new Date(today);
                todayStart.setHours(0, 0, 0, 0);
                const tomorrowStart = new Date(todayStart);
                tomorrowStart.setDate(tomorrowStart.getDate() + 1);
                
                log(`[DEBUG] Checking for existing trips from ${todayStart.toISOString()} to ${tomorrowStart.toISOString()}`);
                
                // FIRST: Check if morning trip was marked absent - skip afternoon if so
                const morningTrips = await tablesDB.listRows({
                    databaseId: databaseId,
                    tableId: 'trips',
                    queries: [
                        Query.equal('activeServiceId', service.$id),
                        Query.equal('tripType', 'morning'),
                        Query.equal('status', 'absent'),
                        Query.greaterThanEqual('scheduledDate', todayStart.toISOString()),
                        Query.lessThan('scheduledDate', tomorrowStart.toISOString()),
                        Query.limit(1)
                    ]
                });
                
                if (morningTrips.total > 0) {
                    log(`[INFO] Morning trip marked absent for service ${service.$id} - skipping afternoon trip`);
                    absentSkipped++;
                    continue;
                }
                
                // Check if afternoon trip already exists for today
                const existingTrips = await tablesDB.listRows({
                    databaseId: databaseId,
                    tableId: 'trips',
                    queries: [
                        Query.equal('activeServiceId', service.$id),
                        Query.equal('tripType', 'afternoon'),
                        Query.greaterThanEqual('scheduledDate', todayStart.toISOString()),
                        Query.lessThan('scheduledDate', tomorrowStart.toISOString()),
                        Query.limit(1)
                    ]
                });
                
                if (existingTrips.total > 0) {
                    log(`[INFO] Afternoon trip already exists for service ${service.$id}, trip ID: ${existingTrips.rows[0].$id}`);
                    skipped++;
                    continue;
                }
                
                // Use default time windows for afternoon trips (PKT)
                const windowStartTime = DEFAULT_AFTERNOON_START;
                const windowEndTime = DEFAULT_AFTERNOON_END;
                
                log(`[DEBUG] Time window (PKT): ${windowStartTime} - ${windowEndTime}`);
                
                // Create afternoon trip (School → Home)
                // Note: Locations are SWAPPED compared to morning
                const tripData = {
                    activeServiceId: service.$id,
                    driverId: service.driverId,
                    childId: service.childId,
                    parentId: service.parentId,
                    tripType: 'afternoon',
                    tripDirection: 'school_to_home',
                    status: 'scheduled',
                    scheduledDate: today.toISOString(),
                    windowStartTime: windowStartTime,
                    windowEndTime: windowEndTime,
                    pickupLocation: child.dropLocation, // School (reverse of morning) - point type
                    dropLocation: child.pickLocation, // Home (reverse of morning) - point type
                    liveTrackingEnabled: false,
                    parentConfirmed: false,
                    approachingNotified: false,
                    arrivedNotified: false,
                    pickedNotified: false,
                    droppedNotified: false,
                };
                
                log(`[DEBUG] Creating trip with data: ${JSON.stringify(tripData)}`);
                
                const createdTrip = await tablesDB.createRow({
                    databaseId: databaseId,
                    tableId: 'trips',
                    rowId: ID.unique(),
                    data: tripData
                });
                tripsCreated++;
                createdTripIds.push(createdTrip.$id);
                
                log(`[SUCCESS] Created afternoon trip ${createdTrip.$id} for child ${child.name}`);
                
            } catch (e) {
                error(`[ERROR] Error processing service ${service.$id}: ${e.message}`);
                log(`[DEBUG] Error stack: ${e.stack}`);
                errors.push({ serviceId: service.$id, error: e.message });
            }
        }
        
        log('='.repeat(60));
        log(`[SUMMARY] Afternoon trip generation complete`);
        log(`[SUMMARY] Created: ${tripsCreated}, Skipped (existing): ${skipped}, Skipped (absent): ${absentSkipped}, Errors: ${errors.length}`);
        log(`[SUMMARY] Created trip IDs: ${createdTripIds.join(', ')}`);
        if (errors.length > 0) {
            log(`[SUMMARY] Error details: ${JSON.stringify(errors)}`);
        }
        log('='.repeat(60));
        
        return res.json({
            success: true,
            tripType: 'afternoon',
            date: today.toISOString(),
            dayOfWeek: dayOfWeek,
            tripsCreated: tripsCreated,
            createdTripIds: createdTripIds,
            skipped: skipped,
            skippedDueToAbsent: absentSkipped,
            errors: errors.length,
            errorDetails: errors.slice(0, 10),
        });
        
    } catch (e) {
        error(`[FATAL] Fatal error in generate-afternoon-trips: ${e.message}`);
        log(`[DEBUG] Fatal error stack: ${e.stack}`);
        return res.json({
            success: false,
            error: e.message,
            stack: e.stack,
        }, 500);
    }
};