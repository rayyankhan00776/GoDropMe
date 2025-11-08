// Minimal Driver Drawer with header, profile and settings
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/features/driverSide/common widgets/drawer widgets/driver_drawer_card.dart';
import 'package:godropme/features/driverSide/common widgets/drawer widgets/driver_profile_tile.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/shared/widgets/drawer_button.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/shared/widgets/drawer_version_label.dart';
import 'package:godropme/utils/app_typography.dart';

class DriverDrawer extends StatelessWidget {
  const DriverDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with centered app name
            const _DriverDrawerHeader(),
            // Profile card
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: DriverDrawerCard(
                child: DriverProfileTile(
                  onTap: () {
                    Get.toNamed(AppRoutes.driverProfile);
                  },
                ),
              ),
            ),

            // Quick actions
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: DriverDrawerCard(
                child: Column(
                  children: [
                    AppDrawerTile(
                      icon: Icons.home_rounded,
                      title: AppStrings.drawerMapScreen,
                      onTap: () {
                        // Navigate to the main driver nav bar (DriverHomeScreen)
                        Get.offAllNamed(AppRoutes.driverMap);
                      },
                    ),
                    AppDrawerTile(
                      icon: Icons.list_alt,
                      title: AppStrings.driverTabRequests,
                      onTap: () {
                        Get.offAllNamed(
                          AppRoutes.driverMap,
                          arguments: {'tab': 0},
                        );
                      },
                    ),
                    AppDrawerTile(
                      icon: Icons.assignment,
                      title: AppStrings.driverTabOrders,
                      onTap: () {
                        Get.offAllNamed(
                          AppRoutes.driverMap,
                          arguments: {'tab': 1},
                        );
                      },
                    ),
                    AppDrawerTile(
                      icon: Icons.chat_bubble_outline,
                      title: AppStrings.driverTabChat,
                      onTap: () {
                        Get.offAllNamed(
                          AppRoutes.driverMap,
                          arguments: {'tab': 3},
                        );
                      },
                    ),
                    AppDrawerTile(
                      icon: Icons.receipt_long_rounded,
                      title: AppStrings.report,
                      onTap: () {
                        Get.toNamed(AppRoutes.driverReport);
                      },
                    ),
                    AppDrawerTile(
                      icon: Icons.settings_rounded,
                      title: AppStrings.drawerSettings,
                      onTap: () {
                        Get.toNamed(AppRoutes.driverSettings);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 5),

            // Version label (shared, consistent)
            const DrawerVersionLabel(),
          ],
        ),
      ),
    );
  }
}

class _DriverDrawerHeader extends StatelessWidget {
  const _DriverDrawerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(120),
          bottomRight: Radius.circular(120),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          AppStrings.optionHeading,
          style: AppTypography.optionHeading.copyWith(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
