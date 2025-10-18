// Reusable shell for driver-side screens with top-left menu and overlay drawer
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:godropme/features/driverSide/common widgets/driver_drawer.dart';
import 'package:godropme/features/driverSide/common widgets/driver_drawer_button.dart';
import 'package:godropme/utils/responsive.dart';

class DriverDrawerShell extends StatefulWidget {
  final Widget body;

  const DriverDrawerShell({super.key, required this.body});

  @override
  State<DriverDrawerShell> createState() => _DriverDrawerShellState();
}

class _DriverDrawerShellState extends State<DriverDrawerShell> {
  bool _isOpen = false;

  void _toggle() => setState(() => _isOpen = !_isOpen);
  void _close() => setState(() => _isOpen = false);

  @override
  Widget build(BuildContext context) {
    final drawerWidth = Responsive.wp(context, 85);

    return Stack(
      children: [
        Positioned.fill(child: widget.body),
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: Responsive.scaleClamped(context, 12, 12, 12),
                top: Responsive.scaleClamped(context, 12, 12, 12),
              ),
              child: DriverGlassDrawerButton(onPressed: _toggle),
            ),
          ),
        ),
        if (_isOpen) ...[
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _close,
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
      ],
    );
  }
}
