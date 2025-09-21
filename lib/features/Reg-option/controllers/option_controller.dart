import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Controller for the Reg-option (Option) screen.
/// Keeps navigation and action handlers centralized so the UI remains dumb.
class OptionController extends GetxController {
  /// Navigate to phone-based continuation flow.
  void continueWithPhone() {
    // TODO: replace with actual navigation when phone flow implemented
    // Example: Get.toNamed(AppRoutes.registerWithPhone);
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
