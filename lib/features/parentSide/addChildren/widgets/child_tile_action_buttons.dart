import 'package:flutter/material.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/common%20widgets/custom_button.dart';

class ActionButtonsRow extends StatelessWidget {
  final VoidCallback onFindDriver;
  final VoidCallback? onDelete;
  const ActionButtonsRow({
    super.key,
    required this.onFindDriver,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
