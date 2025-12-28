// Reusable shell for driver-side screens with top-left menu and overlay drawer
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:godropme/features/DriverSide/common_widgets/driver_drawer.dart';
import 'package:godropme/features/DriverSide/common_widgets/driver_drawer_button.dart';
import 'package:godropme/features/DriverSide/common_widgets/driver_notification_button.dart';
import 'package:godropme/features/DriverSide/common_widgets/driver_drawer_controller.dart';
import 'package:get/get.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/utils/responsive.dart';

class DriverDrawerShell extends StatelessWidget {
  final Widget body;
  final bool showNotificationButton;

  const DriverDrawerShell({
    super.key,
    required this.body,
    this.showNotificationButton = false,
  });

  @override
  Widget build(BuildContext context) {
    // Get or create the shared drawer controller
    final drawerCtrl = Get.find<DriverDrawerController>();
    final drawerWidth = Responsive.wp(context, 85);

    return Stack(
      children: [
        Positioned.fill(child: body),
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: Responsive.scaleClamped(context, 12, 12, 12),
                top: Responsive.scaleClamped(context, 12, 12, 12),
              ),
              child: DriverGlassDrawerButton(onPressed: drawerCtrl.toggle),
            ),
          ),
        ),
        // Optional top-right notifications button
        if (showNotificationButton)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(
                  right: Responsive.scaleClamped(context, 12, 12, 12),
                  top: Responsive.scaleClamped(context, 12, 12, 12),
                ),
                child: DriverGlassNotificationButton(
                  onPressed: () => Get.toNamed(AppRoutes.driverNotifications),
                ),
              ),
            ),
          ),
        // Drawer overlay - uses Obx for reactive updates
        Obx(() {
          if (!drawerCtrl.isOpen.value) return const SizedBox.shrink();
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: drawerCtrl.close,
                  child: const SizedBox.shrink(),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  elevation: 8,
                  color: Colors.transparent,
                  child: SizedBox(
                    width: drawerWidth,
                    height: double.infinity,
                    child: const DriverDrawer(),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
