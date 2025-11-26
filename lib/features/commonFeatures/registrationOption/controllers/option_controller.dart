import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/services/Terms_uri_opener.dart';
// ...existing imports

/// Controller for the Reg-option (Option) screen.
/// Keeps navigation and action handlers centralized so the UI remains dumb.
class OptionController extends GetxController {
  /// Navigate to phone-based continuation flow.
  void continueWithPhone() {
    // Prefer named routes (centralized in `routes.dart`). Use named route
    // consistently — bindings provide controller instances for the target.
    Get.toNamed(AppRoutes.emailScreen);
    debugPrint(
      'OptionController: continueWithPhone called (navigated via named route)',
    );
  }

  /// Open the Terms and Conditions page.
  void openTerms() async {
    termsUriOpener();
  }

  /// Open the Privacy Policy page.
  void openPrivacy() async {
    termsUriOpener();
  }
}
