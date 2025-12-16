import 'package:flutter/material.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:get/get.dart';
import 'package:godropme/features/DriverSide/common_widgets/driver_drawer_shell.dart';
import 'package:godropme/features/DriverSide/settings/controllers/driver_settings_controller.dart';
import 'package:godropme/features/DriverSide/settings/widgets/settings_caption.dart';
import 'package:godropme/features/DriverSide/settings/widgets/settings_section.dart';
import 'package:godropme/features/DriverSide/settings/widgets/settings_tile.dart';
import 'package:godropme/features/DriverSide/settings/widgets/driver_settings_confirm_dialog.dart';
import 'package:godropme/services/Terms_uri_opener.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';

class DriverSettingsScreen extends StatelessWidget {
  const DriverSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(DriverSettingsController());
    
    return DriverDrawerShell(
      body: Scaffold(
        backgroundColor: AppColors.white,
        body: Obx(() => Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Leave space beneath the overlaid drawer button
                    SizedBox(height: Responsive.scaleClamped(context, 60, 48, 72)),

                    // Title
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 1),
                      child: Text(
                        AppStrings.settings,
                        style: AppTypography.optionHeading,
                      ),
                    ),

                    // Sections
                    const DriverSettingsCaption('General'),
                    DriverSettingsSection(
                      children: [
                        Obx(() => DriverSettingsTile(
                          title: 'Email',
                          subtitle: controller.email.value?.trim(),
                          showIosChevron: false,
                          // Email edit disabled - linked to auth
                        )),
                        const DriverSettingsTile(
                          title: 'Languages',
                          subtitle: 'default language - English',
                          showIosChevron: true,
                        ),
                        const DriverSettingsTile(
                          title: 'Dark Mode',
                          subtitle: 'Off',
                          showIosChevron: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const DriverSettingsCaption('Account'),
                    DriverSettingsSection(
                      children: [
                        DriverSettingsTile(
                          title: AppStrings.drawerTerms,
                          onTap: () async => termsUriOpener(),
                        ),
                        DriverSettingsTile(
                          title: AppStrings.drawerLogout,
                          onTap: () => _handleLogout(context, controller),
                          isDestructive: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    DriverSettingsSection(
                      children: [
                        DriverSettingsTile(
                          title: 'Delete Account',
                          onTap: () => _handleDeleteAccount(context, controller),
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Loading overlay
            if (controller.isLoading.value)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
          ],
        )),
      ),
    );
  }

  /// Handle logout with confirmation dialog
  Future<void> _handleLogout(
      BuildContext context, DriverSettingsController controller) async {
    final confirmed =
        await DriverSettingsConfirmDialog.showLogoutConfirmation(context);
    if (confirmed) {
      await controller.logout();
    }
  }

  /// Handle delete account with confirmation dialog
  Future<void> _handleDeleteAccount(
      BuildContext context, DriverSettingsController controller) async {
    final confirmed =
        await DriverSettingsConfirmDialog.showDeleteAccountConfirmation(context);
    if (confirmed) {
      await controller.deleteAccount();
    }
  }
}
