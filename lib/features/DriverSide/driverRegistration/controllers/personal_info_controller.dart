import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';

class PersonalInfoController extends GetxController {
  final firstName = ''.obs;
  final surName = ''.obs;
  final lastName = ''.obs;
  final whatsappNumber = ''.obs;
  final imagePath = RxnString();

  void setFirstName(String v) => firstName.value = v;
  void setSurName(String v) => surName.value = v;
  void setLastName(String v) => lastName.value = v;
  void setWhatsappNumber(String v) => whatsappNumber.value = v;
  void setImagePath(String? path) => imagePath.value = path;

  Future<void> savePersonalInfo() async {
    // Placeholder: persist locally or call backend later.
    debugPrint(
      'PersonalInfoController: whatsapp=${whatsappNumber.value}, first=${firstName.value}, last=${lastName.value}, image=${imagePath.value}',
    );
    await LocalStorage.setJson(StorageKeys.personalInfo, {
      'whatsappNumber': whatsappNumber.value,
      'firstName': firstName.value,
      'surName': surName.value,
      'lastName': lastName.value,
      'imagePath': imagePath.value,
    });
  }

  Future<void> loadPersonalInfo() async {
    final data = await LocalStorage.getJson(StorageKeys.personalInfo);
    if (data == null) return;
    whatsappNumber.value = (data['whatsappNumber'] ?? '') as String;
    firstName.value = (data['firstName'] ?? '') as String;
    surName.value = (data['surName'] ?? '') as String;
    lastName.value = (data['lastName'] ?? '') as String;
    imagePath.value = data['imagePath'] as String?;
  }
}
