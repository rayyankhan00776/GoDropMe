import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godropme/shared/utils/map_marker_utils.dart';
import 'package:godropme/services/appwrite/trip_service.dart';
import 'package:godropme/services/appwrite/trip_tracking_service.dart';
import 'package:godropme/services/appwrite/auth_service.dart';
import 'package:godropme/services/appwrite/parent_service.dart';
import 'package:godropme/services/appwrite/child_service.dart';
import 'package:godropme/utils/schools_loader.dart';
import 'package:flutter/foundation.dart';

/// Controller for Parent Home/Map screen with real-time trip tracking.
class ParentMapController extends GetxController {
  // Services
  final _tripService = TripService.instance;
  final _trackingService = TripTrackingService.instance;
  final _authService = AuthService.instance;
  final _parentService = ParentService.instance;
  final _childService = ChildService.instance;

  final isMapReady = false.obs;
  final Rxn<Position> currentPosition = Rxn<Position>();
  final isLoadingLocation = false.obs;
  final markers = Rx<Set<Marker>>({});
  final isLoadingMarkers = false.obs;

  // Active trips for parent's children
  final RxList<Map<String, dynamic>> activeTrips = <Map<String, dynamic>>[].obs;
  
  // Currently tracked trip (for single trip view)
  final Rx<Map<String, dynamic>?> currentTrip = Rx<Map<String, dynamic>?>(null);
  
