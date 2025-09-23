import 'package:flutter/material.dart';
import 'package:godropme/core/utlis/app_strings.dart';
import 'package:godropme/core/utlis/app_typography.dart';

class OtpHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  const OtpHeader({super.key, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((title ?? AppStrings.otpTitle).isNotEmpty)
          Text(
            title ?? AppStrings.otpTitle,
            style: AppTypography.optionHeading,
          ),
        const SizedBox(height: 2),
        if ((subtitle ?? AppStrings.otpSubtitle).isNotEmpty)
          Text(
            subtitle ?? AppStrings.otpSubtitle,
            style: AppTypography.optionLineSecondary,
          ),
      ],
    );
  }
}
