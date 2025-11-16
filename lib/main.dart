import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/theme/theme.dart';
import 'package:godropme/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppwriteClient.instance;
  // Set a global black status bar with light (white) icons across the app.
  // - Android: statusBarColor + statusBarIconBrightness
  // - iOS: statusBarBrightness (set to dark to get light content)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
    ),
  );
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
      // Provide a smooth fade + slide transition globally
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
