import 'dart:io';
import 'package:flutter/material.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/theme/colors.dart';

class ChildTileAvatar extends StatelessWidget {
  final String initial;
  final String? photoPath;
  
  const ChildTileAvatar({
    super.key, 
    required this.initial,
    this.photoPath,
  });

  bool get _hasPhoto =>
      photoPath != null &&
      photoPath!.isNotEmpty &&
      File(photoPath!).existsSync();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _hasPhoto ? null : const LinearGradient(
          colors: AppColors.gradientPink,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        image: _hasPhoto
            ? DecorationImage(
                image: FileImage(File(photoPath!)),
                fit: BoxFit.cover,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: _hasPhoto
          ? null
          : Text(
              initial,
              style: AppTypography.optionLineSecondary.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}
