import 'package:flutter/material.dart';
import 'package:godropme/core/utils/app_strings.dart';
import 'package:godropme/core/utils/app_typography.dart';

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
            const SizedBox(height: 6),
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
