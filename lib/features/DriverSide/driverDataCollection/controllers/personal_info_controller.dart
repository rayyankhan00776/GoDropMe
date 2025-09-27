import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

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
  }
}
