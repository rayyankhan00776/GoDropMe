import 'package:flutter/material.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/features/parentSide/common widgets/parent_drawer_shell.dart';
import 'package:godropme/features/parentSide/parentProfile/widgets/profile_avatar.dart';
import 'package:godropme/features/parentSide/parentProfile/widgets/profile_caption.dart';
import 'package:godropme/features/parentSide/parentProfile/widgets/profile_section.dart';
import 'package:godropme/features/parentSide/parentProfile/widgets/profile_tile.dart';
import 'package:get/get.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/models/parent_profile.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    // Name tile: show stored parent name as subtitle
                    FutureBuilder<ParentProfile>(
                      future: ParentProfile.loadFromLocal(),
                      builder: (context, snapshot) {
                        final name = (snapshot.data?.fullName ?? '').trim();
                        return ProfileTile(
                          title: 'Name',
                          subtitle: name.isEmpty ? 'Not set' : name,
                          showIosChevron: true,
                        );
                      },
                    ),
                    // Email tile
                    const ProfileTile(
                      title: 'Email',
                      subtitle: 'Add email',
                      showIosChevron: true,
                    ),
                    // Children tile: show count and navigate to Add Children screen
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: LocalStorage.getJsonList(
                        StorageKeys.childrenList,
                      ),
                      builder: (context, snapshot) {
                        final count = snapshot.data?.length ?? 0;
                        return ProfileTile(
                          title: 'Children',
                          subtitle: '$count added',
                          showIosChevron: true,
                          onTap: () => Get.toNamed(AppRoutes.addChildren),
                        );
                      },
                    ),
                    // City tile
                    const ProfileTile(
                      title: 'City',
                      subtitle: 'Add a city',
                      showIosChevron: true,
                    ),
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
