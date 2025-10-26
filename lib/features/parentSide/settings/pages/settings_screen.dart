import 'package:flutter/material.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/features/parentSide/common widgets/parent_drawer_shell.dart';
import 'package:godropme/features/parentSide/settings/widgets/settings_tile.dart';
import 'package:godropme/features/parentSide/settings/widgets/settings_section.dart';
import 'package:godropme/features/parentSide/settings/widgets/settings_caption.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';

class ParentSettingsScreen extends StatelessWidget {
  const ParentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ParentDrawerShell(
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
                  padding: const EdgeInsets.only(left: 8.0, bottom: 12),
                  child: Text(
                    AppStrings.settings,
                    style: AppTypography.optionHeading,
                  ),
                ),

                // Sections with captions for a cleaner grouping
                const SettingsCaption('General'),
                const SettingsSection(
                  children: [
                    SettingsTile(title: 'Phone Number', showIosChevron: true),
                    SettingsTile(
                      title: 'Languages',
                      subtitle: 'default language - English',
                      showIosChevron: true,
                    ),
                    SettingsTile(
                      title: 'Dark Mode',
                      subtitle: 'Off',
                      showIosChevron: true,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const SettingsCaption('Account'),
                const SettingsSection(
                  children: [
                    SettingsTile(title: 'Rules'),
                    SettingsTile(title: AppStrings.drawerLogout),
                  ],
                ),
                const SizedBox(height: 14),
                const SettingsSection(
                  children: [
                    SettingsTile(title: 'Delete Account', isDestructive: true),
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
