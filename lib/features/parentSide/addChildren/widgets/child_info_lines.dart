import 'package:flutter/material.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/theme/colors.dart';
import 'child_tile_helpers.dart';

class ChildInfoLines extends StatelessWidget {
  final String title;
  final String gender;
  final String age;
  final String school;
  const ChildInfoLines({
    super.key,
    required this.title,
    required this.gender,
    required this.age,
    required this.school,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.optionLineSecondary.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
            if (gender.isNotEmpty) const SizedBox(width: 6),
            if (gender.isNotEmpty) ChildInfoPill(text: gender),
            if (age.isNotEmpty) const SizedBox(width: 6),
            if (age.isNotEmpty) ChildInfoPill(text: formattedAge(age)),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Icon(Icons.school_outlined, size: 16, color: AppColors.gray),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                school.isEmpty ? '-' : school,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.optionTerms.copyWith(
                  color: AppColors.gray,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
