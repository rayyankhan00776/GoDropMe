import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/features/DriverSide/driverRegistration/models/driver_name.dart';
import 'package:godropme/services/appwrite/auth_service.dart';
import 'package:godropme/services/appwrite/database_constants.dart';

class DriverNameController extends GetxController {
  final name = ''.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

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

  /// Register driver user in the users table.
  /// 
  /// This creates the user record in the `users` table with role = driver.
  /// The `drivers` table record will be created later when the driver
  /// completes full registration with all required documents.
  /// 
  /// Returns true on success, false on failure (check [errorMessage]).
  Future<bool> registerDriver() async {
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

      // Register user in users collection with role = driver
      // NOTE: This only creates users table row, NOT drivers table row.
      // Driver profile is created at end of registration with all documents.
      final registerResult = await AuthService.instance.registerUser(
        role: CollectionEnums.roleDriver,
        fullName: name.value.trim(),
        email: authUser.email,
      );

      if (!registerResult.success) {
        errorMessage.value = registerResult.message;
        return false;
      }

      debugPrint('✅ Driver user registered in users collection');

      // Save role locally for quick access
      await LocalStorage.setString(StorageKeys.userRole, 'driver');

      return true;
    } catch (e) {
      debugPrint('❌ Driver registration error: $e');
      errorMessage.value = 'Registration failed. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Returns a typed model representing the driver's name without changing
  /// how we persist it (still a plain string under StorageKeys.driverName).
  DriverName get model => DriverName(fullName: name.value);
}
