// Reusable shell that provides the ZoomDrawer with the common Parent drawer
// and a top-left glassy menu button overlay.

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:godropme/features/parentSide/common widgets/drawer.dart';
import 'package:godropme/features/parentSide/common widgets/drawer_button.dart';
import 'package:godropme/utils/responsive.dart';

class ParentDrawerShell extends StatefulWidget {
  final Widget body;

  const ParentDrawerShell({super.key, required this.body});

  @override
  State<ParentDrawerShell> createState() => _ParentDrawerShellState();
}

class _ParentDrawerShellState extends State<ParentDrawerShell> {
  final ZoomDrawerController _zoomController = ZoomDrawerController();

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      controller: _zoomController,
      menuScreen: const ParentDrawer(),
      mainScreen: Stack(
        children: [
          // Page content
          Positioned.fill(child: widget.body),

          // Top-left drawer button
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  left: Responsive.scaleClamped(context, 12, 12, 12),
                  top: Responsive.scaleClamped(context, 12, 12, 12),
                ),
                child: GlassDrawerButton(
                  onPressed: () => _zoomController.toggle?.call(),
                ),
              ),
            ),
          ),
        ],
      ),
      // Visual tuning for smooth animation (kept in sync across screens)
      borderRadius: 24,
      showShadow: true,
      angle: 0.0,
      slideWidth: Responsive.wp(context, 85),
      openCurve: Curves.fastOutSlowIn,
      closeCurve: Curves.easeInOut,
      drawerShadowsBackgroundColor: Colors.black.withOpacity(0.2),
      menuBackgroundColor: Colors.transparent,
    );
  }
}
