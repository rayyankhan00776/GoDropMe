import 'package:flutter/material.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';

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
        SizedBox(height: Responsive.scaleClamped(context, 2, 1, 6)),
        if ((subtitle ?? AppStrings.phoneSubtitle).isNotEmpty)
          Text(
            subtitle ?? AppStrings.phoneSubtitle,
            style: AppTypography.optionLineSecondary,
          ),
      ],
    );
  }
}
