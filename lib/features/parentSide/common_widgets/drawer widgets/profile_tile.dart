// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:godropme/common_widgets/appwrite_image.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_assets.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/features/parentSide/parentProfile/controllers/parent_profile_controller.dart';

class ProfileTile extends StatelessWidget {
  final VoidCallback? onTap;
  const ProfileTile({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GetX<ParentProfileController>(
      init: Get.isRegistered<ParentProfileController>() 
          ? Get.find<ParentProfileController>() 
          : Get.put(ParentProfileController()),
      builder: (controller) {
        // Show loading state while profile is being fetched
        if (controller.isLoading.value) {
          return _buildLoadingTile();
        }
        
        final profile = controller.profile.value;
        final displayName = (profile?.fullName.isNotEmpty ?? false)
            ? profile!.fullName.trim()
            : AppStrings.drawerProfileNamePlaceholder;
        
        return ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: _buildAvatar(controller),
          title: Text(
            displayName,
            style: AppTypography.optionLineSecondary.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          subtitle: Text(
            AppStrings.drawerProfileRoleParent,
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

  /// Build loading placeholder tile
  Widget _buildLoadingTile() {
    return ListTile(
      contentPadding: const EdgeInsets.all(12),
      leading: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.grayLight.withValues(alpha: 0.5),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      title: Container(
        height: 16,
        width: 120,
        decoration: BoxDecoration(
          color: AppColors.grayLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      subtitle: Container(
        height: 12,
        width: 60,
        margin: const EdgeInsets.only(top: 6),
        decoration: BoxDecoration(
          color: AppColors.grayLight.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: AppColors.grayLight,
        size: 24,
      ),
    );
  }

  Widget _buildAvatar(ParentProfileController controller) {
    // Priority: Appwrite URL > Local file > Default avatar
    final imageUrl = controller.profileImageUrl.value;
    final imagePath = controller.profileImagePath.value;
    
    // Check if we have Appwrite URL
    if (imageUrl.isNotEmpty) {
      return ClipOval(
        child: AppwriteImage(
          imageUrl: imageUrl,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          placeholder: Container(
            width: 52,
            height: 52,
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
          errorWidget: _buildDefaultAvatar(),
        ),
      );
    }
    
    // Check if we have local file
    final hasLocalImage = imagePath.isNotEmpty && File(imagePath).existsSync();
    if (hasLocalImage) {
      return CircleAvatar(
        radius: 26,
        backgroundColor: Colors.white,
        backgroundImage: FileImage(File(imagePath)),
        child: null,
      );
    }
    
    // Default avatar
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return CircleAvatar(
      radius: 26,
      backgroundColor: Colors.white,
      child: ClipOval(
        child: SvgPicture.asset(
          AppAssets.defaultPersonSvg,
          width: 38,
          height: 38,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
