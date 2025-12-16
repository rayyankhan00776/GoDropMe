import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/features/DriverSide/driverProfile/controllers/driver_profile_controller.dart';
import 'package:godropme/services/appwrite/auth_service.dart';
import 'package:godropme/services/appwrite/notification_service.dart';
import 'package:godropme/services/appwrite/driver_service.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/database_constants.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/theme/colors.dart';

class DriverSettingsController extends GetxController {
  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoggingOut = false.obs;
  final RxBool isDeletingAccount = false.obs;

  // Email from local storage
  final RxnString email = RxnString();

  @override
  void onInit() {
    super.onInit();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    final raw = await LocalStorage.getString(StorageKeys.driverEmail);
    email.value = raw?.trim();
  }

  /// Logout: Clear Appwrite session + local data → go to option screen
  Future<void> logout() async {
    isLoggingOut.value = true;
    isLoading.value = true;

    try {
      // Stop realtime subscription before logout
      NotificationService.instance.stopRealtimeSubscription();
      
      // Logout from Appwrite (delete session)
      await AuthService.instance.logout();
      debugPrint('✅ Logged out from Appwrite');

      // Clear all local data
      await LocalStorage.clearAllUserData();
      debugPrint('✅ Local data cleared');

      // Navigate to option screen
      Get.offAllNamed(AppRoutes.optionScreen);
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      // Still clear local data and navigate even if Appwrite fails
      await LocalStorage.clearAllUserData();
      Get.offAllNamed(AppRoutes.optionScreen);
    } finally {
      isLoggingOut.value = false;
      isLoading.value = false;
    }
  }

  /// Delete Account: Delete driver profile, user record, session
  /// 
  /// Deletes data from 2 tables:
  /// 1. Drivers table (driver profile + photos)
  /// 2. Users table (user record)
  /// 
  /// Note: Account (Auth) cannot be fully deleted from client SDK.
  /// The account will remain in Appwrite but all data is removed.
  Future<void> deleteAccount() async {
    isDeletingAccount.value = true;
    isLoading.value = true;

    try {
      // Get driver ID from controller if available
      final profileController = Get.isRegistered<DriverProfileController>()
          ? Get.find<DriverProfileController>()
          : null;
      final driverId = profileController?.driverId;
      final authUserId = AuthService.instance.currentUser?.$id;

      if (driverId != null) {
        // Delete driver profile - it will handle photo deletion internally
        await DriverService.instance.deleteDriver(
          driverId: driverId,
        );
        debugPrint('✅ Driver profile deleted');
      }

      // Delete user record from users table
      if (authUserId != null) {
        try {
          final tablesDB = AppwriteClient.tablesDBService();
          await tablesDB.deleteRow(
            databaseId: AppwriteConfig.databaseId,
            tableId: Collections.users,
            rowId: authUserId,
          );
          debugPrint('✅ User record deleted from users table');
        } catch (e) {
          debugPrint('⚠️ Could not delete user record: $e');
          // Continue - user might not exist in table
        }
      }

      // Logout from Appwrite (delete session)
      await AuthService.instance.logout();
      debugPrint('✅ Logged out from Appwrite');

      // Clear all local data
      await LocalStorage.clearAllUserData();
      debugPrint('✅ Local data cleared');

      // Show success and navigate
      Get.snackbar(
        'Account Deleted',
        'Your account has been successfully deleted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );

      Get.offAllNamed(AppRoutes.optionScreen);
    } catch (e) {
      debugPrint('❌ Delete account error: $e');
      Get.snackbar(
        'Error',
        'Failed to delete account. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isDeletingAccount.value = false;
      isLoading.value = false;
    }
  }
}
