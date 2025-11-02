import 'package:get/get.dart';
import 'package:godropme/features/commonFeatures/driverOrParentOption/binding/dop_binding.dart';
import 'package:godropme/features/commonFeatures/driverOrParentOption/pages/DOP_option_screen.dart';
import 'package:godropme/features/driverSide/driverRegistration/pages/driver_identification_screen.dart';
import 'package:godropme/features/driverSide/driverRegistration/pages/driver_licence_screen.dart';
import 'package:godropme/features/driverSide/driverRegistration/pages/driver_name_screen.dart';
import 'package:godropme/features/driverSide/driverRegistration/binding/driver_name_binding.dart';
import 'package:godropme/features/driverSide/driverRegistration/binding/driver_licence_binding.dart';
import 'package:godropme/features/driverSide/driverRegistration/binding/driver_identification_binding.dart';
import 'package:godropme/features/driverSide/driverRegistration/pages/personal_info_Screen.dart';
import 'package:godropme/features/driverSide/driverRegistration/binding/personal_info_binding.dart';
import 'package:godropme/features/driverSide/driverRegistration/pages/vehicle_Selection_screen.dart';
import 'package:godropme/features/driverSide/driverRegistration/binding/vehicle_selection_binding.dart';
import 'package:godropme/features/driverSide/driverRegistration/pages/vehicle_registration_Screen.dart';
import 'package:godropme/features/driverSide/driverRegistration/binding/vehicle_registration_binding.dart';
import 'package:godropme/features/commonFeatures/onboard/binding/onboard_binding.dart';
import 'package:godropme/features/commonFeatures/onboard/pages/onboard_screen.dart';
import 'package:godropme/features/commonFeatures/registrationOption/pages/option_screen.dart';
import 'package:godropme/features/commonFeatures/registrationOption/binding/option_binding.dart';
import 'package:godropme/features/commonFeatures/phoneAndOtpVerfication/pages/otp_screen.dart';
import 'package:godropme/features/commonFeatures/phoneAndOtpVerfication/pages/phone_Screen.dart';
import 'package:godropme/features/commonFeatures/phoneAndOtpVerfication/binding/phone_binding.dart';
import 'package:godropme/features/commonFeatures/phoneAndOtpVerfication/binding/otp_binding.dart';
// import 'package:godropme/features/parentSide/parentHome/extra/parent_Home_Screen.dart';
import 'package:godropme/features/parentSide/parentHome/pages/parent_map_screen.dart';
import 'package:godropme/features/parentSide/parentHome/binding/parent_map_binding.dart';
import 'package:godropme/features/parentSide/parentName/pages/parent_name_screen.dart';
import 'package:godropme/features/parentSide/parentName/binding/parent_name_binding.dart';
import 'package:godropme/features/parentSide/addChildren/pages/add_children_screen.dart';
import 'package:godropme/features/parentSide/addChildren/binding/add_children_binding.dart';
import 'package:godropme/features/parentSide/findDrivers/pages/find_drivers_screen.dart';
import 'package:godropme/features/parentSide/parentProfile/pages/profile_screen.dart';
import 'package:godropme/features/parentSide/settings/pages/settings_screen.dart';
import 'package:godropme/features/parentSide/addChildren/widgets/AddChildrenFormhelpScreen/add_child_help_screen.dart';
import 'package:godropme/features/parentSide/parentChat/pages/parent_chat_screen.dart';
import 'package:godropme/features/driverSide/driverHome/pages/driver_home_screen.dart';
import 'package:godropme/features/driverSide/driverHome/binding/driver_home_binding.dart';
import 'package:godropme/features/parentSide/report/pages/parent_report_screen.dart';
import 'package:godropme/features/parentSide/report/binding/parent_report_binding.dart';
import 'package:godropme/features/driverSide/driverRegistration/pages/service_details_screen.dart';
import 'package:godropme/features/driverSide/driverRegistration/binding/service_details_binding.dart';
import 'package:godropme/features/driverSide/settings/pages/settings_screen.dart';
import 'package:godropme/features/driverSide/driverProfile/pages/profile_screen.dart';
import 'package:godropme/features/driverSide/report/pages/driver_report_screen.dart';
import 'package:godropme/features/driverSide/report/binding/driver_report_binding.dart';
import 'package:godropme/features/parentSide/notifications/pages/parents_notification_Screen.dart';
import 'package:godropme/features/parentSide/notifications/binding/parent_notifications_binding.dart';
import 'package:godropme/features/driverSide/notifications/pages/driver_notifications_screen.dart';
import 'package:godropme/features/driverSide/notifications/binding/driver_notifications_binding.dart';

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
  static const String driverServiceDetails = '/driver_service_details';
  static const String parentmapScreen = '/map_screen';
  static const String parentChat = '/parent_chat';
  static const String addChildren = '/add_children';
  static const String addChildHelp = '/add_child_help';
  static const String findDrivers = '/find_drivers';
  static const String profile = '/profile';
  static const String driverMap = '/driver_map';
  static const String parentReport = '/parent_report';
  static const String parentSettings = '/parent_settings';
  static const String driverSettings = '/driver_settings';
  static const String driverProfile = '/driver_profile';
  static const String driverReport = '/driver_report';
  static const String parentNotifications = '/parent_notifications';
  static const String driverNotifications = '/driver_notifications';

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
    GetPage(
      name: vehicleRegistration,
      page: () => const VehicleRegistrationScreen(),
      binding: VehicleRegistrationBinding(),
    ),
    GetPage(
      name: driverServiceDetails,
      page: () => const ServiceDetailsScreen(),
      binding: ServiceDetailsBinding(),
    ),
    // parents Screens can be added here in the same manner
    GetPage(
      name: parentmapScreen,
      page: () => const ParentMapScreen(),
      binding: ParentMapBinding(),
    ),
    GetPage(name: parentChat, page: () => const ParentChatScreen()),
    GetPage(
      name: addChildren,
      page: () => const AddChildrenScreen(),
      binding: AddChildrenBinding(),
    ),
    GetPage(
      name: addChildHelp,
      page: () => const AddChildHelpScreen(),
      binding: AddChildrenBinding(),
    ),
    GetPage(name: findDrivers, page: () => const FindDriversScreen()),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(
      name: driverMap,
      page: () => const DriverHomeScreen(),
      binding: DriverMapBinding(),
    ),
    // Parent Report Screen
    GetPage(
      name: parentReport,
      page: () => const ParentReportScreen(),
      binding: ParentReportBinding(),
    ),
    // Parent Settings Screen
    GetPage(name: parentSettings, page: () => const ParentSettingsScreen()),
    // Driver Settings Screen
    GetPage(name: driverSettings, page: () => const DriverSettingsScreen()),
    // Driver Profile Screen
    GetPage(name: driverProfile, page: () => const DriverProfileScreen()),
    // Driver Report Screen
    GetPage(
      name: driverReport,
      page: () => const DriverReportScreen(),
      binding: DriverReportBinding(),
    ),
    // Notifications
    GetPage(
      name: parentNotifications,
      page: () => const ParentsNotificationScreen(),
      binding: ParentNotificationsBinding(),
    ),
    GetPage(
      name: driverNotifications,
      page: () => const DriverNotificationsScreen(),
      binding: DriverNotificationsBinding(),
    ),
  ];
}
