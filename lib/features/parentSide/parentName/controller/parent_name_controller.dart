import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/features/parentSide/parentProfile/models/parent_profile.dart';
import 'package:godropme/models/value_objects.dart';
import 'package:godropme/services/appwrite/auth_service.dart';
import 'package:godropme/services/appwrite/parent_service.dart';
import 'package:godropme/services/appwrite/database_constants.dart';

class ParentNameController extends GetxController {
  final name = ''.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  void setName(String v) => name.value = v;

  /// Save name locally (for draft/offline usage)
  Future<void> saveName() async {
    debugPrint('ParentNameController: saving name locally: ${name.value}');
    await LocalStorage.setString(StorageKeys.parentName, name.value);
  }

  Future<void> loadName() async {
    final v = await LocalStorage.getString(StorageKeys.parentName);
    if (v != null) name.value = v;
  }

  /// Register parent with Appwrite backend
  /// 
  /// Creates user record + parent profile in Appwrite.
  /// Call this when parent completes the registration flow.
  /// 
  /// Returns true on success, false on failure (check [errorMessage]).
  Future<bool> registerParent({
    File? profilePhoto,
  }) async {
    if (name.value.trim().isEmpty) {
      errorMessage.value = 'Please enter your name';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final authUser = AuthService.instance.currentUser;
      if (authUser == null) {
        errorMessage.value = 'Please login first';
        return false;
      }

      // Step 1: Register user in users collection with role = parent
      final registerResult = await AuthService.instance.registerUser(
        role: CollectionEnums.roleParent,
        fullName: name.value.trim(),
        email: authUser.email,
      );

      if (!registerResult.success) {
        errorMessage.value = registerResult.message;
        return false;
      }

      debugPrint('✅ Parent registered in users collection');

      // Step 2: If profile photo provided, update the parent profile with photo
      if (profilePhoto != null) {
        // Get the newly created parent profile
        final getResult = await ParentService.instance.getParent();
        if (getResult.success && getResult.parent?.id != null) {
          await ParentService.instance.updateProfilePhoto(
            parentId: getResult.parent!.id!,
            photo: profilePhoto,
          );
          debugPrint('📷 Profile photo uploaded');
        }
      }

      // Step 3: Save role locally for quick access
      await LocalStorage.setString(StorageKeys.userRole, 'parent');

      return true;
    } catch (e) {
      debugPrint('❌ Parent registration error: $e');
      errorMessage.value = 'Registration failed. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Returns a typed ParentProfile composed from the current name and the
  /// locally stored phone number. This does not change how data is persisted
  /// elsewhere; it's a convenience to use strongly-typed data at the edges.
  Future<ParentProfile> buildProfile() async {
    final phoneDigits =
        await LocalStorage.getString(StorageKeys.parentPhone) ?? '';
    return ParentProfile(
      fullName: name.value,
      phone: phoneDigits.isNotEmpty ? PhoneNumber(national: phoneDigits) : null,
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
