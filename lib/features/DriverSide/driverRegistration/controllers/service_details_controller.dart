import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/features/driverSide/driverRegistration/models/service_details.dart';
import 'package:godropme/models/value_objects.dart';

class ServiceDetailsController extends GetxController {
  // Selected fields
  final selectedSchools = <String>[].obs; // multi-select
  final dutyType = RxnString();
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

  /// A typed snapshot of current selections. Persistence stays unchanged.
  ServiceDetails get model => ServiceDetails(
    schoolNames: selectedSchools.toList(),
    dutyType: dutyType.value ?? '',
    pickupRangeKm: '', // not part of current controller state
    operatingDays: operatingDays.value == null
        ? const []
        : [operatingDays.value!],
    routeStartPoint:
        (routeStartLat.value != null && routeStartLng.value != null)
        ? LatLngLite(lat: routeStartLat.value!, lng: routeStartLng.value!)
        : null,
    extraNotes: extraNotes.value.isEmpty ? null : extraNotes.value,
    isActive: isActive.value,
  );
}
