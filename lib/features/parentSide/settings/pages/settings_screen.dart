import 'package:flutter/material.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:get/get.dart';
import 'package:godropme/features/parentSide/common_widgets/parent_drawer_shell.dart';
import 'package:godropme/features/parentSide/settings/controllers/settings_controller.dart';
import 'package:godropme/features/parentSide/settings/widgets/settings_tile.dart';
import 'package:godropme/features/parentSide/settings/widgets/settings_section.dart';
import 'package:godropme/features/parentSide/settings/widgets/settings_caption.dart';
import 'package:godropme/features/parentSide/settings/widgets/settings_confirm_dialog.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/services/Terms_uri_opener.dart';

class ParentSettingsScreen extends StatelessWidget {
  const ParentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get controller from binding
    final controller = Get.find<SettingsController>();

    return ParentDrawerShell(
      body: Scaffold(
        backgroundColor: AppColors.white,
        body: Obx(() => Stack(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Leave space beneath the overlaid drawer button
                        SizedBox(
                            height:
                                Responsive.scaleClamped(context, 60, 48, 72)),

                        // Title
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 1),
                          child: Text(
                            AppStrings.settings,
                            style: AppTypography.optionHeading,
                          ),
                        ),

                        // Sections with captions for a cleaner grouping
                        const SettingsCaption('General'),
                        SettingsSection(
                          children: [
                            Obx(() => SettingsTile(
                                  title: 'Email',
                                  subtitle: controller.email.value?.trim(),
                                  showIosChevron: false,
                                  // Email edit disabled due to auth flow issues
                                )),
                            const SettingsTile(
                              title: 'Languages',
                              subtitle: 'default language - English',
                              showIosChevron: true,
                            ),
                            const SettingsTile(
                              title: 'Dark Mode',
                              subtitle: 'Off',
                              showIosChevron: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const SettingsCaption('Account'),
                        SettingsSection(
                          children: [
                            SettingsTile(
                              title: AppStrings.drawerTerms,
                              onTap: () async => termsUriOpener(),
                            ),
                            SettingsTile(
                              title: AppStrings.drawerLogout,
                              onTap: () => _handleLogout(context, controller),
                              isDestructive: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SettingsSection(
                          children: [
                            SettingsTile(
                              title: 'Delete Account',
                              onTap: () =>
                                  _handleDeleteAccount(context, controller),
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
      BuildContext context, SettingsController controller) async {
    final confirmed =
        await SettingsConfirmDialog.showLogoutConfirmation(context);
    if (confirmed) {
      await controller.logout();
    }
  }

  /// Handle delete account with confirmation dialog
  Future<void> _handleDeleteAccount(
      BuildContext context, SettingsController controller) async {
    final confirmed =
        await SettingsConfirmDialog.showDeleteAccountConfirmation(context);
    if (confirmed) {
      await controller.deleteAccount();
    }
  }
}
