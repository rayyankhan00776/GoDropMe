import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';

/// Controller for Vehicle Registration step.
/// Keeps persistence logic centralized without altering the UI layer.
class VehicleRegistrationController extends GetxController {
  /// Mirrors the existing helper function and writes the section to local storage.
  Future<void> saveVehicleRegistrationSection({
    required String brand,
    required String model,
    required String color,
    required String year,
    required String plate,
    required int seatCapacity,
    required String? vehiclePhotoPath,
    required String? certFrontPath,
    required String? certBackPath,
  }) async {
    await LocalStorage.setJson(StorageKeys.vehicleRegistration, {
      'brand': brand,
      'model': model,
      'color': color,
      'year': year,
      'plate': plate,
      'seatCapacity': seatCapacity,
      'vehiclePhotoPath': vehiclePhotoPath,
      'certFrontPath': certFrontPath,
      'certBackPath': certBackPath,
    });
  }
}
