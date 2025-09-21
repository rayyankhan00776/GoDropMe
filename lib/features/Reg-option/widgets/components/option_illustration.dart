import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:godropme/core/utlis/app_assets.dart';
import 'package:godropme/core/utlis/app_strings.dart';
import 'package:godropme/core/utlis/app_typography.dart';

class OptionIllustration extends StatelessWidget {
  const OptionIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 300,
          height: 300,
          child: SvgPicture.asset(
            AppAssets.optionIllustration,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.optionLine1,
          textAlign: TextAlign.center,
          style: AppTypography.optionLinePrimary,
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.optionLine2,
          textAlign: TextAlign.center,
          style: AppTypography.optionLineSecondary,
        ),
      ],
    );
  }
}
