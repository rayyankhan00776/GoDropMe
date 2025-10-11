// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:godropme/utils/app_strings.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';

class ParentnameHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  const ParentnameHeader({super.key, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((title ?? AppStrings.parentNameTitle).isNotEmpty)
          Text(
            title ?? AppStrings.parentNameTitle,
            style: AppTypography.optionHeading,
          ),
        SizedBox(height: Responsive.scaleClamped(context, 2, 1, 6)),
        if ((subtitle ?? AppStrings.parentNameSubtitle).isNotEmpty)
          Text(
            subtitle ?? AppStrings.parentNameSubtitle,
            style: AppTypography.optionLineSecondary,
          ),
      ],
    );
  }
}
