import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/features/driverSide/driverRegistration/models/personal_info.dart';

class PersonalInfoController extends GetxController {
  final firstName = ''.obs;
  final surName = ''.obs;
  final lastName = ''.obs;
  final imagePath = RxnString();
  final phone = ''.obs;

  void setFirstName(String v) => firstName.value = v;
  void setSurName(String v) => surName.value = v;
  void setLastName(String v) => lastName.value = v;
  void setImagePath(String? path) => imagePath.value = path;
  void setPhone(String v) => phone.value = v;

  Future<void> savePersonalInfo() async {
    // Placeholder: persist locally or call backend later.
    debugPrint(
      'PersonalInfoController: first=${firstName.value}, last=${lastName.value}, phone=${phone.value}, image=${imagePath.value}',
    );
    // Build typed model but persist using existing storage keys
    final model = PersonalInfo(
      firstName: firstName.value,
      surName: surName.value,
      lastName: lastName.value,
      photoPath: imagePath.value,
    );
    await LocalStorage.setJson(StorageKeys.personalInfo, {
      'firstName': model.firstName,
      'surName': model.surName,
      'lastName': model.lastName,
      'imagePath': model.photoPath,
      'phone': phone.value,
    });
    // Persist phone under its dedicated key as well for parity with other flows
    if (phone.value.trim().isNotEmpty) {
      await LocalStorage.setString(StorageKeys.driverPhone, phone.value.trim());
    }
  }

  Future<void> loadPersonalInfo() async {
    final data = await LocalStorage.getJson(StorageKeys.personalInfo);
    if (data == null) return;
    // Map storage keys to model, then populate fields from model
    final model = PersonalInfo(
      firstName: (data['firstName'] ?? '') as String,
      surName: (data['surName'] ?? '') as String,
      lastName: (data['lastName'] ?? '') as String,
      photoPath: data['imagePath'] as String?,
    );
    firstName.value = model.firstName;
    surName.value = model.surName;
    lastName.value = model.lastName;
    imagePath.value = model.photoPath;
    // Load phone if present in stored JSON; otherwise leave as-is
    final p = (data['phone'] ?? '') as String;
    if (p.isNotEmpty) phone.value = p;
  }

  PersonalInfo get model => PersonalInfo(
    firstName: firstName.value,
    surName: surName.value,
    lastName: lastName.value,
    photoPath: imagePath.value,
  );
}
