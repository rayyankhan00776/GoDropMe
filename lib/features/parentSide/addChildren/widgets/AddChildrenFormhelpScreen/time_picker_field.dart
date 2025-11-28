import 'package:flutter/material.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';

class TimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback onPick;
  const TimePickerField({
    super.key,
    required this.label,
    required this.time,
    required this.onPick,
  });

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
              label,
              style: AppTypography.optionTerms.copyWith(
                color: AppColors.darkGray,
              ),
            ),
          ),
          Text(
            time?.format(context) ?? 'Not set',
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
