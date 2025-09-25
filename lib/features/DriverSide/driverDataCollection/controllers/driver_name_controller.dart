import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class DriverNameController extends GetxController {
  final name = ''.obs;

  void setName(String v) => name.value = v;

  Future<void> saveName() async {
    // Placeholder: persist locally or call backend later.
    debugPrint('DriverNameController: saving name: ${name.value}');
  }
}
