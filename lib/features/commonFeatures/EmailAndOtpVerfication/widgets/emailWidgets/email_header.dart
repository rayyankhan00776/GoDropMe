import 'package:flutter/material.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';

/// Deprecated header (previously phone-specific). Updated to reference
/// email constants so the file doesn't break compilation if still imported.
/// Prefer inline headers in the new email screen implementation.
class EmailHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;

  const EmailHeader({this.title, this.subtitle, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((title ?? AppStrings.emailTitle).isNotEmpty)
          Text(
            title ?? AppStrings.emailTitle,
            style: AppTypography.optionHeading,
          ),
        SizedBox(height: Responsive.scaleClamped(context, 2, 1, 6)),
        if ((subtitle ?? AppStrings.emailSubtitle).isNotEmpty)
          Text(
            subtitle ?? AppStrings.emailSubtitle,
            style: AppTypography.optionLineSecondary,
          ),
      ],
    );
  }
}
