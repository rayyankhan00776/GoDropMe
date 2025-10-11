import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:godropme/core/utils/app_strings.dart';
import 'package:godropme/core/utils/app_typography.dart';
import 'package:godropme/core/theme/colors.dart';

class OptionTerms extends StatelessWidget {
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  const OptionTerms({this.onTermsTap, this.onPrivacyTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
                  TapGestureRecognizer()..onTap = () => onTermsTap?.call(),
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: AppStrings.optionPrivacyText,
              style: AppTypography.optionTerms.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              recognizer:
                  TapGestureRecognizer()..onTap = () => onPrivacyTap?.call(),
            ),
          ],
        ),
      ),
    );
  }
}
