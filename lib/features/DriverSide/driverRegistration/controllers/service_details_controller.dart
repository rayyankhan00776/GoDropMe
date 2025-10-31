import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';

class ServiceDetailsController extends GetxController {
  // Selected fields
  final selectedSchools = <String>[].obs; // multi-select
  final dutyType = RxnString();
  final pickupRangeKm = RxnString(); // e.g., "3–5"
  final routeStartLat = RxnDouble();
  final routeStartLng = RxnDouble();
  final availableSeats = 0.obs;
  final operatingDays = RxnString();
  final extraNotes = ''.obs;
  final isActive = true.obs;

  // Seat capacity cap from vehicle registration step
  final seatCapacityMax = 0.obs;

  Future<void> loadSeatCapacityCap() async {
    final vehicle = await LocalStorage.getJson(StorageKeys.vehicleRegistration);
    if (vehicle != null) {
      final cap = vehicle['seatCapacity'];
      if (cap is int) {
        seatCapacityMax.value = cap;
        if (availableSeats.value == 0) {
          availableSeats.value = cap; // default: all seats available initially
        }
      }
    }
  }

  Future<void> saveServiceDetails() async {
    await LocalStorage.setJson(StorageKeys.driverServiceDetails, {
      'schoolNames': selectedSchools.toList(),
      'dutyType': dutyType.value,
      'pickupRangeKm': pickupRangeKm.value,
      'routeStart': _coordsOrNull(routeStartLat.value, routeStartLng.value),
      'availableSeats': availableSeats.value,
      'operatingDays': operatingDays.value,
      'extraNotes': extraNotes.value,
      'active': isActive.value,
    });
  }

  Map<String, double>? _coordsOrNull(double? lat, double? lng) {
    if (lat == null || lng == null) return null;
    return {'lat': lat, 'lng': lng};
  }
}
