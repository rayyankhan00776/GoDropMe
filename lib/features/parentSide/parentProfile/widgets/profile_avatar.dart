// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/common_widgets/appwrite_image.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/features/parentSide/parentProfile/controllers/parent_profile_controller.dart';

class ProfileAvatar extends StatelessWidget {
  final double size;
  final bool editable;
  
  const ProfileAvatar({
    super.key, 
    this.size = 108,
    this.editable = true,
  });

  void _showImagePickerOptions(BuildContext context) {
    final controller = Get.find<ParentProfileController>();
    
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

  @override
  Widget build(BuildContext context) {
    return GetX<ParentProfileController>(
      init: Get.isRegistered<ParentProfileController>() 
          ? Get.find<ParentProfileController>() 
          : Get.put(ParentProfileController()),
      builder: (controller) {
        return GestureDetector(
          onTap: editable ? () => _showImagePickerOptions(context) : null,
          child: Stack(
            children: [
              _buildAvatarContainer(controller),
              // Edit badge
              if (editable)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      controller.hasProfileImage ? Icons.edit : Icons.add_a_photo_outlined,
                      size: size * 0.15,
                      color: Colors.white,
                    ),
                  ),
                ),
              // Syncing indicator
              if (controller.isSyncing.value)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatarContainer(ParentProfileController controller) {
    final imageUrl = controller.profileImageUrl.value;
    final imageFile = controller.profileImageFile;
    
    // Priority: Network URL > Local file > Placeholder
    final hasNetworkImage = imageUrl.isNotEmpty;
    final hasLocalFile = imageFile != null && imageFile.existsSync();
    final hasImage = hasNetworkImage || hasLocalFile;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
        border: Border.all(
          color: hasImage ? AppColors.primary : Colors.grey.shade400,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: hasNetworkImage
            ? AppwriteImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: size,
                height: size,
                placeholder: Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                errorWidget: _buildPlaceholder(),
              )
            : hasLocalFile
                ? Image.file(
                    imageFile,
                    fit: BoxFit.cover,
                    width: size,
                    height: size,
                  )
                : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.person_outline_rounded,
        size: size * 0.4,
        color: AppColors.darkGray.withValues(alpha: 0.5),
      ),
    );
  }
}
