import 'package:flutter/material.dart';
import 'package:godropme/features/parentSide/common widgets/parent_drawer_shell.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/constants/app_strings.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ParentDrawerShell(
      body: const Scaffold(
        body: Center(
          child: Text(AppStrings.profileTitle, style: AppTypography.titleLarge),
        ),
      ),
    );
  }
}
