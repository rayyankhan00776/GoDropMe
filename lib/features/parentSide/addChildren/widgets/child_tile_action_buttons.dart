import 'package:flutter/material.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/common_widgets/custom_button.dart';

class ActionButtonsRow extends StatelessWidget {
  final VoidCallback onFindDriver;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkAbsent;
  final bool isAbsentToday;
  
  const ActionButtonsRow({
    super.key,
    required this.onFindDriver,
    this.onDelete,
    this.onMarkAbsent,
    this.isAbsentToday = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Absent Today button row
        if (onMarkAbsent != null) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onMarkAbsent,
              icon: Icon(
                isAbsentToday ? Icons.check_circle : Icons.person_off_outlined,
                size: 18,
              ),
              label: Text(isAbsentToday ? 'Marked Absent Today' : 'Mark Absent Today'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isAbsentToday ? Colors.orange : Colors.grey,
                ),
                foregroundColor: isAbsentToday ? Colors.orange : Colors.grey.shade700,
                backgroundColor: isAbsentToday 
                    ? Colors.orange.withValues(alpha: 0.1) 
                    : Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(height: Responsive.scaleClamped(context, 12, 8, 16)),
        ],
        Center(
          child: SizedBox(
            width: Responsive.wp(context, 70),
            child: CustomButton(text: 'Find Driver', onTap: onFindDriver),
          ),
        ),
        SizedBox(height: Responsive.scaleClamped(context, 12, 8, 16)),
        Center(
          child: TextButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: Text(
              'Delete',
              style: AppTypography.optionTerms.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: Responsive.scaleClamped(context, 12, 8, 16)),
      ],
    );
  }
}
