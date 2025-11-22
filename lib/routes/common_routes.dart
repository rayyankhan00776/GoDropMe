part of '../routes.dart';

final List<GetPage<dynamic>> commonRoutes = [
  GetPage(
    name: AppRoutes.onboard,
    page: () => const OnboardScreen(),
    binding: OnboardBinding(),
  ),
  GetPage(
    name: AppRoutes.optionScreen,
    page: () => const OptionScreen(),
    binding: OptionBinding(),
  ),
  GetPage(
    name: AppRoutes.EmailScreen,
    page: () => const EmailScreen(),
    binding: PhoneBinding(),
  ),
  GetPage(
    name: AppRoutes.otpScreen,
    page: () => const OtpScreen(),
    binding: OtpBinding(),
  ),
  GetPage(
    name: AppRoutes.dopOption,
    page: () => const DopOptionScreen(),
    binding: DopBinding(),
  ),
];
