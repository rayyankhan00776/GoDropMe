import 'package:flutter/material.dart';
import 'package:godropme/constants/app_strings.dart';
import 'driver_profile_section.dart';
import 'driver_profile_tile.dart';

class ProfileActionsSection extends StatelessWidget {
  final String? phoneNumber; // raw phone, may start with +92 or 92
  final VoidCallback? onOpenTerms;
  final VoidCallback? onLogout;
  final VoidCallback? onDeleteAccount;
  const ProfileActionsSection({
    super.key,
    required this.phoneNumber,
    this.onOpenTerms,
    this.onLogout,
    this.onDeleteAccount,
  });

  String _formatPhone(String? n) {
    if (n == null || n.trim().isEmpty) return 'Not set';
    var p = n.trim();
    if (p.startsWith('+92')) p = p.substring(3);
    if (p.startsWith('92')) p = p.substring(2);
    return '+92 ${p.trim()}';
  }

  @override
  Widget build(BuildContext context) {
    return DriverProfileSection(
      children: [
        DriverProfileTile(
          title: 'Phone Number',
          subtitle: _formatPhone(phoneNumber),
          showIosChevron: true,
        ),
        DriverProfileTile(title: AppStrings.drawerTerms, onTap: onOpenTerms),
        DriverProfileTile(title: AppStrings.drawerLogout, onTap: onLogout),
        const DriverProfileTile(title: 'Delete Account', isDestructive: true),
      ],
    );
  }
}
