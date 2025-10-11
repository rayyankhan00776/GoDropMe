import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';

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
    await LocalStorage.setJson(StorageKeys.driverLicence, {
      'licenceImagePath': licenceImagePath.value,
      'selfieWithLicencePath': selfieWithLicencePath.value,
      'licenceNumber': licenceNumber.value,
      'expiryDate': expiryDate.value,
    });
  }

  Future<void> loadDriverLicence() async {
    final data = await LocalStorage.getJson(StorageKeys.driverLicence);
    if (data == null) return;
    licenceImagePath.value = data['licenceImagePath'] as String?;
    selfieWithLicencePath.value = data['selfieWithLicencePath'] as String?;
    licenceNumber.value = (data['licenceNumber'] ?? '') as String;
    expiryDate.value = (data['expiryDate'] ?? '') as String;
  }
}
