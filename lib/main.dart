import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/theme/theme.dart';
import 'package:godropme/routes.dart';
import 'package:appwrite/appwrite.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Appwrite client and register core services in GetX DI for global access.
  Get.put<Client>(AppwriteClient.client, permanent: true);
  Get.put<Account>(AppwriteClient.accountService(), permanent: true);
  Get.put<Databases>(AppwriteClient.databasesService(), permanent: true);
  Get.put<Storage>(AppwriteClient.storageService(), permanent: true);

  // Log initialization and optionally verify connection if a session exists.
  try {
    // This will succeed only if there's an active session already.
    await Get.find<Account>().get();
    debugPrint('✅ Appwrite connected successfully (active session).');
  } catch (_) {
    // No active session is fine at startup; client is still ready.
    debugPrint('✅ Appwrite client initialized (no active session yet).');
  }

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
