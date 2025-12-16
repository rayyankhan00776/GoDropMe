import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/services/appwrite/auth_service.dart';
import 'package:godropme/services/appwrite/database_constants.dart';
import 'package:godropme/services/appwrite/notification_service.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';

/// Controller for the splash screen that handles:
/// 1. Request notification permission (better UX - during splash)
/// 2. Check if first-time user (show onboarding)
/// 3. Check if user has active session (auto-login)
/// 4. Navigate to appropriate screen
class SplashController extends GetxController {
  // Observable for permission request status
  final isRequestingPermission = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  /// Initialize app and determine navigation
  Future<void> _initializeApp() async {
    // Request notification permission during splash (better UX)
    // This happens while splash screen is showing, so user sees the dialog
    // before any app content loads
    isRequestingPermission.value = true;
    final hasPermission = await NotificationService.instance.hasNotificationPermission();
    if (!hasPermission) {
      debugPrint('🔔 Requesting notification permission...');
      await NotificationService.instance.requestNotificationPermission();
    }
    isRequestingPermission.value = false;
    
    // Small delay for splash screen visibility (reduced since permission took some time)
    await Future.delayed(const Duration(milliseconds: 800));

    // Check if user has seen onboarding
    final hasSeenOnboarding = await LocalStorage.getString(StorageKeys.hasSeenOnboarding);

    if (hasSeenOnboarding != 'true') {
      // First-time user - show onboarding
      debugPrint('🚀 First-time user - showing onboarding');
      Get.offAllNamed(AppRoutes.onboard);
      return;
    }

    // User has seen onboarding, check for active session
    final sessionResult = await AuthService.instance.checkSession();

    if (!sessionResult.success) {
      // No active session - show login/option screen
      debugPrint('🔐 No active session - showing option screen');
      Get.offAllNamed(AppRoutes.optionScreen);
      return;
    }

    // User has active session - register for push notifications
    debugPrint('✅ Active session found - role: ${sessionResult.userRole}, status: ${sessionResult.status}, hasDriverProfile: ${sessionResult.hasDriverProfile}');
    await NotificationService.instance.registerForPushNotifications();
    
    // Start app-wide realtime subscription for live notification updates
    // This ensures notifications work even when not on notification page
    NotificationService.instance.startRealtimeSubscription();
    
    await _navigateToHome(
      sessionResult.userRole, 
      sessionResult.status,
      sessionResult.hasDriverProfile,
      sessionResult.statusReason,
    );
  }

  /// Navigate to the appropriate home screen based on user role
  /// Status is now from users table: pending, active, suspended, rejected
  Future<void> _navigateToHome(
    String? role, 
    String? status, 
    bool hasDriverProfile,
    String? statusReason,
  ) async {
    if (role == CollectionEnums.roleParent) {
      switch (status) {
        case CollectionEnums.statusSuspended:
          Get.offAllNamed(
            AppRoutes.driverSuspended,
            arguments: {'reason': statusReason},
          );
          break;
          default:
          // Default to main map if status unknown
          Get.offAllNamed(AppRoutes.parentmapScreen);
      }
    } else if (role == CollectionEnums.roleDriver) {
      // Check if driver has completed registration
      if (!hasDriverProfile) {
        // Driver user exists but hasn't completed registration
        // Resume at vehicle selection
        debugPrint('🚗 Driver registration incomplete - resuming at vehicle selection');
        Get.offAllNamed(AppRoutes.vehicleSelection);
        return;
      }
      
      // Driver has profile - check status from users table
      // Users table status: pending, active, suspended, rejected
      switch (status) {
        case CollectionEnums.statusActive:
          Get.offAllNamed(AppRoutes.driverMap);
          break;
        case CollectionEnums.statusPending:
          Get.offAllNamed(AppRoutes.driverPendingApproval);
          break;
        case CollectionEnums.statusSuspended:
          Get.offAllNamed(
            AppRoutes.driverSuspended,
            arguments: {'reason': statusReason},
          );
          break;
        case CollectionEnums.statusRejected:
          Get.offAllNamed(
            AppRoutes.driverRejected,
            arguments: {'reason': statusReason},
          );
          break;
        default:
          // Default to pending approval if status unknown
          Get.offAllNamed(AppRoutes.driverPendingApproval);
      }
    } else {
      // Unknown or no role - check if they need to complete registration
      // For now, go to option screen
      Get.offAllNamed(AppRoutes.dopOption);
    }
  }
}
