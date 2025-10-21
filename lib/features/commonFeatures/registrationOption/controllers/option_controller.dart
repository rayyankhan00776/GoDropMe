import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/routes.dart';
import 'package:url_launcher/url_launcher.dart';
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

  /// Open the Terms and Conditions page.
  void openTerms() async {
    final Uri url = Uri.parse('https://rayonixsolutions.com/privacy-policy');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Handle error
      print('Could not launch $url');
    }
  }

  /// Open the Privacy Policy page.
  void openPrivacy() async {
    final Uri url = Uri.parse('https://rayonixsolutions.com/privacy-policy');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Handle error
      print('Could not launch $url');
    }
  }
}
