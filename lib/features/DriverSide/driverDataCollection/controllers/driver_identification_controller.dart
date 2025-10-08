import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/core/utils/local_storage.dart';

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
    await LocalStorage.setJson(StorageKeys.driverIdentification, {
      'cnicNumber': cnicNumber.value,
      'expiryDate': expiryDate.value,
      'frontImagePath': frontImagePath.value,
      'backImagePath': backImagePath.value,
    });
  }

  Future<void> loadDriverIdentification() async {
    final data = await LocalStorage.getJson(StorageKeys.driverIdentification);
    if (data == null) return;
    cnicNumber.value = (data['cnicNumber'] ?? '') as String;
    expiryDate.value = (data['expiryDate'] ?? '') as String;
    frontImagePath.value = data['frontImagePath'] as String?;
    backImagePath.value = data['backImagePath'] as String?;
  }
}
