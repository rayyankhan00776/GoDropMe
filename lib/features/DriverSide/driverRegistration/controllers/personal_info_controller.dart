import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/features/DriverSide/driverRegistration/models/personal_info.dart';

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

  /// Convert phone to E.164 format (+92XXXXXXXXXX) for Appwrite storage
  /// The PakistanPhoneNumberFormatter already normalizes to 10-digit national format (3XXXXXXXXX)
  String? get phoneE164 {
    final p = phone.value.trim();
    if (p.isEmpty) return null;
    final digits = p.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    // Formatter outputs 10-digit national number starting with 3
    // Just prepend +92
    return '+92$digits';
  }

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
      phone: phone.value, // Store raw for local display
      photoPath: imagePath.value,
    );
    await LocalStorage.setJson(StorageKeys.personalInfo, {
      'firstName': model.firstName,
      'surName': model.surName,
      'lastName': model.lastName,
      'imagePath': model.photoPath,
      'phone': phone.value, // Raw for local
      'phoneE164': phoneE164, // E.164 format for Appwrite
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
    phone: phone.value,
    photoPath: imagePath.value,
  );
}
