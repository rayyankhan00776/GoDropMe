import 'package:flutter/material.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';

class DopHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  const DopHeader({super.key, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder + FittedBox so long headings/subheadings scale down
    // on small screens instead of wrapping to multiple lines. This keeps the
    // visual design intact while avoiding layout breaks on narrow devices.
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if ((title ?? AppStrings.dopheading).isNotEmpty)
              SizedBox(
                width: maxW,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Text(
                    title ?? AppStrings.dopheading,
                    style: AppTypography.optionHeading,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            SizedBox(height: Responsive.scaleClamped(context, 6, 4, 12)),
            if ((subtitle ?? AppStrings.dopsubheading).isNotEmpty)
              SizedBox(
                width: maxW,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Text(
                    subtitle ?? AppStrings.dopsubheading,
                    style: AppTypography.optionLineSecondary,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
