import 'package:flutter/material.dart';
import 'package:godropme/utils/app_typography.dart';

class DriverChatScreen extends StatelessWidget {
  const DriverChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Chat',
          style: AppTypography.optionHeading,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
