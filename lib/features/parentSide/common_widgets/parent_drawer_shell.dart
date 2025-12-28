// Reusable shell that provides a simple overlay drawer (no animation)
// with a top-left glassy menu button.

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:godropme/features/parentSide/common_widgets/drawer.dart';
import 'package:godropme/features/parentSide/common_widgets/drawer_button.dart';
import 'package:godropme/features/parentSide/common_widgets/notification_button.dart';
import 'package:godropme/features/parentSide/common_widgets/parent_drawer_controller.dart';
import 'package:get/get.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/utils/responsive.dart';

class ParentDrawerShell extends StatelessWidget {
  final Widget body;
  final bool showNotificationButton;

  const ParentDrawerShell({
    super.key,
    required this.body,
    this.showNotificationButton = false,
  });

  @override
  Widget build(BuildContext context) {
    // Get or create the shared drawer controller
    final drawerCtrl = Get.put(ParentDrawerController(), permanent: true);
    final drawerWidth = Responsive.wp(context, 85);

    return Stack(
      children: [
        // Main content remains full width/height regardless of drawer state
        Positioned.fill(child: body),

        // Top-left drawer button
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: Responsive.scaleClamped(context, 12, 12, 12),
                top: Responsive.scaleClamped(context, 12, 12, 12),
              ),
              child: GlassDrawerButton(onPressed: drawerCtrl.toggle),
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
                child: GlassNotificationButton(
                  onPressed: () => Get.toNamed(AppRoutes.parentNotifications),
                ),
              ),
            ),
          ),

        // Overlay drawer - uses Obx for reactive updates
        Obx(() {
          if (!drawerCtrl.isOpen.value) return const SizedBox.shrink();
          return Stack(
            children: [
              // Optional invisible tap area to close when tapping outside the drawer
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
                    child: const ParentDrawer(),
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
