import 'package:flutter/material.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';

class AddChildrenEmptyState extends StatelessWidget {
  final VoidCallback onAddChild;
  const AddChildrenEmptyState({super.key, required this.onAddChild});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 96,
              width: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: AppColors.gradientBlue,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.child_care_outlined,
                size: 44,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.noChildrenAdded,
              textAlign: TextAlign.center,
              style: AppTypography.optionHeading.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap below to add your first child. You can always edit later.',
              textAlign: TextAlign.center,
              style: AppTypography.optionLineSecondary.copyWith(
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
                elevation: 6,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onAddChild,
              icon: const Icon(Icons.add),
              label: const Text('Add Child'),
            ),
          ],
        ),
      ),
    );
  }
}
