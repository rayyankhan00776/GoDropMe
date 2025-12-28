import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godropme/shared/utils/map_marker_utils.dart';
import 'package:godropme/features/DriverSide/driverHome/models/driver_map.dart';
import 'package:godropme/services/appwrite/active_service_service.dart';
import 'package:godropme/services/appwrite/child_service.dart';
import 'package:godropme/services/appwrite/auth_service.dart';
import 'package:godropme/services/appwrite/driver_service.dart';
import 'package:godropme/utils/schools_loader.dart';
import 'package:flutter/foundation.dart';

class DriverHomeController extends GetxController {
  // Services
  final _activeServiceService = ActiveServiceService.instance;
  final _childService = ChildService.instance;
  final _authService = AuthService.instance;
  final _driverService = DriverService.instance;

  final isOnline = false.obs;
  final markers = Rx<Set<Marker>>({});
  final isLoadingMarkers = false.obs;
  final children = <ChildPickup>[].obs;
  
  // Active services from backend
  final RxList<Map<String, dynamic>> activeServices = <Map<String, dynamic>>[].obs;
  
  // Error state
  final RxString error = ''.obs;
  
  // Cached driver icon for location updates
  BitmapDescriptor? driverIcon;
  
  // Driver's vehicle type - will come from user profile
  final vehicleType = 'Car'.obs;

  @override
  void onInit() {
    super.onInit();
    loadActiveServices();
  }

  void toggleOnline(bool v) => isOnline.value = v;

  // ═══════════════════════════════════════════════════════════════════════════
  // BACKEND INTEGRATION - Real Active Services
  // ═══════════════════════════════════════════════════════════════════════════

  /// Load active services for driver from backend
  Future<void> loadActiveServices() async {
    try {
      isLoadingMarkers.value = true;
      error.value = '';

      // Get driver ID from auth service
      final user = _authService.currentUser;
      if (user == null) {
        error.value = 'Not authenticated';
        return;
      }

      // Map auth user -> driver document ID
      final driverProfile = await _driverService.getDriver(userId: user.$id);
      if (!driverProfile.success || driverProfile.driverId == null) {
        error.value = driverProfile.message;
        debugPrint('❌ Driver profile lookup failed for user ${user.$id}: ${error.value}');
        return;
      }

      final String driverId = driverProfile.driverId!;
      debugPrint('🔄 Loading active services for driver: $driverId (userId: ${user.$id})');

      // Get active services from backend
      final result = await _activeServiceService.getDriverActiveServices(
        driverId: driverId,
      );

      if (result.success) {
        activeServices.value = result.services;
        debugPrint('✅ Loaded ${activeServices.length} active services');

        // Load children details for each service
        await _loadChildrenFromServices();
        
        // Load markers after children are loaded
        await _loadMarkers();
      } else {
        error.value = result.message ?? 'Failed to load active services';
        debugPrint('❌ Load active services error: ${error.value}');
      }
    } catch (e) {
      error.value = 'Error loading active services: $e';
      debugPrint('❌ Load active services exception: $e');
    } finally {
      isLoadingMarkers.value = false;
    }
  }

  /// Load children details from active services
  Future<void> _loadChildrenFromServices() async {
    final List<ChildPickup> childrenList = [];

    debugPrint('📍 Loading children from ${activeServices.length} active services');

    for (var service in activeServices) {
      try {
        final childId = service['childId'] as String;
        debugPrint('📍 Loading child: $childId');
        
        // Get child details
        final childResult = await _childService.getChild(childId);
        
        if (childResult.success && childResult.child != null) {
          final child = childResult.child!;
          debugPrint('✅ Loaded child: ${child.name}, schoolId: ${child.schoolId}');
          
          // Get school details
          final school = await SchoolsLoader.getById(child.schoolId);

          if (school != null) {
            debugPrint('✅ Found school: ${school.name} at (${school.lat}, ${school.lng})');
            
            // Get locations from child model
            final homeLocation = child.pickLocation; // [lng, lat]

            if (homeLocation != null && homeLocation.length == 2) {
              final homeLat = homeLocation[1];
              final homeLng = homeLocation[0];
              debugPrint('✅ Home location: ($homeLat, $homeLng)');
              
              childrenList.add(
                ChildPickup(
                  id: childId,
                  name: child.name,
                  homeLocation: LatLng(homeLat, homeLng),
                  schoolLocation: LatLng(school.lat, school.lng),
                  schoolName: school.name,
                ),
              );
            } else {
              debugPrint('⚠️ No home location for child ${child.name}');
            }
          } else {
            debugPrint('⚠️ School not found: ${child.schoolId}');
          }
        } else {
          debugPrint('⚠️ Failed to load child $childId: ${childResult.message}');
        }
      } catch (e) {
        debugPrint('❌ Error loading child details: $e');
      }
    }

    children.value = childrenList;
    debugPrint('✅ Loaded ${children.length} children with locations');
  }

