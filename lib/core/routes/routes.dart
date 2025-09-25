import 'package:get/get.dart';
import 'package:godropme/features/DriverOrParentOption/binding/dop_binding.dart';
import 'package:godropme/features/DriverOrParentOption/pages/DOP_option_screen.dart';
import 'package:godropme/features/DriverSide/driverDataCollection/pages/driver_name_screen.dart';
import 'package:godropme/features/DriverSide/driverDataCollection/binding/driver_name_binding.dart';
import 'package:godropme/features/onboard/binding/onboard_binding.dart';
import 'package:godropme/features/onboard/pages/onboard_screen.dart';
import 'package:godropme/features/Reg-option/pages/option_screen.dart';
import 'package:godropme/features/Reg-option/binding/option_binding.dart';
import 'package:godropme/features/phoneVerfication/pages/otp_screen.dart';
import 'package:godropme/features/phoneVerfication/pages/phone_Screen.dart';
import 'package:godropme/features/phoneVerfication/binding/phone_binding.dart';
import 'package:godropme/features/phoneVerfication/binding/otp_binding.dart';

// Add more imports for other screens as you create them

class AppRoutes {
  static const String onboard = '/onboard';
  static const String optionScreen = '/option_screen';
  static const String phoneScreen = '/phone_screen';
  static const String otpScreen = '/otp_screen';
  static const String dopOption = '/dop_option';
  static const String driverName = '/driver_name';
  // static const String register = '/register'; // Example for future screens

  static final routes = [
    GetPage(
      name: onboard,
      page: () => const OnboardScreen(),
      binding: OnboardBinding(),
    ),
    GetPage(
      name: optionScreen,
      page: () => const OptionScreen(),
      binding: OptionBinding(),
    ),
    GetPage(
      name: phoneScreen,
      page: () => const PhoneScreen(),
      binding: PhoneBinding(),
    ),
    GetPage(
      name: otpScreen,
      page: () => const OtpScreen(),
      binding: OtpBinding(),
    ),
    GetPage(
      name: dopOption,
      page: () => const DopOptionScreen(),
      binding: DopBinding(),
    ),
    GetPage(
      name: driverName,
      page: () => DriverNameScreen(),
      binding: DriverNameBinding(),
    ),
  ];
}
