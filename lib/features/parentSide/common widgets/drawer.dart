// Common Parent drawer used across parent-side screens.
// Derived from the previous MapScreenDrawer without changing design or logic.

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/features/parentSide/common widgets/drawer widgets/drawer_header.dart';
import 'package:godropme/features/parentSide/common widgets/drawer widgets/drawer_card.dart';
import 'package:godropme/features/parentSide/common widgets/drawer widgets/drawer_tile.dart';
import 'package:godropme/features/parentSide/common widgets/drawer widgets/profile_tile.dart';

class ParentDrawer extends StatelessWidget {
  const ParentDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with centered app name
            const ParentDrawerHeader(),

            // Main scrollable content
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  vertical: Responsive.scaleClamped(context, 16, 16, 16),
                  horizontal: Responsive.scaleClamped(context, 8, 8, 8),
                ),
                children: [
                  // Profile tile with polished look
                  DrawerCard(
                    child: ProfileTile(
                      onTap: () => Get.offNamed(AppRoutes.profile),
                    ),
                  ),

                  const SizedBox(height: 7),

                  // Quick actions
                  DrawerCard(
                    child: Column(
                      children: [
                        DrawerTile(
                          icon: Icons.drive_eta_rounded,
                          title: AppStrings.drawerMapScreen,
                          onTap: () => Get.offNamed(AppRoutes.parentmapScreen),
                        ),
                        const Divider(height: 1),
                        DrawerTile(
                          icon: Icons.child_care_rounded,
                          title: AppStrings.drawerAddChildren,
                          onTap: () => Get.offNamed(AppRoutes.addChildren),
                        ),
                        const Divider(height: 1),
                        DrawerTile(
                          icon: Icons.directions_bus_filled_rounded,
                          title: AppStrings.drawerFindDrivers,
                          onTap: () => Get.offNamed(AppRoutes.findDrivers),
                        ),
                        const Divider(height: 1),
                        DrawerTile(
                          icon: Icons.directions_bus_filled_rounded,
                          title: AppStrings.parentChatHeading,
                          onTap: () => Get.offNamed(AppRoutes.parentChat),
                        ),
                        const Divider(height: 1),
                        DrawerTile(
                          icon: Icons.settings_rounded,
                          title: AppStrings.drawerSettings,
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        DrawerTile(
                          icon: Icons.report_gmailerrorred_rounded,
                          title: 'Report',
                          onTap: () => Get.offNamed(AppRoutes.parentReport),
                        ),
                        const Divider(height: 1),
                        DrawerTile(
                          icon: Icons.help_outline_rounded,
                          title: AppStrings.drawerHelp,
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        DrawerTile(
                          icon: Icons.description_outlined,
                          title: AppStrings.drawerTerms,
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        DrawerTile(
                          icon: Icons.logout_rounded,
                          title: AppStrings.drawerLogout,
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        DrawerTile(
                          icon: Icons.star_rate_outlined,
                          title: AppStrings.drawerRateUs,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Center(
                    child: Text(
                      AppStrings.drawerVersionLabel,
                      style: AppTypography.optionLineSecondary.copyWith(
                        color: AppColors.darkGray,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // (No local helpers; composition uses DrawerCard, DrawerTile, ProfileTile,
}
