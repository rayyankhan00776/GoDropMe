import 'package:flutter/material.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/core/theme/colors.dart';
import 'package:godropme/core/theme/button_dimensions.dart';

/// A white-background button used for "Continue with Google".
class GoogleButton extends StatelessWidget {
  final String text;
  final Widget? leading;
  final VoidCallback? onTap;
  final double height;
  final double width;

  const GoogleButton({
    required this.text,
    this.leading,
    this.onTap,
    this.height = AppButtonDimensions.primaryHeight,
    this.width = double.infinity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppButtonDimensions.borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppButtonDimensions.borderRadius),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(
                AppButtonDimensions.borderRadius,
              ),
              border: Border.all(color: Colors.black54, width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[
                    leading!,
                    SizedBox(
                      width: Responsive.scaleClamped(context, 12, 8, 20),
                    ),
                  ],
                  Text(
                    text,
                    style: AppTypography.onboardButton.copyWith(
                      color: AppColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
