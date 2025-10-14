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
import 'package:godropme/features/parentSide/common widgets/drawer widgets/gradient_action_button.dart';
import 'package:godropme/features/parentSide/common widgets/drawer widgets/outline_action_button.dart';

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

                  const SizedBox(height: 14),

                  // Quick actions
                  DrawerCard(
                    child: Column(
                      children: [
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // App options
                  DrawerCard(
                    child: Column(
                      children: [
                        DrawerTile(
                          icon: Icons.settings_rounded,
                          title: AppStrings.drawerSettings,
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        DrawerTile(
                          icon: Icons.support_agent_rounded,
                          title: AppStrings.drawerSupport,
                          onTap: () {},
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
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Sticky bottom: Rate Us, Logout and version
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Map Screen button (full width) -> Navigate to Map Screen
                  DrawerGradientActionButton(
                    icon: Icons.drive_eta_rounded,
                    label: AppStrings.drawerMapScreen,
                    colors: const [AppColors.primary, AppColors.primaryDark],
                    onTap: () => Get.offNamed(AppRoutes.parentmapScreen),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DrawerGradientActionButton(
                          icon: Icons.star_rate_rounded,
                          label: AppStrings.drawerRateUs,
                          colors: const [
                            AppColors.primary,
                            AppColors.primaryDark,
                          ],
                          onTap: () {
                            // TODO: Implement rate prompt or app store redirect
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DrawerOutlineActionButton(
                          icon: Icons.logout_rounded,
                          label: AppStrings.drawerLogout,
                          color: Colors.redAccent,
                          onTap: () {
                            // TODO: Implement logout
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // (No local helpers; composition uses DrawerCard, DrawerTile, ProfileTile,
  // DrawerGradientActionButton, and DrawerOutlineActionButton widgets.)
}
