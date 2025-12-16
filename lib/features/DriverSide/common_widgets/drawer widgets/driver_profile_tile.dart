// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:godropme/common_widgets/appwrite_image.dart';
import 'package:godropme/features/DriverSide/driverProfile/controllers/driver_profile_controller.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_assets.dart';
import 'package:godropme/utils/app_typography.dart';

class DriverProfileTile extends StatelessWidget {
  final VoidCallback? onTap;
  const DriverProfileTile({super.key, this.onTap});

  Widget _buildLocalAvatar(String? path) {
    // Check if it's a valid local file path
    if (path != null && path.isNotEmpty && !path.startsWith('assets/')) {
      final file = File(path);
      if (file.existsSync()) {
        return ClipOval(
          child: Image.file(file, width: 52, height: 52, fit: BoxFit.cover),
        );
      }
    }
    // Fallback to default SVG avatar
    return ClipOval(
      child: SvgPicture.asset(
        AppAssets.defaultPersonSvg,
        width: 38,
        height: 38,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return ClipOval(
      child: SvgPicture.asset(
        AppAssets.defaultPersonSvg,
        width: 38,
        height: 38,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetX<DriverProfileController>(
      init: Get.isRegistered<DriverProfileController>()
          ? Get.find<DriverProfileController>()
          : Get.put(DriverProfileController()),
      builder: (controller) {
        final hasAppwritePhoto = controller.hasAppwritePhoto;
        final hasLocalImage = controller.hasProfileImage;
        final appwriteUrl = controller.profileImageUrl.value;
        final localPath = controller.profileImagePath.value;
        final displayName = controller.displayName.value;
        final isLoading = controller.isLoading.value;

        return ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : hasAppwritePhoto
                    ? AppwriteImage(
                        imageUrl: appwriteUrl,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(26),
                        placeholder: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                        errorWidget: _buildDefaultAvatar(),
                      )
                    : hasLocalImage
                        ? _buildLocalAvatar(localPath)
                        : _buildDefaultAvatar(),
          ),
          title: isLoading
              ? Container(
                  height: 16,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
              : Text(
                  displayName.isNotEmpty ? displayName : 'Driver',
                  style: AppTypography.optionLineSecondary.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
          subtitle: Text(
            'Driver',
            style: AppTypography.optionLineSecondary.copyWith(
              fontSize: 13,
              color: AppColors.darkGray,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.primary,
            size: 24,
          ),
          onTap: onTap,
        );
      },
    );
  }
}
