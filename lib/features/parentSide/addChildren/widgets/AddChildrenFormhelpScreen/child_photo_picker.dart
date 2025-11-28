// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';

class ChildPhotoPicker extends StatelessWidget {
  final String? imagePath;
  final ValueChanged<String?> onImageSelected;

  const ChildPhotoPicker({
    super.key,
    this.imagePath,
    required this.onImageSelected,
  });

  bool get _hasImage =>
      imagePath != null &&
      imagePath!.isNotEmpty &&
      File(imagePath!).existsSync();

  Future<void> _showImagePickerOptions(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grayLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Child Photo',
                style: AppTypography.optionHeading.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_outlined,
                      color: AppColors.primary),
                ),
                title:
                    Text('Take Photo', style: AppTypography.optionLineSecondary),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_outlined,
                      color: AppColors.primary),
                ),
                title: Text('Choose from Gallery',
                    style: AppTypography.optionLineSecondary),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.gallery);
                },
              ),
              if (_hasImage)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  title: Text(
                    'Remove Photo',
                    style: AppTypography.optionLineSecondary.copyWith(
                      color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onImageSelected(null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        onImageSelected(image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImagePickerOptions(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Avatar/placeholder
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _hasImage ? null : AppColors.grayLight,
                image: _hasImage
                    ? DecorationImage(
                        image: FileImage(File(imagePath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
                border: Border.all(
                  color: _hasImage ? AppColors.primary : AppColors.gray,
                  width: 2,
                ),
              ),
              child: _hasImage
                  ? null
                  : const Icon(
                      Icons.person_outline_rounded,
                      size: 28,
                      color: AppColors.darkGray,
                    ),
            ),
            const SizedBox(width: 16),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _hasImage ? 'Photo added' : 'Add child photo',
                    style: AppTypography.optionLineSecondary.copyWith(
                      color: _hasImage ? AppColors.black : AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _hasImage ? 'Tap to change' : 'Tap to select',
                    style: AppTypography.helperSmall.copyWith(
                      color: AppColors.darkGray,
                    ),
                  ),
                ],
              ),
            ),
            // Icon
            Icon(
              _hasImage ? Icons.check_circle : Icons.add_a_photo_outlined,
              color: _hasImage ? AppColors.primary : AppColors.darkGray,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
