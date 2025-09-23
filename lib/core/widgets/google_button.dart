import 'package:flutter/material.dart';
import 'package:godropme/core/utils/app_typography.dart';
import 'package:godropme/core/theme/colors.dart';

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
    this.height = 56,
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
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
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
                  if (leading != null) ...[leading!, const SizedBox(width: 12)],
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
