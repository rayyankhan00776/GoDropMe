import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/services/appwrite/auth_service.dart';
import 'package:godropme/services/appwrite/database_constants.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';

class OtpController extends GetxController {
  final code = ''.obs;
  final digits = List.generate(6, (_) => '').obs;
  final allFilled = false.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  
  // Resend OTP state
  final isResending = false.obs;
  final canResend = false.obs;
  final resendCountdown = 60.obs; // 60 seconds countdown
  Timer? _resendTimer;

  @override
  void onInit() {
    super.onInit();
    _startResendTimer();
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    super.onClose();
  }

  /// Start the countdown timer for resend
  void _startResendTimer() {
    canResend.value = false;
    resendCountdown.value = 60;
    
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  /// Resend OTP to the user's email
  Future<bool> resendOtp(String email) async {
    if (!canResend.value || isResending.value) return false;
    
    isResending.value = true;
    errorMessage.value = '';
    
    try {
      final result = await AuthService.instance.sendEmailOTP(email);
      
      if (result.success) {
        debugPrint('✅ OTP resent successfully to $email');
        // Reset digits and restart timer
        resetDigits();
        _startResendTimer();
        return true;
      } else {
        errorMessage.value = result.message;
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error resending OTP: $e');
      errorMessage.value = 'Failed to resend OTP. Please try again.';
      return false;
    } finally {
      isResending.value = false;
    }
  }

  void setCode(String value) => code.value = value;

  void setDigit(int index, String value) {
    if (index < 0 || index >= digits.length) return;
    digits[index] = value;
    // trigger recomputation
    allFilled.value = digits.every((d) => d.trim().length == 1);
    digits.refresh();
  }

  /// Get the full OTP code from all digits
  String get fullCode => digits.join();

  /// Reset all digits
  void resetDigits() {
    for (int i = 0; i < digits.length; i++) {
      digits[i] = '';
    }
    allFilled.value = false;
    digits.refresh();
  }

  /// Verify OTP with Appwrite and navigate based on result
  Future<bool> verifyOtp() async {
    if (!allFilled.value) {
      errorMessage.value = 'Please enter the complete 6-digit code';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await AuthService.instance.verifyEmailOTP(fullCode);

      if (!result.success) {
        errorMessage.value = result.message;
        return false;
      }

      debugPrint('✅ OTP verified! isNewUser: ${result.isNewUser}, role: ${result.userRole}, status: ${result.status}, hasDriverProfile: ${result.hasDriverProfile}');

      // Navigate based on user status
      if (result.isNewUser == true) {
        // New user - go to driver/parent option screen
        Get.offAllNamed(AppRoutes.dopOption);
      } else {
        // Existing user - route based on role
        await _navigateToHome(
          result.userRole, 
          result.status, 
          result.hasDriverProfile,
          result.statusReason,
        );
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error verifying OTP: $e');
      errorMessage.value = 'Verification failed. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
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
      // Save role for future reference
      await LocalStorage.setString(StorageKeys.userRole, 'parent');
      Get.offAllNamed(AppRoutes.parentmapScreen);
    } else if (role == CollectionEnums.roleDriver) {
      // Save role for future reference
      await LocalStorage.setString(StorageKeys.userRole, 'driver');
      
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
      // Unknown role - go to option screen
      Get.offAllNamed(AppRoutes.dopOption);
    }
  }
}
