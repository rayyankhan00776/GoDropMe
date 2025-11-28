// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/constants/button_dimensions.dart';

/// A reusable button widget for the app.
///
/// Customizable [height], [width], [text], [onTap], and optional [gradient] and [borderRadius].
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final double height;
  final double width;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final Widget? leading;
  final Color? textColor;

  const CustomButton({
    required this.text,
    this.onTap,
    this.height = AppButtonDimensions.primaryHeight,
    this.width = double.infinity,
    this.gradient,
    this.borderRadius,
    this.leading,
    this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          gradient:
              gradient ??
              const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.buttonGradient,
              ),
          color: gradient == null ? null : null,
          borderRadius:
              borderRadius ??
              BorderRadius.circular(AppButtonDimensions.borderRadius),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF756AED).withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: borderRadius ?? BorderRadius.circular(20),
            onTap: onTap,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
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
                      color: textColor ?? AppColors.white,
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
