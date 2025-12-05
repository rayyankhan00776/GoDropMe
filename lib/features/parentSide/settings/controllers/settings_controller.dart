import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/features/parentSide/parentProfile/controllers/parent_profile_controller.dart';
import 'package:godropme/services/appwrite/auth_service.dart';
import 'package:godropme/services/appwrite/parent_service.dart';
import 'package:godropme/services/appwrite/child_service.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/database_constants.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/theme/colors.dart';

class SettingsController extends GetxController {
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
    final raw = await LocalStorage.getString(StorageKeys.parentEmail);
    email.value = raw?.trim();
  }

  /// Logout: Clear Appwrite session + local data → go to option screen
  Future<void> logout() async {
    isLoggingOut.value = true;
    isLoading.value = true;

    try {
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

  /// Delete Account: Delete all children, parent profile, user record, session
  /// 
  /// Deletes data from 3 tables:
  /// 1. Children table (all children for this parent)
  /// 2. Parents table (parent profile + photo)
  /// 3. Users table (user record)
  /// 
  /// Note: Account (Auth) cannot be fully deleted from client SDK.
  /// The account will remain in Appwrite but all data is removed.
  Future<void> deleteAccount() async {
    isDeletingAccount.value = true;
    isLoading.value = true;

    try {
      // Get parent ID and auth user ID
      final profileController = Get.find<ParentProfileController>();
      final parentId = profileController.parentId;
      final photoUrl = profileController.photoUrl;
      final authUserId = AuthService.instance.currentUser?.$id;

      if (parentId != null) {
        // 1. Delete all children for this parent
        await ChildService.instance.deleteAllChildren(parentId);
        debugPrint('✅ All children deleted');

        // 2. Delete parent profile (includes photo deletion)
        await ParentService.instance.deleteParent(
          parentId: parentId,
          profilePhotoUrl: photoUrl,
        );
        debugPrint('✅ Parent profile deleted');
      }

      // 3. Delete user record from users table
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

      // 4. Logout from Appwrite (delete session)
      // Note: This only deletes the session, not the account itself
      // Full account deletion requires Server SDK with API key
      await AuthService.instance.logout();
      debugPrint('✅ Logged out from Appwrite');

      // 5. Clear all local data
      await LocalStorage.clearAllUserData();
      debugPrint('✅ Local data cleared');

      // 6. Show success and navigate
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
