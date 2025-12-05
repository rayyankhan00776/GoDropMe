import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/firebase_options.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/theme/theme.dart';
import 'package:godropme/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppwriteClient.instance;
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
