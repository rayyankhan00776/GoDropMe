import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:godropme/core/utlis/app_assets.dart';
import 'package:godropme/core/utlis/app_strings.dart';
import 'package:godropme/core/utlis/app_typography.dart';
import 'package:godropme/core/widgets/custom_button.dart';
import 'package:godropme/core/widgets/google_button.dart';
import 'package:godropme/core/theme/colors.dart';
// ...existing imports above

class OptionContent extends StatelessWidget {
  final VoidCallback? onContinuePhone;
  final VoidCallback? onContinueGoogle;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  const OptionContent({
    this.onContinuePhone,
    this.onContinueGoogle,
    this.onTermsTap,
    this.onPrivacyTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 5),
          // Heading
          Center(
            child: Text(
              AppStrings.optionHeading,
              style: AppTypography.optionHeading,
            ),
          ),

          const SizedBox(height: 34),

          // SVG Illustration
          Center(
            child: SizedBox(
              width: 300,
              height: 300,
              child: SvgPicture.asset(
                AppAssets.optionIllustration,
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Two descriptive lines under the illustration
          const SizedBox(height: 8),
          Text(
            AppStrings.optionLine1,
            textAlign: TextAlign.center,
            style: AppTypography.optionLinePrimary,
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.optionLine2,
            textAlign: TextAlign.center,
            style: AppTypography.optionLineSecondary,
          ),

          const SizedBox(height: 160),

          // Primary button - Continue with Phone
          CustomButton(
            text: AppStrings.continueWithPhone,
            onTap: onContinuePhone,
            height: 57,
            width: screenWidth,
            borderRadius: BorderRadius.circular(20),
          ),

          const SizedBox(height: 12),

          // Secondary white Google button
          GoogleButton(
            text: AppStrings.continueWithGoogle,
            onTap: onContinueGoogle,
            height: 57,
            width: screenWidth,
            leading: Image.asset(
              AppAssets.google,
              width: 24,
              height: 24,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 16),

          // Terms & Conditions text with clickable spans
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTypography.optionTerms,
                children: [
                  TextSpan(text: AppStrings.optionTermsPrefix),
                  TextSpan(
                    text: AppStrings.optionTermsText,
                    style: AppTypography.optionTerms.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {
                            if (onTermsTap != null) onTermsTap!();
                          },
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: AppStrings.optionPrivacyText,
                    style: AppTypography.optionTerms.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {
                            if (onPrivacyTap != null) onPrivacyTap!();
                          },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
