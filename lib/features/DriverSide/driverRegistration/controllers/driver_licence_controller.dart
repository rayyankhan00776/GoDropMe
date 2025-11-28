import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/features/DriverSide/driverRegistration/models/driver_licence.dart';

class DriverLicenceController extends GetxController {
  final licenceImagePath = RxnString();
  final selfieWithLicencePath = RxnString();
  final licenceNumber = ''.obs;
  final expiryDate = ''.obs;

  void setLicenceImagePath(String? path) => licenceImagePath.value = path;
  void setSelfieWithLicencePath(String? path) =>
      selfieWithLicencePath.value = path;
  void setLicenceNumber(String v) => licenceNumber.value = v;
  void setExpiryDate(String v) => expiryDate.value = v;

  Future<void> saveDriverLicence() async {
    // Placeholder for persistence / backend call
    debugPrint(
      'DriverLicenceController: licence=${licenceNumber.value}, expiry=${expiryDate.value}, licenceImage=${licenceImagePath.value}, selfie=${selfieWithLicencePath.value}',
    );
    // Build typed model but persist using existing storage keys
    final model = DriverLicence(
      licenceNumber: licenceNumber.value,
      expiry: expiryDate.value,
      licencePhotoPath: licenceImagePath.value,
      selfieWithLicencePath: selfieWithLicencePath.value,
    );
    await LocalStorage.setJson(StorageKeys.driverLicence, {
      'licenceImagePath': model.licencePhotoPath,
      'selfieWithLicencePath': model.selfieWithLicencePath,
      'licenceNumber': model.licenceNumber,
      'expiryDate': model.expiry,
    });
  }

  Future<void> loadDriverLicence() async {
    final data = await LocalStorage.getJson(StorageKeys.driverLicence);
    if (data == null) return;
    // Map storage keys to model, then populate fields from model
    final model = DriverLicence(
      licenceNumber: (data['licenceNumber'] ?? '') as String,
      expiry: (data['expiryDate'] ?? '') as String,
      licencePhotoPath: data['licenceImagePath'] as String?,
      selfieWithLicencePath: data['selfieWithLicencePath'] as String?,
    );
    licenceImagePath.value = model.licencePhotoPath;
    selfieWithLicencePath.value = model.selfieWithLicencePath;
    licenceNumber.value = model.licenceNumber;
    expiryDate.value = model.expiry;
  }

  DriverLicence get model => DriverLicence(
    licenceNumber: licenceNumber.value,
    expiry: expiryDate.value,
    licencePhotoPath: licenceImagePath.value,
    selfieWithLicencePath: selfieWithLicencePath.value,
  );
}
