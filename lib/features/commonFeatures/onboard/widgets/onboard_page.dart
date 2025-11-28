// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/common_widgets/custom_button.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/utils/app_typography.dart';

/// A single onboarding page widget.
///
/// Inputs:
/// - [image]: file name (without extension) under assets/images/onboard/
/// - [title]: main heading text
/// - [subtitle]: optional subheading text
/// - [showButton]: whether to show the primary "Get Started" button

class OnboardPage extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final bool showButton;

  const OnboardPage({
    required this.image,
    required this.title,
    required this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.showButton = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = Responsive.screenWidth(context);
    // Page layout: image/title/subtitle in Expanded to keep them centered,
    // and the primary button anchored near the bottom. Sizes are responsive
    // but clamped so visual design remains unchanged on medium screens.
    final screenHeight = Responsive.screenHeight(context);
    final imageSize = math.min(screenWidth * 0.75, 280.0);
    final bottomButtonPadding = math.min(screenHeight * 0.08, 60.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: Image.asset(image, fit: BoxFit.contain),
                  ),
                ),
                SizedBox(height: Responsive.scaleClamped(context, 16, 12, 24)),
                Text(
                  title,
                  style: titleStyle ?? AppTypography.onboardTitle,
                  textAlign: TextAlign.center,
                ),
                if (subtitle.isNotEmpty) ...[
                  SizedBox(height: Responsive.scaleClamped(context, 8, 6, 12)),
                  Text(
                    subtitle,
                    style: subtitleStyle ?? AppTypography.onboardSubtitle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),

          if (showButton)
            Padding(
              padding: EdgeInsets.only(bottom: bottomButtonPadding),
              child: Builder(
                builder: (context) {
                  // Compute responsive button size. Use baseline values that
                  // preserve the original design on typical phones but scale
                  // down on very small screens and slightly up on larger ones.
                  final btnHeight = Responsive.scaleClamped(
                    context,
                    58,
                    44,
                    72,
                  );
                  // Keep some horizontal margin; on very small screens prefer
                  // a percent-based width but ensure a readable minimum.
                  final horizontalMargin = Responsive.scaleClamped(
                    context,
                    35,
                    16,
                    60,
                  );
                  final btnWidth =
                      (Responsive.screenWidth(context) - horizontalMargin * 2)
                          .clamp(180.0, Responsive.screenWidth(context));

                  return CustomButton(
                    text: AppStrings.onboardButton,
                    onTap: () {
                      Get.offAllNamed(AppRoutes.optionScreen);
                    },
                    height: btnHeight,
                    width: btnWidth,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
