import 'package:flutter/material.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/features/parentSide/common widgets/parent_drawer_shell.dart';
import 'package:godropme/features/parentSide/settings/widgets/settings_tile.dart';
import 'package:godropme/features/parentSide/settings/widgets/settings_section.dart';
import 'package:godropme/features/parentSide/settings/widgets/settings_caption.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/models/parent_profile.dart';
import 'package:godropme/services/Terms_uri_opener.dart';

class ParentSettingsScreen extends StatefulWidget {
  const ParentSettingsScreen({super.key});

  @override
  State<ParentSettingsScreen> createState() => _ParentSettingsScreenState();
}

class _ParentSettingsScreenState extends State<ParentSettingsScreen> {
  String? _phone;

  @override
  void initState() {
    super.initState();
    _loadPhone();
  }

  Future<void> _loadPhone() async {
    final profile = await ParentProfile.loadFromLocal();
    final raw = profile.phone.national;
    if (!mounted) return;
    setState(() => _phone = raw);
  }

  String? _formatPhone(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    var n = raw.trim();
    if (n.startsWith('+92')) n = n.substring(3);
    if (n.startsWith('92')) n = n.substring(2);
    return '+92 $n';
  }

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
                    SettingsTile(
                      title: 'Phone Number',
                      subtitle: _formatPhone(_phone),
                      showIosChevron: true,
                    ),
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
                    const SettingsTile(title: AppStrings.drawerLogout),
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
