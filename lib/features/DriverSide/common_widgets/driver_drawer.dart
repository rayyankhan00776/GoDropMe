// Minimal Driver Drawer with header, profile and settings
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/features/DriverSide/common_widgets/drawer widgets/driver_drawer_card.dart';
import 'package:godropme/features/DriverSide/common_widgets/drawer widgets/driver_profile_tile.dart';
import 'package:godropme/features/DriverSide/common_widgets/driver_drawer_controller.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/shared/widgets/drawer_button.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/shared/widgets/drawer_version_label.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';

class DriverDrawer extends StatelessWidget {
  const DriverDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final drawerCtrl = Get.find<DriverDrawerController>();
    
    return Drawer(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with centered app name (fixed at top)
            const _DriverDrawerHeader(),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile card
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: DriverDrawerCard(
                        child: DriverProfileTile(
                          onTap: () {
                            drawerCtrl.close();
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
                                drawerCtrl.close();
                                // Navigate to the main driver nav bar (DriverHomeScreen)
                                Get.offAllNamed(AppRoutes.driverMap);
                              },
                            ),
                            AppDrawerTile(
                              icon: Icons.list_alt,
                              title: AppStrings.driverTabRequests,
                              onTap: () {
                                drawerCtrl.close();
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
                                drawerCtrl.close();
                                Get.offAllNamed(
                                  AppRoutes.driverMap,
                                  arguments: {'tab': 1},
                                );
                              },
                            ),
                            AppDrawerTile(
                              icon: Icons.work_outline_rounded,
                              title: 'Active Services',
                              onTap: () {
                                drawerCtrl.close();
                                Get.toNamed(AppRoutes.driverActiveServices);
                              },
                            ),
                            AppDrawerTile(
                              icon: Icons.chat_bubble_outline,
                              title: AppStrings.driverTabChat,
                              onTap: () {
                                drawerCtrl.close();
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
                                drawerCtrl.close();
                                Get.toNamed(AppRoutes.driverReport);
                              },
                            ),
                            AppDrawerTile(
                              icon: Icons.settings_rounded,
                              title: AppStrings.drawerSettings,
                              onTap: () {
                                drawerCtrl.close();
                                Get.toNamed(AppRoutes.driverSettings);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Version label (shared, consistent)
                    const DrawerVersionLabel(),
                  ],
                ),
              ),
            ),
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
      height: Responsive.scaleClamped(context, 70, 70, 70),
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
