// Consistent version label for both Parent and Driver drawers
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';

class DrawerVersionLabel extends StatelessWidget {
  const DrawerVersionLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Center(
        child: Text(
          AppStrings.drawerVersionLabel,
          style: AppTypography.optionLineSecondary.copyWith(
            color: AppColors.darkGray,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
