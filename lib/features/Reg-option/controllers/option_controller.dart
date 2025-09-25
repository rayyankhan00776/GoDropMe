import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/core/routes/routes.dart';
// ...existing imports

/// Controller for the Reg-option (Option) screen.
/// Keeps navigation and action handlers centralized so the UI remains dumb.
class OptionController extends GetxController {
  /// Navigate to phone-based continuation flow.
  void continueWithPhone() {
    // Prefer named routes (centralized in `routes.dart`). Use named route
    // consistently — bindings provide controller instances for the target.
    Get.toNamed(AppRoutes.phoneScreen);
    debugPrint(
      'OptionController: continueWithPhone called (navigated via named route)',
    );
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
