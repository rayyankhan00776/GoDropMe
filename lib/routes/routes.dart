import 'package:get/get.dart';
import 'package:godropme/features/onboard/binding/onboard_binding.dart';
import 'package:godropme/features/onboard/pages/onboard_screen.dart';

// Add more imports for other screens as you create them

class AppRoutes {
  static const String onboard = '/onboard';
  // static const String register = '/register'; // Example for future screens

  static final routes = [
    GetPage(
      name: onboard,
      page: () => const OnboardScreen(),
      binding: OnboardBinding(),
    ),
    // Add more GetPage entries here as you add screens
  ];
}
