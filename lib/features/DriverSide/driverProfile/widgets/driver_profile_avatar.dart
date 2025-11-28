// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:godropme/features/driverSide/driverProfile/controllers/driver_profile_controller.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_assets.dart';
import 'package:godropme/utils/app_typography.dart';

class DriverProfileAvatar extends StatelessWidget {
  final double size;
  final String? imagePath;
  final bool editable;
  
  const DriverProfileAvatar({
    super.key, 
    this.size = 108, 
    this.imagePath,
    this.editable = false,
  });

  void _showImagePickerOptions(BuildContext context) {
    final controller = Get.find<DriverProfileController>();
    
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
                'Profile Photo',
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
                  child: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                ),
                title: Text('Take Photo', style: AppTypography.optionLineSecondary),
                onTap: () {
                  Navigator.pop(context);
                  controller.takeProfilePhoto();
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                ),
                title: Text('Choose from Gallery', style: AppTypography.optionLineSecondary),
                onTap: () {
                  Navigator.pop(context);
                  controller.pickProfileImage();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, String? path) {
    // If it's an asset placeholder or null/empty, show default SVG
    if (path == null || path.isEmpty || path.startsWith('assets/')) {
      return ClipOval(
        child: SvgPicture.asset(
          AppAssets.defaultPersonSvg,
          width: size * 0.7,
          height: size * 0.7,
          fit: BoxFit.cover,
        ),
      );
    }

    // Avoid synchronous disk I/O in build; rely on errorBuilder fallback.
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final target = (size * dpr).clamp(64, 1024).round();
    return ClipOval(
      child: Image.file(
        File(path),
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: target,
        cacheHeight: target,
        filterQuality: FilterQuality.low,
        errorBuilder: (context, error, stack) => SvgPicture.asset(
          AppAssets.defaultPersonSvg,
          width: size * 0.7,
          height: size * 0.7,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If editable, use GetX controller for reactive updates
    if (editable) {
      return GetX<DriverProfileController>(
        init: Get.isRegistered<DriverProfileController>()
            ? Get.find<DriverProfileController>()
            : Get.put(DriverProfileController()),
        builder: (controller) {
          final hasImage = controller.hasProfileImage;
          final imageFile = controller.profileImageFile;

          return GestureDetector(
            onTap: () => _showImagePickerOptions(context),
            child: Stack(
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                    border: Border.all(
                      color: hasImage ? AppColors.primary : Colors.grey.shade400,
                      width: 2,
                    ),
                    image: hasImage && imageFile != null
                        ? DecorationImage(
                            image: FileImage(imageFile),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: hasImage
                      ? null
                      : Center(
                          child: Icon(
                            Icons.person_outline_rounded,
                            size: size * 0.4,
                            color: Colors.grey.shade500,
                          ),
                        ),
                ),
                // Edit icon overlay
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: size * 0.15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    // Non-editable mode: use provided imagePath or fetch from storage
    if (imagePath != null) {
      return RepaintBoundary(
        child: SizedBox(
          width: size,
          height: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
              border: Border.all(color: Colors.grey.shade400, width: 2),
            ),
            child: Center(child: _buildAvatar(context, imagePath)),
          ),
        ),
      );
    }
    // Fallback: fetch from storage if no path was passed
    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: FutureBuilder<Map<String, dynamic>?>(
          future: LocalStorage.getJson(StorageKeys.personalInfo),
          builder: (context, snapshot) {
            final path = snapshot.data?['imagePath'] as String?;
            return DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.grey.shade400, width: 2),
              ),
              child: Center(child: _buildAvatar(context, path)),
            );
          },
        ),
      ),
    );
  }
}
