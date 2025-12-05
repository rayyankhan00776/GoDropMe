import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/services/appwrite/auth_service.dart';

/// Controller previously used for phone number collection now repurposed
/// for email capture. Renamed logically (class only) to reflect new input
/// semantics while keeping the same file and binding names to avoid
/// widespread route / binding churn.
class EmailController extends GetxController {
  final email = ''.obs; // captured user email
  final submitted = false.obs; // form submit attempt flag
  final isLoading = false.obs; // loading state for OTP sending
  final errorMessage = ''.obs; // error message if OTP sending fails

  void setEmail(String value) => email.value = value;
  void markSubmitted() => submitted.value = true;

  /// Send OTP to the user's email via Appwrite
  /// Returns true if OTP was sent successfully
  Future<bool> sendOtp() async {
    if (email.value.trim().isEmpty) {
      errorMessage.value = 'Please enter an email address';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await AuthService.instance.sendEmailOTP(email.value.trim());
      
      if (result.success) {
        debugPrint('✅ OTP sent successfully to ${email.value}');
        return true;
      } else {
        errorMessage.value = result.message;
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error sending OTP: $e');
      errorMessage.value = 'Failed to send OTP. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
