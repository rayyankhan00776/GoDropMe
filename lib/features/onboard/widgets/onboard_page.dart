// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:godropme/core/utils/responsive.dart';
import 'package:godropme/core/widgets/custom_button.dart';
import 'package:godropme/core/theme/colors.dart';
import 'package:godropme/core/routes/routes.dart';

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
                const SizedBox(height: 16),
                Text(
                  title,
                  style:
                      titleStyle ??
                      const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                  textAlign: TextAlign.center,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style:
                        subtitleStyle ??
                        const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: AppColors.darkGray,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),

          if (showButton)
            Padding(
              padding: EdgeInsets.only(bottom: bottomButtonPadding),
              child: CustomButton(
                text: 'Get Started',
                onTap: () {
                  Get.offAllNamed(AppRoutes.optionScreen);
                },
                height: 58,
                width: screenWidth - 70,
              ),
            ),
        ],
      ),
    );
  }
}
