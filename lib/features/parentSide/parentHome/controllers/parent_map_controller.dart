import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Controller for Parent Home/Map screen with location services.
class ParentMapController extends GetxController {
  final isMapReady = false.obs;
  final Rxn<Position> currentPosition = Rxn<Position>();
  final isLoadingLocation = false.obs;

  void setMapReady(bool v) => isMapReady.value = v;

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
