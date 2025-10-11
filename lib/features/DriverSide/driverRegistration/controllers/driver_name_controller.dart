import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/utils/local_storage.dart';

class DriverNameController extends GetxController {
  final name = ''.obs;

  void setName(String v) => name.value = v;

  Future<void> saveName() async {
    // Placeholder: persist locally or call backend later.
    debugPrint('DriverNameController: saving name: ${name.value}');
    await LocalStorage.setString(StorageKeys.driverName, name.value);
  }

  Future<void> loadName() async {
    final v = await LocalStorage.getString(StorageKeys.driverName);
    if (v != null) name.value = v;
  }
}
