import 'package:flutter/material.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/features/driverSide/common widgets/driver_drawer_shell.dart';

class DriverChatScreen extends StatelessWidget {
  const DriverChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DriverDrawerShell(
        body: Center(
          child: Text(
            AppStrings.driverTabChat,
            style: AppTypography.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
