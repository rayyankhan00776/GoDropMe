import 'package:flutter/material.dart';
import 'package:godropme/core/utlis/app_strings.dart';
import 'package:godropme/core/utlis/app_typography.dart';

class PhoneHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;

  const PhoneHeader({this.title, this.subtitle, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((title ?? AppStrings.phoneTitle).isNotEmpty)
          Text(
            title ?? AppStrings.phoneTitle,
            style: AppTypography.optionHeading,
          ),
        const SizedBox(height: 8),
        if ((subtitle ?? AppStrings.phoneSubtitle).isNotEmpty)
          Text(
            subtitle ?? AppStrings.phoneSubtitle,
            style: AppTypography.optionLineSecondary,
          ),
      ],
    );
  }
}
