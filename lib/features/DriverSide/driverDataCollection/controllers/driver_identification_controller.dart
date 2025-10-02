import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

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
  }
}
