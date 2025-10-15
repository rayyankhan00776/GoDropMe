// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:godropme/features/parentSide/common widgets/parent_drawer_shell.dart';
import 'package:godropme/utils/app_typography.dart';

class ParentChatScreen extends StatelessWidget {
  const ParentChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ParentDrawerShell(
      body: Scaffold(
        appBar: AppBar(title: const Text('Chat'), elevation: 0),
        body: const Center(
          child: Text('Chat', style: AppTypography.optionLinePrimary),
        ),
      ),
    );
  }
}
