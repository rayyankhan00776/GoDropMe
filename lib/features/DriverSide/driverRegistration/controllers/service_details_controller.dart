import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';

class ServiceDetailsController extends GetxController {
  // Selected fields
  final selectedSchools = <String>[].obs; // school names for display
  final selectedSchoolsData = <Map<String, dynamic>>[].obs; // full school data with lat/lng
  final serviceCategory = RxnString(); // 'Male', 'Female', or 'Both'
  final routeStartLat = RxnDouble(); // serviceAreaCenter lat
  final routeStartLng = RxnDouble(); // serviceAreaCenter lng
  final routeStartAddress = RxnString(); // serviceAreaAddress
  final monthlyPricePkr = RxnInt(); // Monthly service price in PKR
  final extraNotes = ''.obs;

  // Seat capacity cap from vehicle registration step (for reference)
  final seatCapacityMax = 0.obs;

  Future<void> loadSeatCapacityCap() async {
    final vehicle = await LocalStorage.getJson(StorageKeys.vehicleRegistration);
    if (vehicle != null) {
      final cap = vehicle['seatCapacity'];
      if (cap is int) {
        seatCapacityMax.value = cap;
      }
    }
  }

  Future<void> saveServiceDetails({
    required List<Map<String, dynamic>> schools,
    String? serviceCategory,
    double? serviceAreaRadiusKm,
    List<Map<String, double>>? serviceAreaPolygon,
  }) async {
    await LocalStorage.setJson(StorageKeys.driverServiceDetails, {
      'schools': schools, // Full school objects with lat/lng
      'serviceCategory': serviceCategory,
      'serviceAreaCenter': _coordsOrNull(routeStartLat.value, routeStartLng.value),
      'serviceAreaAddress': routeStartAddress.value,
      'serviceAreaRadiusKm': serviceAreaRadiusKm,
      'serviceAreaPolygon': serviceAreaPolygon,
      'monthlyPricePkr': monthlyPricePkr.value,
      'extraNotes': extraNotes.value,
    });
  }

  Map<String, double>? _coordsOrNull(double? lat, double? lng) {
    if (lat == null || lng == null) return null;
    return {'lat': lat, 'lng': lng};
  }
}
