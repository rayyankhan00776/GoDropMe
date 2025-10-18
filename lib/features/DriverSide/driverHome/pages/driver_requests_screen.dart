import 'package:flutter/material.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/features/driverSide/common widgets/driver_drawer_shell.dart';

class DriverRequestsScreen extends StatelessWidget {
  const DriverRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DriverDrawerShell(
        body: Center(
          child: Text(
            'Requests',
            style: AppTypography.optionHeading,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
