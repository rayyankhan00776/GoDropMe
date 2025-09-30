import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

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
  }
}
