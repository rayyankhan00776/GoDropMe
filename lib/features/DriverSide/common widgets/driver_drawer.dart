// Minimal Driver Drawer - empty except GoDropMe heading
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';

class DriverDrawer extends StatelessWidget {
  const DriverDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with centered app name
            _DriverDrawerHeader(),
            // Empty content for now
            Expanded(
              child: Center(
                child: Text('', style: AppTypography.optionLineSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverDrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: Responsive.scaleClamped(context, 80, 80, 80),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(120),
          bottomRight: Radius.circular(120),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          AppStrings.optionHeading,
          style: AppTypography.optionHeading.copyWith(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
