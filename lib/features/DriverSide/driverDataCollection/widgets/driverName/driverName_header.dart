// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:godropme/core/utils/app_strings.dart';
import 'package:godropme/core/utils/app_typography.dart';
import 'package:godropme/core/utils/responsive.dart';

class DrivernameHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  const DrivernameHeader({super.key, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((title ?? AppStrings.driverNameTitle).isNotEmpty)
          Text(
            title ?? AppStrings.driverNameTitle,
            style: AppTypography.optionHeading,
          ),
        SizedBox(height: Responsive.scaleClamped(context, 2, 1, 6)),
        if ((subtitle ?? AppStrings.driverNameSubtitle).isNotEmpty)
          Text(
            subtitle ?? AppStrings.driverNameSubtitle,
            style: AppTypography.optionLineSecondary,
          ),
      ],
    );
  }
}
