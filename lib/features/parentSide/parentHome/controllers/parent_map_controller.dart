import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godropme/shared/utils/map_marker_utils.dart';

/// Controller for Parent Home/Map screen with location services.
class ParentMapController extends GetxController {
  final isMapReady = false.obs;
  final Rxn<Position> currentPosition = Rxn<Position>();
  final isLoadingLocation = false.obs;
  final markers = Rx<Set<Marker>>({});
  final isLoadingMarkers = false.obs;

  // Demo data for parent map - in production, this would come from backend
  // Home location (parent's registered address)
  final LatLng demoHomeLocation = const LatLng(34.0051, 71.5349);
  
  // School location (child's school)
  final LatLng demoSchoolLocation = const LatLng(34.0151, 71.5449);
  final String demoSchoolName = 'Allied School (Town Campus)';
  
  // Driver location during trip (simulated position between home and school)
  final LatLng demoDriverLocation = const LatLng(34.0101, 71.5399);
  final String demoDriverName = 'Muhammad Ali';
  final String demoDriverVehicle = 'Car';

  @override
  void onInit() {
    super.onInit();
    // Load demo markers when controller initializes
    _loadDemoMarkers();
  }

  void setMapReady(bool v) => isMapReady.value = v;

  /// Load demo markers for parent map
  Future<void> _loadDemoMarkers() async {
    try {
      isLoadingMarkers.value = true;
      
      // Load custom marker icons
      final homeIcon = await MapMarkerUtils.getHomeMarker();
      final schoolIcon = await MapMarkerUtils.getSchoolMarker();
      final driverIcon = await MapMarkerUtils.getDriverMarker(demoDriverVehicle);

      final Set<Marker> newMarkers = {};

      // Add home marker
      newMarkers.add(
        Marker(
          markerId: const MarkerId('home'),
          position: demoHomeLocation,
          icon: homeIcon,
          infoWindow: const InfoWindow(
            title: 'Home',
            snippet: 'Pickup Location',
          ),
        ),
      );

      // Add school marker
      newMarkers.add(
        Marker(
          markerId: const MarkerId('school'),
          position: demoSchoolLocation,
          icon: schoolIcon,
          infoWindow: InfoWindow(
            title: demoSchoolName,
            snippet: 'Drop-off Location',
          ),
        ),
      );

      // Add driver marker (simulating active trip)
      newMarkers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: demoDriverLocation,
          icon: driverIcon,
          infoWindow: InfoWindow(
            title: demoDriverName,
            snippet: 'En route to school',
          ),
        ),
      );

      markers.value = newMarkers;
    } catch (e) {
      // Fallback to default markers if custom icons fail
      _loadDefaultMarkers();
    } finally {
      isLoadingMarkers.value = false;
    }
  }

  /// Fallback to default markers if custom icons fail to load
  void _loadDefaultMarkers() {
    markers.value = {
      Marker(
        markerId: const MarkerId('home'),
        position: demoHomeLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Home', snippet: 'Pickup Location'),
      ),
      Marker(
        markerId: const MarkerId('school'),
        position: demoSchoolLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: demoSchoolName, snippet: 'Drop-off Location'),
      ),
      Marker(
        markerId: const MarkerId('driver'),
        position: demoDriverLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(title: demoDriverName, snippet: 'En route to school'),
      ),
    };
  }

  /// Refresh markers (useful for real-time updates)
  Future<void> refreshMarkers() async {
    await _loadDemoMarkers();
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
