// Glassy Drawer Button widget - reusable across parent side screens

// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:godropme/theme/colors.dart';

class GlassDrawerButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double size;
  final double borderRadius;
  final Color iconColor;
  final IconData icon;

  const GlassDrawerButton({
    super.key,
    this.onPressed,
    this.size = 45,
    this.borderRadius = 8,
    this.iconColor = AppColors.white,
    this.icon = Icons.menu,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 1),
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.9),
            border: Border.all(
              color: AppColors.primaryDark.withOpacity(0.8),
              width: 0.6,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            // boxShadow: [BoxShadow(color: AppColors.primary, blurRadius: 8)],
          ),
          child: IconButton(
            icon: Icon(icon, color: iconColor, size: 28),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
