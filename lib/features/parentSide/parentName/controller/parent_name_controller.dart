import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class ParentNameController extends GetxController {
  final name = ''.obs;

  void setName(String v) => name.value = v;

  Future<void> saveName() async {
    // Placeholder: persist locally or call backend later.
    debugPrint('ParentNameController: saving name: ${name.value}');
  }
}