  // Error state
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadActiveTrips();
  }

  @override
  void onClose() {
    _trackingService.unsubscribe();
    super.onClose();
  }

  void setMapReady(bool v) => isMapReady.value = v;

  // ═══════════════════════════════════════════════════════════════════════════
  // BACKEND INTEGRATION - Real-time Trip Tracking
  // ═══════════════════════════════════════════════════════════════════════════

  /// Load active trips for parent's children from backend
  Future<void> loadActiveTrips() async {
    try {
      isLoadingMarkers.value = true;
      error.value = '';

      // Map auth user -> parent document ID
      final user = _authService.currentUser;
      if (user == null) {
        error.value = 'Not authenticated';
        return;
      }

      final parentProfile = await _parentService.getParent(userId: user.$id);
      if (!parentProfile.success || parentProfile.parent?.id == null) {
        error.value = parentProfile.message;
        debugPrint('❌ Parent profile lookup failed for user ${user.$id}: ${error.value}');
        return;
      }

      final String parentId = parentProfile.parent!.id!;
      debugPrint('🔄 Loading trips for parent: $parentId (userId: ${user.$id})');

      // Get today's trips for parent
      final result = await _tripService.getParentTrips(parentId: parentId);

      if (result.success) {
        activeTrips.value = result.trips;
        debugPrint('✅ Loaded ${activeTrips.length} trips');

        // Load markers for all trips
        await _loadMarkersFromTrips();

        // Subscribe to first active trip (driver_enroute, arrived, picked, in_transit)
        final activeTripInProgress = activeTrips.firstWhereOrNull(
          (trip) => ['driver_enroute', 'arrived', 'picked', 'in_transit'].contains(trip['status']),
        );

        if (activeTripInProgress != null) {
          subscribeToTripUpdates(activeTripInProgress['id']);
        }
      } else {
        error.value = result.message ?? 'Failed to load trips';
        debugPrint('❌ Load trips error: ${error.value}');
      }
    } catch (e) {
      error.value = 'Error loading trips: $e';
      debugPrint('❌ Load trips exception: $e');
    } finally {
      isLoadingMarkers.value = false;
    }
  }

  /// Load map markers from trip data
  Future<void> _loadMarkersFromTrips() async {
    try {
      final Set<Marker> newMarkers = {};

      debugPrint('📍 Loading markers for ${activeTrips.length} trips');

      // Load custom marker icons
      final homeIcon = await MapMarkerUtils.getHomeMarker();
      final schoolIcon = await MapMarkerUtils.getSchoolMarker();

      // Load schools data
      final schools = await SchoolsLoader.load();
      debugPrint('📍 Loaded ${schools.length} schools');

      for (var trip in activeTrips) {
        final tripId = trip['id'] as String;
        final childId = trip['childId'] as String;
        final status = trip['status'] as String? ?? 'scheduled';

        debugPrint('📍 Processing trip $tripId for child $childId');

        // Get child details to access home location and school
        final childResult = await _childService.getChild(childId);
        if (!childResult.success || childResult.child == null) {
          debugPrint('⚠️ Could not load child for trip $tripId: ${childResult.message}');
          continue;
        }

        final child = childResult.child!;
        final childName = child.name;
        debugPrint('✅ Loaded child: $childName, schoolId: ${child.schoolId}');

        // Get school details using schoolId
        final school = schools.firstWhereOrNull((s) => s.id == child.schoolId);
        if (school == null) {
          debugPrint('⚠️ Could not find school ${child.schoolId} for child $childName');
          continue;
        }
        debugPrint('✅ Found school: ${school.name} at (${school.lat}, ${school.lng})');

        // Add pickup location marker (child's home)
        final pickupLocation = child.pickLocation; // [lng, lat]
        if (pickupLocation != null && pickupLocation.length == 2) {
          final pickupLatLng = LatLng(
            pickupLocation[1], // lat
            pickupLocation[0], // lng
          );
          debugPrint('✅ Adding pickup marker at $pickupLatLng');

          newMarkers.add(
            Marker(
              markerId: MarkerId('pickup_$tripId'),
              position: pickupLatLng,
              icon: homeIcon,
              infoWindow: InfoWindow(
                title: 'Home - $childName',
                snippet: 'Pickup Location',
              ),
            ),
          );
        } else {
          debugPrint('⚠️ No pickup location for child $childName');
        }

        // Add dropoff location marker (school)
        final schoolLatLng = LatLng(school.lat, school.lng);
        debugPrint('✅ Adding school marker at $schoolLatLng');
        newMarkers.add(
          Marker(
            markerId: MarkerId('dropoff_$tripId'),
            position: schoolLatLng,
            icon: schoolIcon,
            infoWindow: InfoWindow(
              title: school.name,
              snippet: 'Drop-off Location',
            ),
          ),
        );

        // Get current driver location if trip is active (Appwrite point format: [lng, lat])
        if (['driver_enroute', 'arrived', 'picked', 'in_transit'].contains(status)) {
          final driverLocation = trip['currentDriverLocation'];
          if (driverLocation is List && driverLocation.length == 2) {
            final driverLatLng = LatLng(
              (driverLocation[1] as num).toDouble(), // lat
              (driverLocation[0] as num).toDouble(), // lng
            );

            // Get vehicle type for appropriate icon
            final vehicleType = trip['vehicleType'] as String? ?? 'Car';
            final driverIcon = await MapMarkerUtils.getDriverMarker(vehicleType);
            final driverName = trip['driverName'] as String? ?? 'Driver';

            newMarkers.add(
              Marker(
                markerId: MarkerId('driver_$tripId'),
                position: driverLatLng,
                icon: driverIcon,
                infoWindow: InfoWindow(
                  title: driverName,
                  snippet: _getStatusMessage(status),
                ),
              ),
            );
          }
        }
      }

      markers.value = newMarkers;
      debugPrint('✅ Added ${newMarkers.length} total markers to parent map');
      
      // Fit map to show all markers
      if (newMarkers.isNotEmpty) {
        _fitMarkersOnMap(newMarkers);
      }
    } catch (e) {
      debugPrint('❌ Load markers error: $e');
    }
  }

  /// Subscribe to real-time trip updates
  void subscribeToTripUpdates(String tripId) {
    debugPrint('📍 Subscribing to trip updates: $tripId');
    
    _trackingService.subscribeToTrip(
      tripId: tripId,
      onLocationUpdate: (location, status) {
        debugPrint('📍 Driver location update: $location, status: $status');
        updateDriverMarker(tripId, location, status);
      },
      onStatusChange: (status) {
        debugPrint('📍 Trip status changed: $status');
        updateTripStatus(tripId, status);
      },
      onTripCompleted: () {
        debugPrint('📍 Trip completed');
        loadActiveTrips(); // Reload trips to update UI
      },
    );

    // Store current tracked trip
    currentTrip.value = activeTrips.firstWhereOrNull((trip) => trip['id'] == tripId);
  }

  /// Update driver marker on map with new location
  void updateDriverMarker(String tripId, LatLng location, String status) async {
    try {
      final trip = activeTrips.firstWhereOrNull((t) => t['id'] == tripId);
      if (trip == null) return;

      final vehicleType = trip['vehicleType'] as String? ?? 'Car';
      final driverIcon = await MapMarkerUtils.getDriverMarker(vehicleType);
      final driverName = trip['driverName'] as String? ?? 'Driver';

      final updatedMarkers = Set<Marker>.from(markers.value);
      
      // Remove old driver marker
      updatedMarkers.removeWhere((m) => m.markerId.value == 'driver_$tripId');
      
      // Add updated driver marker
      updatedMarkers.add(
        Marker(
          markerId: MarkerId('driver_$tripId'),
          position: location,
          icon: driverIcon,
          infoWindow: InfoWindow(
            title: driverName,
            snippet: _getStatusMessage(status),
          ),
        ),
      );

      markers.value = updatedMarkers;
    } catch (e) {
      debugPrint('❌ Update driver marker error: $e');
    }
  }

  /// Update trip status in local state
  void updateTripStatus(String tripId, String status) {
    final tripIndex = activeTrips.indexWhere((t) => t['id'] == tripId);
    if (tripIndex != -1) {
      activeTrips[tripIndex]['status'] = status;
      activeTrips.refresh();
      
      // Update current trip if it's the tracked one
      if (currentTrip.value?['id'] == tripId) {
        currentTrip.value = activeTrips[tripIndex];
      }
    }
  }

  /// Get user-friendly status message
  String _getStatusMessage(String status) {
    switch (status) {
      case 'scheduled':
        return 'Scheduled';
      case 'driver_enroute':
        return 'On the way to pickup';
      case 'arrived':
        return 'Arrived at pickup';
      case 'picked':
        return 'Child picked up';
      case 'in_transit':
        return 'Going to school';
      case 'dropped':
        return 'Dropped at school';
      case 'cancelled':
        return 'Cancelled';
      case 'absent':
        return 'Child absent';
      default:
        return status;
    }
  }

  /// Fit map camera to show all markers
  void _fitMarkersOnMap(Set<Marker> markersSet) async {
    if (markersSet.isEmpty) return;

    // Calculate bounds
    double minLat = markersSet.first.position.latitude;
    double maxLat = markersSet.first.position.latitude;
    double minLng = markersSet.first.position.longitude;
    double maxLng = markersSet.first.position.longitude;

    for (var marker in markersSet) {
      if (marker.position.latitude < minLat) minLat = marker.position.latitude;
      if (marker.position.latitude > maxLat) maxLat = marker.position.latitude;
      if (marker.position.longitude < minLng) minLng = marker.position.longitude;
      if (marker.position.longitude > maxLng) maxLng = marker.position.longitude;
    }

    // Note: In the UI layer, you should get the GoogleMapController and call:
    // mapController?.animateCamera(CameraUpdate.newLatLngBounds(
    //   LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng)),
    //   100, // padding
    // ));
    
    debugPrint('📍 Map bounds calculated: ($minLat, $minLng) to ($maxLat, $maxLng)');
  }

  /// Refresh markers (reload trips from backend)
  Future<void> refreshMarkers() async {
    await loadActiveTrips();
  }

  /// Get the user's current location
  Future<Position?> getCurrentLocation() async {
    try {
      isLoadingLocation.value = true;
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Location Services Disabled',
          'Please enable location services',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Permission Denied',
            'Location permission is required',
            snackPosition: SnackPosition.BOTTOM,
          );
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Permission Denied',
          'Please enable location permission in settings',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      currentPosition.value = position;
      return position;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get location: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isLoadingLocation.value = false;
    }
  }

  /// Convert Position to LatLng
  LatLng? get currentLatLng {
    final pos = currentPosition.value;
    if (pos == null) return null;
    return LatLng(pos.latitude, pos.longitude);
  }
}
