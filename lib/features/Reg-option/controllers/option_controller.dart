import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/core/routes/routes.dart';
import 'package:godropme/features/phoneVerfication/pages/phone_Screen.dart';

/// Controller for the Reg-option (Option) screen.
/// Keeps navigation and action handlers centralized so the UI remains dumb.
class OptionController extends GetxController {
  /// Navigate to phone-based continuation flow.
  void continueWithPhone() {
    // Prefer named routes (centralized in `routes.dart`). If for any reason
    // named-route resolution fails at runtime (middleware or redirect),
    // fall back to direct widget navigation so the app doesn't crash.
    try {
      Get.toNamed(AppRoutes.phoneScreen);
    } catch (e) {
      debugPrint('Named route failed, falling back to direct navigation: $e');
      Get.to(() => const PhoneScreen());
    }
    debugPrint('OptionController: continueWithPhone called');
  }

  /// Continue using Google sign-in.
  void continueWithGoogle() {
    // TODO: integrate Google Sign-In
    debugPrint('OptionController: continueWithGoogle called');
  }

  /// Open the Terms and Conditions page.
  void openTerms() {
    // TODO: navigate to terms page when implemented
    debugPrint('OptionController: openTerms called');
  }

  /// Open the Privacy Policy page.
  void openPrivacy() {
    // TODO: navigate to privacy page when implemented
    debugPrint('OptionController: openPrivacy called');
  }
}
