import 'package:flutter/material.dart';
import 'package:godropme/core/utils/app_strings.dart';
import 'package:godropme/core/utils/app_typography.dart';

class OptionHeader extends StatelessWidget {
  const OptionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
      child: Center(
        child: Text(
          AppStrings.optionHeading,
          style: AppTypography.optionHeading,
        ),
      ),
    );
  }
}
