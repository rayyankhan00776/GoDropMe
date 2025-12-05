import 'package:flutter/material.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';

/// A reusable confirmation dialog for settings actions like logout/delete
class SettingsConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final bool isDestructive;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const SettingsConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    this.isDestructive = false,
    this.onConfirm,
    this.onCancel,
  });

  /// Shows the dialog and returns true if confirmed, false otherwise
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SettingsConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  /// Convenience method for logout confirmation
  static Future<bool> showLogoutConfirmation(BuildContext context) {
    return show(
      context: context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      isDestructive: false,
    );
  }

  /// Convenience method for delete account confirmation
  static Future<bool> showDeleteAccountConfirmation(BuildContext context) {
    return show(
      context: context,
      title: 'Delete Account',
      message:
          'This action cannot be undone. All your data including children records will be permanently deleted.',
      confirmText: 'Delete Account',
      isDestructive: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.white,
      title: Text(
        title,
        style: AppTypography.optionHeading,
      ),
      content: Text(
        message,
        style: AppTypography.optionLineSecondary,
      ),
      actions: [
        TextButton(
          onPressed: () {
        Navigator.pop(context, false);
        onCancel?.call();
          },
          child: Text(
        'Cancel',
        style: AppTypography.optionLineSecondary.copyWith(
          color: AppColors.darkGray,
        ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
        Navigator.pop(context, true);
        onConfirm?.call();
          },
          style: ElevatedButton.styleFrom(
        backgroundColor: isDestructive ? Colors.red : AppColors.primary,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
        confirmText,
        style: AppTypography.optionLineSecondary.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
          ),
        ),
      ],
    );
  }
}
