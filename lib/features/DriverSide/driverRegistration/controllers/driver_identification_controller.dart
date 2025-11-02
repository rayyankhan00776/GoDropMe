import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/features/driverSide/driverRegistration/models/driver_identification.dart';

class DriverIdentificationController extends GetxController {
  final frontImagePath = RxnString();
  final backImagePath = RxnString();
  final cnicNumber = ''.obs;
  final expiryDate = ''.obs;

  void setFrontImagePath(String? path) => frontImagePath.value = path;
  void setBackImagePath(String? path) => backImagePath.value = path;
  void setCnicNumber(String v) => cnicNumber.value = v;
  void setExpiryDate(String v) => expiryDate.value = v;

  Future<void> saveDriverIdentification() async {
    // Placeholder for persistence / backend call
    debugPrint(
      'DriverIdentificationController: cnic=${cnicNumber.value}, expiry=${expiryDate.value}, front=${frontImagePath.value}, back=${backImagePath.value}',
    );
    // Build typed model but persist using existing storage keys
    final model = DriverIdentification(
      cnicNumber: cnicNumber.value,
      expiryDate: expiryDate.value,
      idFrontPhotoPath: frontImagePath.value,
      idBackPhotoPath: backImagePath.value,
    );
    await LocalStorage.setJson(StorageKeys.driverIdentification, {
      'cnicNumber': model.cnicNumber,
      'expiryDate': model.expiryDate,
      'frontImagePath': model.idFrontPhotoPath,
      'backImagePath': model.idBackPhotoPath,
    });
  }

  Future<void> loadDriverIdentification() async {
    final data = await LocalStorage.getJson(StorageKeys.driverIdentification);
    if (data == null) return;
    final model = DriverIdentification(
      cnicNumber: (data['cnicNumber'] ?? '') as String,
      expiryDate: (data['expiryDate'] ?? '') as String,
      idFrontPhotoPath: data['frontImagePath'] as String?,
      idBackPhotoPath: data['backImagePath'] as String?,
    );
    cnicNumber.value = model.cnicNumber;
    expiryDate.value = model.expiryDate ?? '';
    frontImagePath.value = model.idFrontPhotoPath;
    backImagePath.value = model.idBackPhotoPath;
  }

  DriverIdentification get model => DriverIdentification(
    cnicNumber: cnicNumber.value,
    expiryDate: expiryDate.value,
    idFrontPhotoPath: frontImagePath.value,
    idBackPhotoPath: backImagePath.value,
  );
}
