import 'package:flutter/material.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:get/get.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/features/driverSide/common widgets/driver_drawer_shell.dart';
import 'package:godropme/features/driverSide/settings/widgets/settings_caption.dart';
import 'package:godropme/features/driverSide/settings/widgets/settings_section.dart';
import 'package:godropme/features/driverSide/settings/widgets/settings_tile.dart';
import 'package:godropme/services/Terms_uri_opener.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';

class DriverSettingsScreen extends StatefulWidget {
  const DriverSettingsScreen({super.key});

  @override
  State<DriverSettingsScreen> createState() => _DriverSettingsScreenState();
}

class _DriverSettingsScreenState extends State<DriverSettingsScreen> {
  String? _email; // stored in driverPhone key for backward compatibility

  @override
  void initState() {
    super.initState();
    _loadPhone();
  }

  Future<void> _loadPhone() async {
    String? raw = await LocalStorage.getString(StorageKeys.driverPhone);
    // Fallback: if driver phone not yet stored (pre-role selection flow),
    // copy parent phone to driver key so settings shows a value.
    if (raw == null || raw.trim().isEmpty) {
      final parentRaw = await LocalStorage.getString(StorageKeys.parentPhone);
      if (parentRaw != null && parentRaw.trim().isNotEmpty) {
        raw = parentRaw.trim();
        // Persist for driver for future accesses.
        await LocalStorage.setString(StorageKeys.driverPhone, raw);
      }
    }
    if (!mounted) return;
    setState(() => _email = raw);
  }

  // Phone formatting removed: now we display raw email value.

  @override
  Widget build(BuildContext context) {
    return DriverDrawerShell(
      body: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
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
                    DriverSettingsTile(
                      title: 'Email',
                      subtitle: _email?.trim(),
                      showIosChevron: true,
                      onTap: () => Get.toNamed(
                        AppRoutes.EmailScreen,
                        arguments: const {
                          'mode': 'update-phone',
                          'role': 'driver',
                        },
                      ),
                    ),
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
                      onTap: () async {
                        await LocalStorage.clearAllUserData();
                        Get.offAllNamed(AppRoutes.onboard);
                      },
                      isDestructive: true,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const DriverSettingsSection(
                  children: [
                    DriverSettingsTile(
                      title: 'Delete Account',
                      isDestructive: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
