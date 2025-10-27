import 'package:flutter/material.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';

class ProfileTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showIosChevron;
  final bool isDestructive;
  final VoidCallback? onTap;

  const ProfileTile({
    super.key,
    required this.title,
    this.subtitle,
    this.showIosChevron = false,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      title: Text(
        title,
        style: AppTypography.optionLineSecondary.copyWith(
          color: isDestructive ? Colors.red : AppColors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: AppTypography.helperSmall),
      trailing: showIosChevron
          ? const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.black38,
            )
          : null,
    );
  }
}
