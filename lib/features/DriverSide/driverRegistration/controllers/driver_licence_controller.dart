import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/features/DriverSide/driverRegistration/models/driver_licence.dart';

class DriverLicenceController extends GetxController {
  final licenceImagePath = RxnString();
  final selfieWithLicencePath = RxnString();
  final licenceNumber = ''.obs;
  final licenseExpiry = ''.obs; // Renamed to match Appwrite column

  void setLicenceImagePath(String? path) => licenceImagePath.value = path;
  void setSelfieWithLicencePath(String? path) =>
      selfieWithLicencePath.value = path;
  void setLicenceNumber(String v) => licenceNumber.value = v;
  void setLicenseExpiry(String v) => licenseExpiry.value = v;
  
  // Legacy alias for backward compatibility
  void setExpiryDate(String v) => licenseExpiry.value = v;

  Future<void> saveDriverLicence() async {
    // Placeholder for persistence / backend call
    debugPrint(
      'DriverLicenceController: licence=${licenceNumber.value}, expiry=${licenseExpiry.value}, licenceImage=${licenceImagePath.value}, selfie=${selfieWithLicencePath.value}',
    );
    // Build typed model but persist using existing storage keys
    final model = DriverLicence(
      licenceNumber: licenceNumber.value,
      licenseExpiry: licenseExpiry.value,
      licencePhotoPath: licenceImagePath.value,
      selfieWithLicencePath: selfieWithLicencePath.value,
    );
    await LocalStorage.setJson(StorageKeys.driverLicence, {
      'licenceImagePath': model.licencePhotoPath,
      'selfieWithLicencePath': model.selfieWithLicencePath,
      'licenceNumber': model.licenceNumber,
      'licenseExpiry': model.licenseExpiry,
    });
  }

  Future<void> loadDriverLicence() async {
    final data = await LocalStorage.getJson(StorageKeys.driverLicence);
    if (data == null) return;
    // Map storage keys to model, then populate fields from model
    // Support both old 'expiryDate' and new 'licenseExpiry' keys
    final model = DriverLicence(
      licenceNumber: (data['licenceNumber'] ?? '') as String,
      licenseExpiry: (data['licenseExpiry'] ?? data['expiryDate'] ?? '') as String,
      licencePhotoPath: data['licenceImagePath'] as String?,
      selfieWithLicencePath: data['selfieWithLicencePath'] as String?,
    );
    licenceImagePath.value = model.licencePhotoPath;
    selfieWithLicencePath.value = model.selfieWithLicencePath;
    licenceNumber.value = model.licenceNumber;
    licenseExpiry.value = model.licenseExpiry;
  }

  DriverLicence get model => DriverLicence(
    licenceNumber: licenceNumber.value,
    licenseExpiry: licenseExpiry.value,
    licencePhotoPath: licenceImagePath.value,
    selfieWithLicencePath: selfieWithLicencePath.value,
  );
}
