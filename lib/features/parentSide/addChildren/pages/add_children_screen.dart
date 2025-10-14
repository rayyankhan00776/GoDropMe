import 'package:flutter/material.dart';
import 'package:godropme/features/parentSide/common widgets/parent_drawer_shell.dart';

class AddChildrenScreen extends StatelessWidget {
  const AddChildrenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ParentDrawerShell(
      body: const Scaffold(
        body: Center(
          child: Text(
            'Add Children',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
