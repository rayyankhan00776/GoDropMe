import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/features/commonFeatures/splash/controllers/splash_controller.dart';
import 'package:godropme/theme/colors.dart';

/// Splash screen that handles:
/// 1. First-time user check (show onboarding)
/// 2. Session check (auto-login)
/// 3. Navigation to appropriate screen
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller to trigger startup logic
    Get.put(SplashController());

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo
            Image.asset(
              'assets/images/logo/LoginAndRegister.png',
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    size: 80,
                    color: Colors.white,
                  ),
                );
              },
            ),
            // const SizedBox(height: 24),
            // // App Name
            // const Text(
            //   'GoDropMe',
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontSize: 32,
            //     fontWeight: FontWeight.bold,
            //     letterSpacing: 1.2,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
