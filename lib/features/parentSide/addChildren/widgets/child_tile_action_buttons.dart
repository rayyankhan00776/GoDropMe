import 'package:flutter/material.dart';
import 'package:godropme/features/parentSide/addChildren/controllers/add_children_controller.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/common_widgets/custom_button.dart';

class ActionButtonsRow extends StatelessWidget {
  final VoidCallback onFindDriver;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkAbsent;
  final bool isAbsentToday;
  final AbsentButtonState absentButtonState;
  
  const ActionButtonsRow({
    super.key,
    required this.onFindDriver,
    this.onDelete,
    this.onMarkAbsent,
    this.isAbsentToday = false,
    this.absentButtonState = AbsentButtonState.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Absent Today button row
        if (onMarkAbsent != null) ...[
          _buildAbsentButton(context),
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
  
  Widget _buildAbsentButton(BuildContext context) {
    // Determine button state
    final bool isEnabled;
    final String label;
    final IconData icon;
    final Color foregroundColor;
    final Color? backgroundColor;
    final Color borderColor;
    
    switch (absentButtonState) {
      case AbsentButtonState.loading:
        isEnabled = false;
        label = 'Loading...';
        icon = Icons.hourglass_empty;
        foregroundColor = Colors.grey;
        backgroundColor = null;
        borderColor = Colors.grey.shade300;
        
      case AbsentButtonState.noService:
        isEnabled = false;
        label = 'No active service';
        icon = Icons.no_accounts_outlined;
        foregroundColor = Colors.grey;
        backgroundColor = null;
        borderColor = Colors.grey.shade300;
        
      case AbsentButtonState.noTrips:
        isEnabled = false;
        label = 'No trips today';
        icon = Icons.event_busy_outlined;
        foregroundColor = Colors.grey;
        backgroundColor = null;
        borderColor = Colors.grey.shade300;
        
      case AbsentButtonState.canMarkAbsent:
        isEnabled = true;
        label = 'Mark Absent Today';
        icon = Icons.person_off_outlined;
        foregroundColor = Colors.grey.shade700;
        backgroundColor = null;
        borderColor = Colors.grey;
        
      case AbsentButtonState.alreadyAbsent:
        isEnabled = false;
        label = 'Marked Absent Today';
        icon = Icons.check_circle;
        foregroundColor = Colors.orange;
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        borderColor = Colors.orange;
        
      case AbsentButtonState.tripInProgress:
        isEnabled = false;
        label = 'Trip in progress';
        icon = Icons.directions_bus;
        foregroundColor = Colors.blue;
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        borderColor = Colors.blue;
        
      case AbsentButtonState.tripsCompleted:
        isEnabled = false;
        label = 'Trips completed';
        icon = Icons.check_circle_outline;
        foregroundColor = Colors.green;
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        borderColor = Colors.green;
    }
    
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isEnabled ? onMarkAbsent : null,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor),
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
          disabledForegroundColor: foregroundColor.withValues(alpha: 0.7),
          disabledBackgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
