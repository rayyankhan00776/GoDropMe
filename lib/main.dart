import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/core/theme/theme.dart';
import 'package:godropme/routes/routes.dart';

void main() {
  runApp(const GoDropMe());
}

class GoDropMe extends StatelessWidget {
  const GoDropMe({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.onboard,
      getPages: AppRoutes.routes,
    );
  }
}
