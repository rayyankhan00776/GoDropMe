part of '../routes.dart';

final List<GetPage<dynamic>> driverRoutes = [
  GetPage(
    name: AppRoutes.driverName,
    page: () => DriverNameScreen(),
    binding: DriverNameBinding(),
  ),
  GetPage(
    name: AppRoutes.vehicleSelection,
    page: () => const VehicleSelectionScreen(),
    binding: VehicleSelectionBinding(),
  ),
  GetPage(
    name: AppRoutes.personalInfo,
    page: () => const PersonalInfoScreen(),
    binding: PersonalInfoBinding(),
  ),
  GetPage(
    name: AppRoutes.driverLicence,
    page: () => const DriverLicenceScreen(),
    binding: DriverLicenceBinding(),
  ),
  GetPage(
    name: AppRoutes.driverIdentification,
    page: () => const DriverIdentificationScreen(),
    binding: DriverIdentificationBinding(),
  ),
  GetPage(
    name: AppRoutes.vehicleRegistration,
    page: () => const VehicleRegistrationScreen(),
    binding: VehicleRegistrationBinding(),
  ),
  GetPage(
    name: AppRoutes.driverServiceDetails,
    page: () => const ServiceDetailsScreen(),
    binding: ServiceDetailsBinding(),
  ),
  GetPage(
    name: AppRoutes.driverMap,
    page: () => const DriverHomeScreen(),
    binding: DriverMapBinding(),
  ),
  // Driver Settings Screen
  GetPage(
    name: AppRoutes.driverSettings,
    page: () => const driver_settings.DriverSettingsScreen(),
  ),
  // Driver Profile Screen
  GetPage(
    name: AppRoutes.driverProfile,
    page: () => const driver_profile.DriverProfileScreen(),
  ),
  // Driver Report Screen
  GetPage(
    name: AppRoutes.driverReport,
    page: () => const DriverReportScreen(),
    binding: DriverReportBinding(),
  ),
  // Driver Notifications
  GetPage(
    name: AppRoutes.driverNotifications,
    page: () => const DriverNotificationsScreen(),
    binding: DriverNotificationsBinding(),
  ),
  // Driver Conversation
  GetPage(
    name: AppRoutes.driverConversation,
    page: () => const DriverConversationScreen(),
    binding: DriverConversationBinding(),
  ),
];
