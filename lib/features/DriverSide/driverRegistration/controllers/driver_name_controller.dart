import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/features/DriverSide/driverRegistration/models/driver_name.dart';

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

  /// Returns a typed model representing the driver's name without changing
  /// how we persist it (still a plain string under StorageKeys.driverName).
  DriverName get model => DriverName(fullName: name.value);
}
