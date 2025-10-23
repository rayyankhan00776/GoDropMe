// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/common%20widgets/custom_button.dart';
import 'package:godropme/constants/app_strings.dart';

/// A small reusable alert dialog used by the OTP flow.
class OtpErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;

  const OtpErrorDialog({
    super.key,
    this.title = AppStrings.error,
    required this.message,
    this.buttonText = AppStrings.ok,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Custom dialog to match app's visual language
    return Dialog(
      elevation: 8,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(width: Responsive.scaleClamped(context, 12, 8, 18)),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.onboardTitle.copyWith(
                      fontSize: 18,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),
            Text(
              message,
              style: AppTypography.onboardSubtitle.copyWith(
                color: AppColors.darkGray,
              ),
            ),
            SizedBox(height: Responsive.scaleClamped(context, 18, 12, 28)),
            SizedBox(
              height: 52,
              child: CustomButton(
                text: buttonText,
                onTap: onPressed ?? () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(12),
                height: 52,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
