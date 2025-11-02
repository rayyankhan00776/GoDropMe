import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/features/driverSide/driverRegistration/models/personal_info.dart';

class PersonalInfoController extends GetxController {
  final firstName = ''.obs;
  final surName = ''.obs;
  final lastName = ''.obs;
  final imagePath = RxnString();

  void setFirstName(String v) => firstName.value = v;
  void setSurName(String v) => surName.value = v;
  void setLastName(String v) => lastName.value = v;
  void setImagePath(String? path) => imagePath.value = path;

  Future<void> savePersonalInfo() async {
    // Placeholder: persist locally or call backend later.
    debugPrint(
      'PersonalInfoController: first=${firstName.value}, last=${lastName.value}, image=${imagePath.value}',
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
    });
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
  }

  PersonalInfo get model => PersonalInfo(
    firstName: firstName.value,
    surName: surName.value,
    lastName: lastName.value,
    photoPath: imagePath.value,
  );
}
