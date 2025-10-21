// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/features/commonFeatures/registrationOption/widgets/option_header.dart';
import 'package:godropme/features/commonFeatures/registrationOption/widgets/option_illustration.dart';
import 'package:godropme/features/commonFeatures/registrationOption/widgets/option_actions.dart';
import 'package:godropme/features/commonFeatures/registrationOption/widgets/option_terms.dart';
import 'package:godropme/features/commonFeatures/registrationOption/controllers/option_controller.dart';
import 'package:godropme/utils/responsive.dart';

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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const OptionHeader(),
                        SizedBox(
                          height: Responsive.scaleClamped(context, 6, 6, 14),
                        ),

                        Expanded(
                          child: Center(
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [const OptionIllustration()],
                              ),
                            ),
                          ),
                        ),

                        OptionActions(onContinuePhone: ctrl.continueWithPhone),

                        SizedBox(
                          height: Responsive.scaleClamped(context, 5, 4, 12),
                        ),

                        OptionTerms(
                          onTermsTap: ctrl.openTerms,
                          onPrivacyTap: ctrl.openPrivacy,
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).viewPadding.bottom + 8,
                        ),
                      ],
                    ),
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
