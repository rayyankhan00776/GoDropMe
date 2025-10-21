import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';

class ParentNameController extends GetxController {
  final name = ''.obs;

  void setName(String v) => name.value = v;

  Future<void> saveName() async {
    // Placeholder: persist locally; backend can be integrated later.
    debugPrint('ParentNameController: saving name: ${name.value}');
    await LocalStorage.setString(StorageKeys.parentName, name.value);
  }

  Future<void> loadName() async {
    final v = await LocalStorage.getString(StorageKeys.parentName);
    if (v != null) name.value = v;
  }
}
