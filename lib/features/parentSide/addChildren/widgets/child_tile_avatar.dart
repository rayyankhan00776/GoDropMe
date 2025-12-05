import 'dart:io';
import 'package:flutter/material.dart';
import 'package:godropme/common_widgets/appwrite_image.dart';
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

  bool get _isNetworkImage =>
      photoPath != null &&
      photoPath!.isNotEmpty &&
      (photoPath!.startsWith('http://') || photoPath!.startsWith('https://'));

  bool get _hasLocalFile =>
      photoPath != null &&
      photoPath!.isNotEmpty &&
      !_isNetworkImage &&
      File(photoPath!).existsSync();

  bool get _hasPhoto => _isNetworkImage || _hasLocalFile;

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
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: _hasPhoto ? _buildImage() : _buildInitial(),
      ),
    );
  }

  Widget _buildImage() {
    if (_isNetworkImage) {
      return AppwriteImage(
        imageUrl: photoPath!,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        placeholder: Container(
          color: AppColors.grayLight,
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        errorWidget: _buildInitial(),
      );
    } else {
      return Image.file(
        File(photoPath!),
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildInitial() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.gradientPink,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTypography.optionLineSecondary.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
