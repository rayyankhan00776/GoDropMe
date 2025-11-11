import 'package:flutter/material.dart';

/// Optional wrapper to isolate selection/gestures around a tile
/// without mixing selection logic into presentation.
class SelectableTileWrapper extends StatelessWidget {
  final bool selected;
  final VoidCallback? onTap;
  final Widget child;
  const SelectableTileWrapper({
    super.key,
    required this.child,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget body = child;
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF0066FF) : Colors.transparent,
            width: selected ? 2 : 0,
          ),
        ),
        child: body,
      ),
    );
  }
}
