import 'package:flutter/material.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/theme/colors.dart';

class DriverProfileCaption extends StatelessWidget {
  final String text;
  const DriverProfileCaption(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 8, top: 14),
      child: Text(
        text,
        style: AppTypography.helperSmall.copyWith(
          color: AppColors.darkGray,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