  /// Load markers for all children
  Future<void> _loadMarkers() async {
    try {
      isLoadingMarkers.value = true;

      debugPrint('📍 Loading markers for ${children.length} children');

      // Load custom marker icons
      final homeIcon = await MapMarkerUtils.getHomeMarker();
      final schoolIcon = await MapMarkerUtils.getSchoolMarker();
      driverIcon = await MapMarkerUtils.getDriverMarker(vehicleType.value);

      final Set<Marker> newMarkers = {};

      // Add markers for each child's home
      for (final child in children) {
        debugPrint('📍 Adding home marker for ${child.name} at ${child.homeLocation}');
        newMarkers.add(
          Marker(
            markerId: MarkerId('home_${child.id}'),
            position: child.homeLocation,
            icon: homeIcon,
            infoWindow: InfoWindow(
              title: "${child.name}'s Home",
              snippet: 'Pickup point',
            ),
          ),
        );
      }

      // Add school markers (unique schools only)
      final uniqueSchools = <String, ChildPickup>{};
      for (final child in children) {
        uniqueSchools[child.schoolName] = child;
      }

      int schoolIndex = 0;
      for (final entry in uniqueSchools.entries) {
        debugPrint('📍 Adding school marker for ${entry.key} at ${entry.value.schoolLocation}');
        newMarkers.add(
          Marker(
            markerId: MarkerId('school_$schoolIndex'),
            position: entry.value.schoolLocation,
            icon: schoolIcon,
            infoWindow: InfoWindow(
              title: entry.key,
              snippet: 'Drop-off point',
            ),
          ),
        );
        schoolIndex++;
      }

      markers.value = newMarkers;
      debugPrint('✅ Added ${newMarkers.length} markers to map');
    } catch (e) {
      debugPrint('❌ Error loading markers: $e');
      // Fallback to default markers if custom icons fail
      _loadDefaultMarkers();
    } finally {
      isLoadingMarkers.value = false;
    }
  }

  /// Fallback to default markers
  void _loadDefaultMarkers() {
    final Set<Marker> newMarkers = {};

    for (final child in children) {
      newMarkers.add(
        Marker(
          markerId: MarkerId('home_${child.id}'),
          position: child.homeLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: "${child.name}'s Home",
            snippet: 'Pickup point',
          ),
        ),
      );
    }

    final uniqueSchools = <String, ChildPickup>{};
    for (final child in children) {
      uniqueSchools[child.schoolName] = child;
    }

    int schoolIndex = 0;
    for (final entry in uniqueSchools.entries) {
      newMarkers.add(
        Marker(
          markerId: MarkerId('school_$schoolIndex'),
          position: entry.value.schoolLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: entry.key,
            snippet: 'Drop-off point',
          ),
        ),
      );
      schoolIndex++;
    }

    markers.value = newMarkers;
  }

  /// Refresh markers (useful for real-time updates)
  Future<void> refreshMarkers() async {
    await loadActiveServices();
  }

  /// Add driver's current location marker
  void updateDriverLocation(LatLng position) {
    final currentMarkers = Set<Marker>.from(markers.value);
    currentMarkers.removeWhere((m) => m.markerId == const MarkerId('me'));
    currentMarkers.add(
      Marker(
        markerId: const MarkerId('me'),
        position: position,
        icon: driverIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'You are here'),
      ),
    );
    markers.value = currentMarkers;
  }
}
