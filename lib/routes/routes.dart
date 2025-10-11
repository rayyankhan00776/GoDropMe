import 'package:get/get.dart';
import 'package:godropme/features/commonFeatures/DriverOrParentOption/binding/dop_binding.dart';
import 'package:godropme/features/commonFeatures/DriverOrParentOption/pages/DOP_option_screen.dart';
import 'package:godropme/features/DriverSide/driverRegistration/pages/driver_identification_screen.dart';
import 'package:godropme/features/DriverSide/driverRegistration/pages/driver_licence_screen.dart';
import 'package:godropme/features/DriverSide/driverRegistration/pages/driver_name_screen.dart';
import 'package:godropme/features/DriverSide/driverRegistration/binding/driver_name_binding.dart';
import 'package:godropme/features/DriverSide/driverRegistration/binding/driver_licence_binding.dart';
import 'package:godropme/features/DriverSide/driverRegistration/binding/driver_identification_binding.dart';
import 'package:godropme/features/DriverSide/driverRegistration/pages/personal_info_Screen.dart';
import 'package:godropme/features/DriverSide/driverRegistration/binding/personal_info_binding.dart';
import 'package:godropme/features/DriverSide/driverRegistration/pages/vehicle_Selection_screen.dart';
import 'package:godropme/features/DriverSide/driverRegistration/binding/vehicle_selection_binding.dart';
import 'package:godropme/features/DriverSide/driverRegistration/pages/vehicle_registration_Screen.dart';
import 'package:godropme/features/commonFeatures/onboard/binding/onboard_binding.dart';
import 'package:godropme/features/commonFeatures/onboard/pages/onboard_screen.dart';
import 'package:godropme/features/commonFeatures/Reg-option/pages/option_screen.dart';
import 'package:godropme/features/commonFeatures/Reg-option/binding/option_binding.dart';
import 'package:godropme/features/commonFeatures/phoneVerfication/pages/otp_screen.dart';
import 'package:godropme/features/commonFeatures/phoneVerfication/pages/phone_Screen.dart';
import 'package:godropme/features/commonFeatures/phoneVerfication/binding/phone_binding.dart';
import 'package:godropme/features/commonFeatures/phoneVerfication/binding/otp_binding.dart';
import 'package:godropme/features/parentSide/parentName/pages/parent_name_screen.dart';
import 'package:godropme/features/parentSide/parentName/binding/driver_name_binding.dart';

// Add more imports for other screens as you create them

class AppRoutes {
  static const String onboard = '/onboard';
  static const String optionScreen = '/option_screen';
  static const String phoneScreen = '/phone_screen';
  static const String otpScreen = '/otp_screen';
  static const String dopOption = '/dop_option';
  static const String driverName = '/driver_name';
  static const String parentName = '/parent_name';
  static const String vehicleSelection = '/vehicle_selection';
  static const String personalInfo = '/personal_info';
  static const String driverLicence = '/driver_licence';
  static const String driverIdentification = '/driver_identification';
  static const String vehicleRegistration = '/vehicle_registration';
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
    GetPage(
      name: parentName,
      page: () => const ParentNameScreen(),
      binding: ParentNameBinding(),
    ),
    GetPage(
      name: vehicleSelection,
      page: () => const VehicleSelectionScreen(),
      binding: VehicleSelectionBinding(),
    ),
    GetPage(
      name: personalInfo,
      page: () => const PersonalInfoScreen(),
      binding: PersonalInfoBinding(),
    ),
    GetPage(
      name: driverLicence,
      page: () => const DriverLicenceScreen(),
      binding: DriverLicenceBinding(),
    ),
    GetPage(
      name: driverIdentification,
      page: () => const DriverIdentificationScreen(),
      binding: DriverIdentificationBinding(),
    ),
    GetPage(name: vehicleRegistration, page: () => VehicleRegistrationScreen()),
  ];
}
