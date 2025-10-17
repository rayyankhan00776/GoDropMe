import 'package:flutter/material.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';

class TimePickerField extends StatelessWidget {
  final TimeOfDay? time;
  final VoidCallback onPick;
  const TimePickerField({super.key, required this.time, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray, width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppStrings.childPickupTimePref,
              style: AppTypography.optionTerms.copyWith(
                color: AppColors.darkGray,
              ),
            ),
          ),
          Text(
            time?.format(context) ?? AppStrings.timeNotSet,
            style: AppTypography.optionTerms.copyWith(
              color: AppColors.darkGray,
            ),
          ),
          SizedBox(width: Responsive.scaleClamped(context, 8, 6, 12)),
          IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: onPick,
            splashRadius: 22,
          ),
        ],
      ),
    );
  }
}
