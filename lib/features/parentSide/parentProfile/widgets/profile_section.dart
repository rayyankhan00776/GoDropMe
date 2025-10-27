import 'package:flutter/material.dart';
import 'package:godropme/features/parentSide/common widgets/drawer widgets/drawer_card.dart';

class ProfileSection extends StatelessWidget {
  final List<Widget> children;
  const ProfileSection({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return DrawerCard(child: Column(children: _withDividers(children)));
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
