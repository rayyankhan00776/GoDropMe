import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/features/DriverSide/driverRegistration/models/vehicle_registration.dart';

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
    final vr = VehicleRegistration(
      brand: brand,
      model: model,
      color: color,
      productionYear: year,
      numberPlate: plate,
      seatCapacity: seatCapacity,
      vehiclePhotoPath: vehiclePhotoPath,
      certificateFrontPath: certFrontPath,
      certificateBackPath: certBackPath,
    );
    // Persist with existing storage keys to avoid behavior changes
    await LocalStorage.setJson(StorageKeys.vehicleRegistration, {
      'brand': vr.brand,
      'model': vr.model,
      'color': vr.color,
      'year': vr.productionYear,
      'plate': vr.numberPlate,
      'seatCapacity': vr.seatCapacity,
      'vehiclePhotoPath': vr.vehiclePhotoPath,
      'certFrontPath': vr.certificateFrontPath,
      'certBackPath': vr.certificateBackPath,
    });
  }
}
