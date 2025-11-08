// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:godropme/common%20widgets/custom_button.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';

/// Actions for the Driver/Parent option screen.
/// Exposes callbacks so the screen remains modular and testable.
class DopActions extends StatelessWidget {
  final VoidCallback? onContinueParent;
  final VoidCallback? onContinueDriver;

  const DopActions({this.onContinueParent, this.onContinueDriver, super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = Responsive.screenWidth(context);
    final buttonWidth = Responsive.scaleClamped(
      context,
      screenWidth - 70,
      220,
      screenWidth - 32,
    );
    final buttonHeight = Responsive.scaleClamped(context, 58, 48, 64);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
      child: Column(
        children: [
          CustomButton(
            text: 'Continue as Parents',
            onTap: onContinueParent,
            height: buttonHeight,
            width: buttonWidth,
            // Use default gradient from CustomButton (primary colors)
          ),
          SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),
          // White button variant: use CustomButton but override decoration via
          // providing a plain container via gradient=null and textColor.
          SizedBox(
            width: buttonWidth,
            height: buttonHeight,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.14),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onContinueDriver,
                  child: Center(
                    child: Text(
                      'Continue as Driver',
                      style: AppTypography.onboardButton.copyWith(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
