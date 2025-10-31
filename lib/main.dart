import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/theme/theme.dart';
import 'package:godropme/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppwriteClient.instance;
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
