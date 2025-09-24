import 'package:flutter/material.dart';
import 'package:godropme/core/utils/app_strings.dart';
import 'package:godropme/core/utils/app_typography.dart';

class DopHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  const DopHeader({super.key, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if ((title ?? AppStrings.dopheading).isNotEmpty)
          Text(
            title ?? AppStrings.dopheading,
            style: AppTypography.optionHeading,
          ),
        const SizedBox(height: 2),
        if ((subtitle ?? AppStrings.dopsubheading).isNotEmpty)
          Text(
            subtitle ?? AppStrings.dopsubheading,
            style: AppTypography.optionLineSecondary,
          ),
      ],
    );
  }
}
