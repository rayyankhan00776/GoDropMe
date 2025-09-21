import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:godropme/core/utlis/app_assets.dart';
import 'package:godropme/core/utlis/app_strings.dart';
import 'package:godropme/core/utlis/app_typography.dart';
import 'package:godropme/core/utils/responsive.dart';

class OptionIllustration extends StatelessWidget {
  const OptionIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = Responsive.screenWidth(context);
    final illustrationSize = (screenWidth * 0.65).clamp(220.0, 340.0);
    final headingFontSize = Responsive.scaleClamped(context, 32, 28, 34);
    final subFontSize = Responsive.scaleClamped(context, 21, 18, 22);

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
  }
}
