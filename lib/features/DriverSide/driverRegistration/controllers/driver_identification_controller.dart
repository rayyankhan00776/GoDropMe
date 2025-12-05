import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/features/DriverSide/driverRegistration/models/driver_identification.dart';

class DriverIdentificationController extends GetxController {
  final frontImagePath = RxnString();
  final backImagePath = RxnString();
  final cnicNumber = ''.obs;
  final cnicExpiry = ''.obs; // Renamed to match Appwrite column

  void setFrontImagePath(String? path) => frontImagePath.value = path;
  void setBackImagePath(String? path) => backImagePath.value = path;
  void setCnicNumber(String v) => cnicNumber.value = v;
  void setCnicExpiry(String v) => cnicExpiry.value = v;
  
  // Legacy alias for backward compatibility
  void setExpiryDate(String v) => cnicExpiry.value = v;

  Future<void> saveDriverIdentification() async {
    // Placeholder for persistence / backend call
    debugPrint(
      'DriverIdentificationController: cnic=${cnicNumber.value}, expiry=${cnicExpiry.value}, front=${frontImagePath.value}, back=${backImagePath.value}',
    );
    // Build typed model but persist using existing storage keys
    final model = DriverIdentification(
      cnicNumber: cnicNumber.value,
      cnicExpiry: cnicExpiry.value,
      idFrontPhotoPath: frontImagePath.value,
      idBackPhotoPath: backImagePath.value,
    );
    await LocalStorage.setJson(StorageKeys.driverIdentification, {
      'cnicNumber': model.cnicNumber,
      'cnicExpiry': model.cnicExpiry,
      'frontImagePath': model.idFrontPhotoPath,
      'backImagePath': model.idBackPhotoPath,
    });
  }

  Future<void> loadDriverIdentification() async {
    final data = await LocalStorage.getJson(StorageKeys.driverIdentification);
    if (data == null) return;
    final model = DriverIdentification(
      cnicNumber: (data['cnicNumber'] ?? '') as String,
      // Support both old 'expiryDate' and new 'cnicExpiry' keys from storage
      cnicExpiry: (data['cnicExpiry'] ?? data['expiryDate'] ?? '') as String,
      idFrontPhotoPath: data['frontImagePath'] as String?,
      idBackPhotoPath: data['backImagePath'] as String?,
    );
    cnicNumber.value = model.cnicNumber;
    cnicExpiry.value = model.cnicExpiry ?? '';
    frontImagePath.value = model.idFrontPhotoPath;
    backImagePath.value = model.idBackPhotoPath;
  }

  DriverIdentification get model => DriverIdentification(
    cnicNumber: cnicNumber.value,
    cnicExpiry: cnicExpiry.value,
    idFrontPhotoPath: frontImagePath.value,
    idBackPhotoPath: backImagePath.value,
  );
}
