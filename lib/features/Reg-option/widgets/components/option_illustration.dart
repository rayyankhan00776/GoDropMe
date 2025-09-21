import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:godropme/core/utlis/app_assets.dart';
import 'package:godropme/core/utlis/app_strings.dart';
import 'package:godropme/core/utlis/app_typography.dart';
import 'package:godropme/core/utils/responsive.dart';
import 'dart:math' as math;

class OptionIllustration extends StatelessWidget {
  const OptionIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = Responsive.screenWidth(context);
    final headingFontSize = Responsive.scaleClamped(context, 32, 28, 34);
    final subFontSize = Responsive.scaleClamped(context, 21, 18, 22);

    // Allow the illustration to shrink based on available vertical space to
    // avoid overflow on short screens. We use LayoutBuilder to read the
    // maxHeight offered by the parent and limit the artwork accordingly.
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight =
            constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : Responsive.screenHeight(context);
        // Prefer width-driven size but cap it by available height (60%).
        final widthDriven = (screenWidth * 0.65).clamp(220.0, 340.0);
        final heightCap = math.max(120.0, maxHeight * 0.6);
        final illustrationSize = math.min(widthDriven, heightCap);

        return Column(
          children: [
            SizedBox(
              width: illustrationSize,
              height: illustrationSize,
              child: SvgPicture.asset(
                AppAssets.optionIllustration,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.optionLine1,
              textAlign: TextAlign.center,
              style: AppTypography.optionLinePrimary.copyWith(
                fontSize: headingFontSize,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.optionLine2,
              textAlign: TextAlign.center,
              style: AppTypography.optionLineSecondary.copyWith(
                fontSize: subFontSize,
              ),
            ),
          ],
        );
      },
    );
  }
}
