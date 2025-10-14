// Reusable shell that provides a simple overlay drawer (no animation)
// with a top-left glassy menu button.

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
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
  bool _isOpen = false;

  void _toggle() => setState(() => _isOpen = !_isOpen);
  void _close() => setState(() => _isOpen = false);

  @override
  Widget build(BuildContext context) {
    final drawerWidth = Responsive.wp(context, 85);

    return Stack(
      children: [
        // Main content remains full width/height regardless of drawer state
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
              child: GlassDrawerButton(onPressed: _toggle),
            ),
          ),
        ),

        // Overlay drawer (no animation). When open, show drawer on the left,
        // overlaying content. Content is not resized or moved.
        if (_isOpen) ...[
          // Optional invisible tap area to close when tapping outside the drawer
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
                child: const ParentDrawer(),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
