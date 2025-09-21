// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/features/Reg-option/widgets/option_content.dart';
import 'package:godropme/features/Reg-option/controllers/option_controller.dart';
import 'package:godropme/core/utils/responsive.dart';

class OptionScreen extends StatelessWidget {
  const OptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available via binding; find it here for callbacks
    final OptionController ctrl = Get.find();

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Use a static layout: header + illustration take flexible space,
            // actions stay anchored near the bottom. This prevents scrolling
            // while remaining responsive across screen sizes.

            return Column(
              children: [
                // Keep the main content flexible so it can shrink/grow as needed.
                Expanded(
                  child: OptionContent(
                    onContinuePhone: ctrl.continueWithPhone,
                    onContinueGoogle: ctrl.continueWithGoogle,
                    onTermsTap: ctrl.openTerms,
                    onPrivacyTap: ctrl.openPrivacy,
                  ),
                ),

                // Add a small safe gap from bottom based on available height.
                SizedBox(height: Responsive.scaleClamped(context, 12, 8, 28)),
              ],
            );
          },
        ),
      ),
    );
  }
}
