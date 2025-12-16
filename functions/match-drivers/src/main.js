/**
 * Appwrite Function: match-drivers
 * 
 * Matches available drivers for a child based on:
 * 1. Service area (geo-query: polygon contains child's pickup point)
 * 2. School (driver serves the child's school)
 * 3. Service category (gender matching or "Both")
 * 4. Driver status (only active drivers)
 * 
 * Request Body:
 * {
 *   "childId": "child_id",
 *   "pickupPoint": [lng, lat],
 *   "schoolId": "school_id",
 *   "gender": "Male" | "Female"
 * }
 * 
 * Response:
 * {
 *   "success": true,
 *   "drivers": [...],
 *   "count": 5
 * }
 */

// Helper function: Point-in-polygon check using ray casting algorithm
function isPointInPolygon(point, polygon) {
  const [x, y] = point;
  let inside = false;
  
  for (let i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    const [xi, yi] = polygon[i];
    const [xj, yj] = polygon[j];
    
    const intersect = ((yi > y) !== (yj > y)) &&
      (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
    
    if (intersect) inside = !inside;
  }
  
  return inside;
}

export default async ({ req, res, log, error }) => {
  try {
    // Parse request body
    const body = typeof req.body === 'string' ? JSON.parse(req.body) : req.body;
    
    const { childId, pickupPoint, schoolId, gender } = body;

    // Validate required fields
    if (!pickupPoint || !Array.isArray(pickupPoint) || pickupPoint.length !== 2) {
      return res.json({
        success: false,
        message: 'Invalid or missing pickupPoint. Expected [lng, lat] array.',
      }, 400);
    }

    if (!schoolId || typeof schoolId !== 'string') {
      return res.json({
        success: false,
        message: 'Missing or invalid schoolId.',
      }, 400);
    }

    if (!gender || !['Male', 'Female'].includes(gender)) {
      return res.json({
        success: false,
        message: 'Invalid gender. Expected "Male" or "Female".',
      }, 400);
    }

    log(`🔍 Matching drivers for child ${childId || 'unknown'}`);
    log(`   Pickup: ${JSON.stringify(pickupPoint)}`);
    log(`   School: ${schoolId}`);
    log(`   Gender: ${gender}`);

    // Appwrite configuration
    const endpoint = process.env.APPWRITE_FUNCTION_API_ENDPOINT;
    const projectId = process.env.APPWRITE_FUNCTION_PROJECT_ID;
    // Use custom API key if provided, otherwise use system-generated key
    const apiKey = process.env.CUSTOM_API_KEY || process.env.APPWRITE_API_KEY;
    const databaseId = 'godropme_db';
    const driverServicesTable = 'driver_services';
    const driversTable = 'drivers';
    const usersTable = 'users';

    log(`🔧 Config: endpoint=${endpoint}, project=${projectId}, usingCustomKey=${!!process.env.CUSTOM_API_KEY}, hasKey=${!!apiKey}`);

    // Helper function to call Appwrite REST API
    // Using collections API which is compatible with TablesDB in Appwrite Cloud
    const listRows = async (tableId, queries = []) => {
      const url = new URL(`${endpoint}/databases/${databaseId}/collections/${tableId}/documents`);
      // Queries are passed as-is, not as strings
      queries.forEach(q => url.searchParams.append('queries[]', q));
      
      log(`📡 Calling: ${url.toString()}`);
      log(`📡 Headers: Project=${projectId}, Key=${apiKey ? apiKey.substring(0, 10) + '...' : 'missing'}`);
      
      const response = await fetch(url.toString(), {
        method: 'GET',
        headers: {
          'x-appwrite-project': projectId,
          'x-appwrite-key': apiKey,
          'content-type': 'application/json',
        },
      });
      
      log(`📡 Response: ${response.status} ${response.statusText}`);
      
      if (!response.ok) {
        const errorText = await response.text();
        log(`❌ Error response: ${errorText}`);
        throw new Error(`API Error: ${response.status} - ${errorText}`);
      }
      
      const result = await response.json();
      // Return in format compatible with our code (using 'rows' key)
      return {
        total: result.total,
        rows: result.documents || [],
      };
    };

    // Step 1: Fetch all driver_services
    // NOTE: REST API queries are problematic, so we'll fetch all and filter in code
    log('📍 Fetching all driver services...');
    
    const serviceQueries = []; // No queries - fetch all

    log(`🔍 Queries: ${JSON.stringify(serviceQueries)}`);

    const servicesResult = await listRows(driverServicesTable, serviceQueries);

    log(`✅ Found ${servicesResult.total} driver services total`);

    if (servicesResult.total === 0) {
      return res.json({
        success: true,
        drivers: [],
        count: 0,
        message: 'No driver services available.',
      });
    }

    // Step 1a: Filter by school in code
    log(`🏫 Filtering by school: ${schoolId}`);
    
    const schoolFilteredServices = servicesResult.rows.filter(service => {
      const schools = service.schoolIds;
      return Array.isArray(schools) && schools.includes(schoolId);
    });

    log(`🎓 ${schoolFilteredServices.length} services after school filter`);

    if (schoolFilteredServices.length === 0) {
      return res.json({
        success: true,
        drivers: [],
        count: 0,
        message: 'No drivers found serving this school.',
      });
    }

    // Step 1b: Filter by geo-location (client-side since REST API doesn't support geo-queries)
    log('🗺️ Filtering by service area...');
    
    const geoFilteredServices = schoolFilteredServices.filter(service => {
      const polygon = service.serviceAreaPolygon;
      
      // serviceAreaPolygon is in GeoJSON format: [[[lng,lat], ...]]
      // We need the coordinate array (the middle level)
      if (!polygon || !Array.isArray(polygon) || polygon.length === 0) {
        log(`⚠️ Service ${service.$id}: No polygon data`);
        return false;
      }
      
      // Extract coordinates from GeoJSON format
      // polygon[0] is the exterior ring (array of [lng,lat] points)
      const coordinates = Array.isArray(polygon[0]) && Array.isArray(polygon[0][0]) 
        ? polygon[0] 
        : polygon;
      
      if (!Array.isArray(coordinates) || coordinates.length < 3) {
        log(`⚠️ Service ${service.$id}: Invalid polygon coordinates`);
        return false;
      }
      
      log(`🔍 Checking service ${service.$id}: polygon has ${coordinates.length} points`);
      
      // Point-in-polygon check
      const isInside = isPointInPolygon(pickupPoint, coordinates);
      log(`${isInside ? '✅' : '❌'} Pickup ${JSON.stringify(pickupPoint)} ${isInside ? 'inside' : 'outside'} polygon`);
      
      return isInside;
    });

    log(`🎯 ${geoFilteredServices.length} services after geo-filter`);

    if (geoFilteredServices.length === 0) {
      return res.json({
        success: true,
        drivers: [],
        count: 0,
        message: 'No drivers found in this area.',
      });
    }

    // Step 2: Filter by service category (gender matching)
    const matchingServices = geoFilteredServices.filter(service => {
      const category = service.serviceCategory;
      return category === 'Both' || category === gender;
    });

    log(`🎯 ${matchingServices.length} services after gender filter`);

    if (matchingServices.length === 0) {
      return res.json({
        success: true,
        drivers: [],
        count: 0,
        message: 'No drivers found matching gender preference.',
      });
    }

    // Step 3: Fetch driver details for each matching service
    const driverIds = matchingServices.map(s => s.driverId);
    log(`👤 Fetching details for ${driverIds.length} drivers...`);

    // Fetch all drivers (no queries work via REST API)
    const driversResult = await listRows(driversTable, []);
    
    // Filter to only the drivers we need
    const filteredDrivers = driversResult.rows.filter(driver => 
      driverIds.includes(driver.$id)
    );
    
    log(`✅ Found ${filteredDrivers.length} matching drivers out of ${driversResult.rows.length} total`);

    // Map driver IDs to driver documents
    const driverMap = {};
    filteredDrivers.forEach(driver => {
      driverMap[driver.$id] = driver;
      log(`📝 Driver ${driver.$id}: vehicleId=${driver.vehicleId || 'none'}`);
    });

    // Step 4: Fetch user status for each driver (only active drivers)
    const userIds = filteredDrivers.map(d => d.userId);
    log(`👥 Fetching user status for ${userIds.length} users...`);
    
    // Fetch all users (no queries work via REST API)
    const usersResult = await listRows(usersTable, []);
    
    // Filter to only active users we need
    const activeUserIds = new Set(
      usersResult.rows
        .filter(user => userIds.includes(user.$id) && user.status === 'active')
        .map(u => u.$id)
    );
    
    log(`✅ ${activeUserIds.size} active drivers found`);

    // Helper to get a single row by ID
    const getRow = async (tableId, rowId) => {
      const url = `${endpoint}/databases/${databaseId}/collections/${tableId}/documents/${rowId}`;
      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'x-appwrite-project': projectId,
          'x-appwrite-key': apiKey,
          'content-type': 'application/json',
        },
      });
      
      if (!response.ok) {
        throw new Error(`API Error: ${response.status}`);
      }
      
      return await response.json();
    };

    // Fetch all schools for name lookup
    log('🏫 Fetching schools...');
    const schoolsTable = 'schools';
    const schoolsResult = await listRows(schoolsTable, []);
    const schoolsMap = {};
    schoolsResult.rows.forEach(school => {
      schoolsMap[school.$id] = school.name;
    });
    log(`✅ Loaded ${schoolsResult.rows.length} schools`);

    // Fetch all vehicles for seat availability
    log('🚗 Fetching vehicles...');
    const vehiclesTable = 'vehicles';
    const vehiclesResult = await listRows(vehiclesTable, []);
    const vehiclesByDriverId = {};
    vehiclesResult.rows.forEach(vehicle => {
      vehiclesByDriverId[vehicle.driverId] = vehicle;
      log(`🚗 Vehicle ${vehicle.$id}: driverId=${vehicle.driverId}, ${vehicle.brand || 'unknown'} ${vehicle.model || 'unknown'}, seats=${vehicle.seatCapacity || 0}`);
    });
    log(`✅ Loaded ${vehiclesResult.rows.length} vehicles`);

    // Step 5: Build final driver listings with all data
    const drivers = [];

    for (const service of matchingServices) {
      const driver = driverMap[service.driverId];
      if (!driver) continue;

      // Skip if driver is not active
      if (!activeUserIds.has(driver.userId)) {
        log(`⚠️ Skipping driver ${driver.$id} - not active`);
        continue;
      }

      // Get vehicle data using driverId
      const vehicle = vehiclesByDriverId[driver.$id];
      
      if (!vehicle) {
        log(`⚠️ No vehicle found for driver ${driver.$id}`);
      } else {
        log(`✅ Found vehicle for driver ${driver.$id}: ${vehicle.brand} ${vehicle.model}`);
      }
      
      // Get school names from schoolIds array
      const schoolNames = (service.schoolIds || [])
        .map(id => schoolsMap[id])
        .filter(name => name) // Remove undefined
        .join(', ');

      // Calculate available seats (total capacity - already occupied)
      // Note: You may need to track occupied seats in driver_services table
      const totalSeats = vehicle?.seatCapacity || 0;
      const occupiedSeats = service.occupiedSeats || 0;
      const availableSeats = Math.max(0, totalSeats - occupiedSeats);
      
      log(`🪑 Seats: total=${totalSeats}, occupied=${occupiedSeats}, available=${availableSeats}`);

      // Build driver listing
      drivers.push({
        driverId: driver.$id,
        name: driver.fullName || 'Driver',
        profilePhotoUrl: driver.profilePhotoUrl || null,
        rating: driver.rating || 0.0,
        totalTrips: driver.totalTrips || 0,
        phone: driver.phone,
        
        // Vehicle info
        vehicle: vehicle ? {
          type: vehicle.vehicleType || 'car',
          brand: vehicle.brand,
          model: vehicle.model,
          color: vehicle.color,
          seatCapacity: vehicle.seatCapacity,
          numberPlate: vehicle.numberPlate,
        } : null,
        
        // Service details
        serviceCategory: service.serviceCategory,
        monthlyPricePkr: service.monthlyPricePkr,
        serviceAreaAddress: service.serviceAreaAddress,
        schoolNames: schoolNames, // Comma-separated school names
        availableSeats: availableSeats, // Calculated available seats
        extraNotes: service.extraNotes,
        
        // Metadata
        serviceId: service.$id,
      });
    }

    log(`🎉 Returning ${drivers.length} matched drivers`);
    
    // Log first driver details for debugging
    if (drivers.length > 0) {
      const firstDriver = drivers[0];
      log(`📋 Sample driver: ${firstDriver.name}`);
      log(`   - Photo: ${firstDriver.profilePhotoUrl || 'none'}`);
      log(`   - Rating: ${firstDriver.rating}`);
      log(`   - Vehicle: ${firstDriver.vehicle ? `${firstDriver.vehicle.brand} ${firstDriver.vehicle.model}` : 'none'}`);
      log(`   - Schools: ${firstDriver.schoolNames}`);
      log(`   - Available seats: ${firstDriver.availableSeats}`);
    }

    return res.json({
      success: true,
      drivers: drivers,
      count: drivers.length,
      message: `Found ${drivers.length} available drivers.`,
    });

  } catch (err) {
    error('❌ Function error:', err);
    return res.json({
      success: false,
      message: err.message || 'An error occurred while matching drivers.',
      error: process.env.APPWRITE_FUNCTION_PROJECT_ID ? err.message : err.toString(),
    }, 500);
  }
};
