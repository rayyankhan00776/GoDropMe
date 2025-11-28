part of '../routes.dart';

final List<GetPage<dynamic>> parentRoutes = [
  GetPage(
    name: AppRoutes.parentName,
    page: () => const ParentNameScreen(),
    binding: ParentNameBinding(),
  ),
  GetPage(
    name: AppRoutes.parentmapScreen,
    page: () => const ParentMapScreen(),
    binding: ParentMapBinding(),
  ),
  GetPage(
    name: AppRoutes.addChildren,
    page: () => const AddChildrenScreen(),
    binding: AddChildrenBinding(),
  ),
  GetPage(
    name: AppRoutes.addChildHelp,
    page: () => const AddChildHelpScreen(),
    binding: AddChildrenBinding(),
  ),
  GetPage(name: AppRoutes.findDrivers, page: () => const FindDriversScreen()),
  GetPage(
    name: AppRoutes.profile,
    page: () => const parent_profile.ProfileScreen(),
  ),
  GetPage(
    name: AppRoutes.parentChat,
    page: () => const ParentChatScreen(),
    binding: ParentChatBinding(),
  ),
  // Parent Report Screen
  GetPage(
    name: AppRoutes.parentReport,
    page: () => const ParentReportScreen(),
    binding: ParentReportBinding(),
  ),
  // Parent Settings Screen
  GetPage(
    name: AppRoutes.parentSettings,
    page: () => const parent_settings.ParentSettingsScreen(),
  ),
  // Parent Notifications
  GetPage(
    name: AppRoutes.parentNotifications,
    page: () => const ParentsNotificationScreen(),
    binding: ParentNotificationsBinding(),
  ),
  // Parent Conversation
  GetPage(
    name: AppRoutes.parentConversation,
    page: () => const ParentConversationScreen(),
    binding: ParentConversationBinding(),
  ),
  // Edit Parent Name
  GetPage(
    name: AppRoutes.editParentName,
    page: () => const EditNameScreen(),
  ),
  // Edit Parent Phone
  GetPage(
    name: AppRoutes.editParentPhone,
    page: () => const EditPhoneScreen(),
  ),
  // Edit Parent Email
  GetPage(
    name: AppRoutes.editParentEmail,
    page: () => const EditEmailScreen(),
  ),
];
