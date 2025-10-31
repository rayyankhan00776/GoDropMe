import 'package:flutter/material.dart';
import 'package:godropme/features/driverSide/common widgets/drawer widgets/driver_drawer_card.dart';

class DriverProfileSection extends StatelessWidget {
  final List<Widget> children;
  const DriverProfileSection({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    // Isolate expensive paints (card with shadow) from scroll to reduce jank
    return RepaintBoundary(
      child: DriverDrawerCard(child: Column(children: _withDividers(children))),
    );
  }

  List<Widget> _withDividers(List<Widget> items) {
    if (items.isEmpty) return const [];
    final List<Widget> out = [];
    for (var i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i != items.length - 1) out.add(const Divider(height: 1));
    }
    return out;
  }
}
