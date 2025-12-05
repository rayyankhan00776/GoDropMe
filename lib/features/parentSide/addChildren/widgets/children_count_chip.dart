import 'package:flutter/material.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/theme/colors.dart';

class ChildrenCountChip extends StatelessWidget {
  final int count;
  const ChildrenCountChip({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Text(
        '$count',
        style: AppTypography.optionLineSecondary.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
