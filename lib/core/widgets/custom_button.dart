// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:godropme/core/utlis/app_typography.dart';
import 'package:godropme/core/theme/colors.dart';

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

  const CustomButton({
    required this.text,
    this.onTap,
    this.height = 56,
    this.width = double.infinity,
    this.gradient,
    this.borderRadius,
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
          borderRadius: borderRadius ?? BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF756AED).withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: borderRadius ?? BorderRadius.circular(40),
            onTap: onTap,
            child: Center(
              child: Text(
                text,
                style: AppTypography.onboardButton.copyWith(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
