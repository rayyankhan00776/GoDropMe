import 'package:flutter/material.dart';
import 'package:godropme/utils/app_typography.dart';

class DriverOrdersScreen extends StatelessWidget {
  const DriverOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'My Orders',
          style: AppTypography.optionHeading,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
