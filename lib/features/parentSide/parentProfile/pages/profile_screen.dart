import 'package:flutter/material.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/features/parentSide/common_widgets/parent_drawer_shell.dart';
import 'package:godropme/features/parentSide/parentProfile/widgets/profile_avatar.dart';
import 'package:godropme/features/parentSide/parentProfile/widgets/profile_caption.dart';
import 'package:godropme/features/parentSide/parentProfile/widgets/profile_section.dart';
import 'package:godropme/features/parentSide/parentProfile/widgets/profile_tile.dart';
import 'package:godropme/features/parentSide/parentProfile/controllers/parent_profile_controller.dart';
import 'package:godropme/features/parentSide/addChildren/controllers/add_children_controller.dart';
import 'package:get/get.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controllers are initialized
    final profileController = Get.isRegistered<ParentProfileController>()
        ? Get.find<ParentProfileController>()
        : Get.put(ParentProfileController());
    final childrenController = Get.isRegistered<AddChildrenController>()
        ? Get.find<AddChildrenController>()
        : Get.put(AddChildrenController());
    
    return ParentDrawerShell(
      body: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leave space beneath the overlaid drawer button
                SizedBox(height: Responsive.scaleClamped(context, 60, 48, 72)),

                // Title centered horizontally
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      AppStrings.profileTitle,
                      textAlign: TextAlign.center,
                      style: AppTypography.optionHeading,
                    ),
                  ),
                ),

                // Centered avatar
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ProfileAvatar(
                      size: Responsive.scaleClamped(context, 108, 96, 128),
                    ),
                  ),
                ),

                const ProfileCaption('Account'),
                ProfileSection(
                  children: [
                    // Name tile: reactive to controller
                    Obx(() {
                      final profile = profileController.profile.value;
                      final name = (profile?.fullName ?? '').trim();
                      return ProfileTile(
                        title: 'Name',
                        subtitle: name.isEmpty ? 'Not set' : name,
                        showIosChevron: true,
                        onTap: () => Get.toNamed(AppRoutes.editParentName),
                      );
                    }),
                    // Email tile: reactive to controller
                    Obx(() {
                      final profile = profileController.profile.value;
                      final email = (profile?.email ?? '').trim();
                      return ProfileTile(
                        title: 'Email',
                        subtitle: email.isEmpty ? 'Add email' : email,
                        showIosChevron: false,
                        // onTap: () => Get.toNamed(AppRoutes.editParentEmail),
                      );
                    }),
                    // Phone tile: reactive to controller
                    Obx(() {
                      final profile = profileController.profile.value;
                      final phone = profile?.phone?.national ?? '';
                      return ProfileTile(
                        title: 'Phone',
                        subtitle: phone.isEmpty ? 'Add phone (optional)' : '+92 $phone',
                        showIosChevron: true,
                        onTap: () => Get.toNamed(AppRoutes.editParentPhone),
                      );
                    }),
                    // Children tile: reactive to controller
                    Obx(() {
                      final count = childrenController.children.length;
                      return ProfileTile(
                        title: 'Children',
                        subtitle: '$count added',
                        showIosChevron: true,
                        onTap: () => Get.toNamed(AppRoutes.addChildren),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
