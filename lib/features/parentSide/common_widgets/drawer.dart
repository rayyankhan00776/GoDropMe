// Common Parent drawer used across parent-side screens.
// Derived from the previous MapScreenDrawer without changing design or logic.

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/features/parentSide/common_widgets/drawer widgets/drawer_header.dart';
import 'package:godropme/features/parentSide/common_widgets/drawer widgets/drawer_card.dart';
import 'package:godropme/shared/widgets/drawer_button.dart';
import 'package:godropme/shared/widgets/drawer_version_label.dart';
import 'package:godropme/features/parentSide/common_widgets/drawer widgets/profile_tile.dart';

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
                      onTap: () => _navigateFromDrawer(context, AppRoutes.profile),
                    ),
                  ),

                  const SizedBox(height: 7),

                  // Quick actions
                  DrawerCard(
                    child: Column(
                      children: [
                        AppDrawerTile(
                          icon: Icons.drive_eta_rounded,
                          title: AppStrings.drawerMapScreen,
                          onTap: () => _navigateFromDrawer(context, AppRoutes.parentmapScreen),
                        ),
                        const Divider(height: 1),
                        AppDrawerTile(
                          icon: Icons.child_care_rounded,
                          title: AppStrings.drawerYourChildren,
                          onTap: () => _navigateFromDrawer(context, AppRoutes.addChildren),
                        ),
                        const Divider(height: 1),
                        AppDrawerTile(
                          icon: Icons.directions_bus_filled_rounded,
                          title: AppStrings.drawerFindDrivers,
                          onTap: () => _navigateFromDrawer(context, AppRoutes.findDrivers),
                        ),
                        const Divider(height: 1),
                        AppDrawerTile(
                          icon: Icons.directions_bus_filled_rounded,
                          title: AppStrings.parentChatHeading,
                          onTap: () => _navigateFromDrawer(context, AppRoutes.parentChat),
                        ),
                        const Divider(height: 1),
                        AppDrawerTile(
                          icon: Icons.settings_rounded,
                          title: AppStrings.drawerSettings,
                          onTap: () => _navigateFromDrawer(context, AppRoutes.parentSettings),
                        ),
                        const Divider(height: 1),
                        AppDrawerTile(
                          icon: Icons.report_gmailerrorred_rounded,
                          title: AppStrings.report,
                          onTap: () => _navigateFromDrawer(context, AppRoutes.parentReport),
                        ),
                        const Divider(height: 1),
                        AppDrawerTile(
                          icon: Icons.star_rate_outlined,
                          title: AppStrings.drawerRateUs,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  const DrawerVersionLabel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // (No local helpers; composition uses DrawerCard, DrawerTile, ProfileTile,
  void _navigateFromDrawer(BuildContext context, String route) {
    // // Close the drawer first
    // if (Navigator.of(context).canPop()) {
    //   Navigator.of(context).pop();
    // } else {
    //   // Fallback for GetX-managed drawers
    //   Get.back(closeOverlays: true);
    // }

    // If already on the same route, do nothing further
    if (Get.currentRoute == route) {
      return Scaffold.of(context).closeDrawer();
    }

    // Navigate to the requested route
    Get.toNamed(route);
  }
}
