// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:godropme/core/theme/colors.dart';
import 'package:godropme/core/utils/responsive.dart';
import 'package:godropme/core/widgets/custom_button.dart';
import 'package:godropme/core/theme/button_dimensions.dart';

/// A reusable bottom bar that shows a step indicator (e.g. "1 of 4"),
/// a small previous/rounded icon button and a primary Next button.
///
/// The Next button uses the project's `CustomButton` so it can be reused
/// across screens. No navigation is performed here; the [onNext] callback
/// is invoked when Next is tapped.
class ProgressNextBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  /// Background color for the small previous button. Defaults to AppColors.grayLight.
  final Color? previousBackgroundColor;

  /// Icon color for the small previous button. Defaults to AppColors.primary.
  final Color? previousIconColor;

  /// Size for the small previous button square. Defaults to 51.
  final double previousButtonSize;

  const ProgressNextBar({
    super.key,
    this.currentStep = 1,
    this.totalSteps = 4,
    this.onNext,
    this.onPrevious,
    this.previousBackgroundColor,
    this.previousIconColor,
    this.previousButtonSize = 51,
  });

  @override
  Widget build(BuildContext context) {
    final String stepText = '$currentStep of $totalSteps';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.scaleClamped(context, 16, 12, 24),
        vertical: Responsive.scaleClamped(context, 12, 8, 20),
      ),
      color: Colors.transparent,
      child: Row(
        children: [
          // Step text + progress bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stepText,
                  style: TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: Responsive.scaleClamped(context, 8, 6, 12)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (currentStep / totalSteps).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: AppColors.grayLight.withOpacity(0.6),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: Responsive.scaleClamped(context, 12, 8, 16)),

          // Small rounded previous button (customizable colors/size)
          Container(
            width: Responsive.scaleClamped(context, previousButtonSize, 40, 80),
            height: Responsive.scaleClamped(
              context,
              previousButtonSize,
              40,
              80,
            ),
            decoration: BoxDecoration(
              color: previousBackgroundColor ?? AppColors.grayLight,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: onPrevious,
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: previousIconColor ?? AppColors.primary,
                size: 18,
              ),
              splashRadius: 20,
            ),
          ),

          SizedBox(width: Responsive.scaleClamped(context, 7, 4, 12)),

          // Next button (reuses CustomButton)
          SizedBox(
            width: Responsive.scaleClamped(context, 140, 100, 220),
            child: CustomButton(
              text: 'Next',
              onTap: onNext,
              height: 53,
              borderRadius: BorderRadius.circular(
                AppButtonDimensions.borderRadius,
              ),
              // ensure primary color gradient is used by overriding gradient
              gradient: const LinearGradient(
                colors: [AppColors.primaryLight, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
