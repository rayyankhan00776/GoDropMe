import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/models/parent_profile.dart';
import 'package:godropme/models/value_objects.dart';

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

  /// Returns a typed ParentProfile composed from the current name and the
  /// locally stored phone number. This does not change how data is persisted
  /// elsewhere; it's a convenience to use strongly-typed data at the edges.
  Future<ParentProfile> buildProfile() async {
    final phoneDigits =
        await LocalStorage.getString(StorageKeys.parentPhone) ?? '';
    return ParentProfile(
      fullName: name.value,
      phone: PhoneNumber(national: phoneDigits),
    );
  }

  /// Saves the profile using the existing individual keys without changing
  /// their shape. Pass [phoneDigits] as national digits (e.g., 3XXXXXXXXX).
  Future<void> saveProfile({required String phoneDigits}) async {
    debugPrint(
      'ParentNameController: saving profile: name=${name.value}, phone=$phoneDigits',
    );
    await LocalStorage.setString(StorageKeys.parentName, name.value);
    await LocalStorage.setString(StorageKeys.parentPhone, phoneDigits);
  }
}
