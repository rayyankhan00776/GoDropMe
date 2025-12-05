import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godropme/shared/utils/map_marker_utils.dart';
import 'package:godropme/features/DriverSide/driverHome/models/driver_map.dart';

class DriverHomeController extends GetxController {
  final isOnline = false.obs;
  final markers = Rx<Set<Marker>>({});
  final isLoadingMarkers = false.obs;
  final children = <ChildPickup>[].obs;
  
  // Cached driver icon for location updates
  BitmapDescriptor? driverIcon;
  
  // Driver's vehicle type - will come from user profile
  final vehicleType = 'Car'.obs;

  @override
  void onInit() {
    super.onInit();
    // Load demo data - replace with backend fetch later
    _loadDemoChildren();
    _loadMarkers();
  }

  void toggleOnline(bool v) => isOnline.value = v;

  /// Load demo children data - TODO: Replace with backend API call
  void _loadDemoChildren() {
    children.assignAll([
      const ChildPickup(
        id: 'child1',
        name: 'Ahmad',
        homeLocation: LatLng(34.0051, 71.5249),
        schoolLocation: LatLng(34.0251, 71.5349),
        schoolName: 'City School (Main Campus)',
      ),
      const ChildPickup(
        id: 'child2',
        name: 'Sara',
        homeLocation: LatLng(34.0101, 71.5149),
        schoolLocation: LatLng(34.0251, 71.5349),
        schoolName: 'City School (Main Campus)',
      ),
      const ChildPickup(
        id: 'child3',
        name: 'Ali',
        homeLocation: LatLng(34.0181, 71.5199),
        schoolLocation: LatLng(34.0301, 71.5449),
        schoolName: 'Beacon House School',
      ),
    ]);
  }

  /// Fetch children from backend - TODO: Implement with Appwrite
  Future<void> fetchChildren() async {
    // TODO: Replace with actual backend call
    // final response = await appwrite.databases.listDocuments(...);
    // children.assignAll(response.documents.map((d) => ChildPickup.fromJson(d.data)));
    _loadDemoChildren();
    await _loadMarkers();
  }

  /// Load markers for all children
  Future<void> _loadMarkers() async {
    try {
      isLoadingMarkers.value = true;

      // Load custom marker icons
      final homeIcon = await MapMarkerUtils.getHomeMarker();
      final schoolIcon = await MapMarkerUtils.getSchoolMarker();
      driverIcon = await MapMarkerUtils.getDriverMarker(vehicleType.value);

      final Set<Marker> newMarkers = {};

      // Add markers for each child's home
      for (final child in children) {
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
    } catch (e) {
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
    await _loadMarkers();
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
