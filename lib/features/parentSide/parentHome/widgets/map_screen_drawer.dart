// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_assets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MapScreenDrawer extends StatelessWidget {
  const MapScreenDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.black,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with centered app name
            Container(
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(120),
                  bottomRight: Radius.circular(120),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'GoDropMe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            // Main scrollable content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                children: [
                  // Profile tile with polished look
                  _card(
                    context,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: SvgPicture.asset(
                            AppAssets.defaultPersonSvg,
                            width: 38,
                            height: 38,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: const Text(
                        'John Doe',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      subtitle: const Text(
                        'Parent',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.darkGray,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      onTap: () {},
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Quick actions
                  _card(
                    context,
                    child: Column(
                      children: [
                        _tile(
                          icon: Icons.child_care_rounded,
                          title: 'Add Children',
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        _tile(
                          icon: Icons.directions_bus_filled_rounded,
                          title: 'Find Drivers',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // App options
                  _card(
                    context,
                    child: Column(
                      children: [
                        _tile(
                          icon: Icons.settings_rounded,
                          title: 'Settings',
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        _tile(
                          icon: Icons.support_agent_rounded,
                          title: 'Support',
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        _tile(
                          icon: Icons.help_outline_rounded,
                          title: 'Help',
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        _tile(
                          icon: Icons.description_outlined,
                          title: 'Terms & Conditions',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Sticky bottom: Rate Us, Logout and version
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Driver Mode button (full width)
                  _gradientButton(
                    icon: Icons.drive_eta_rounded,
                    label: 'Driver Mode',
                    colors: [AppColors.primary, AppColors.primaryDark],
                    onTap: () {
                      // TODO: Navigate to driver mode or toggle profile
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _gradientButton(
                          icon: Icons.star_rate_rounded,
                          label: 'Rate Us',
                          colors: [AppColors.primary, AppColors.primaryDark],
                          onTap: () {
                            // TODO: Implement rate prompt or app store redirect
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _outlineButton(
                          icon: Icons.logout_rounded,
                          label: 'Logout',
                          color: Colors.white,
                          onTap: () {
                            // TODO: Implement logout
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'GoDropMe v1.0.0',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card wrapper for consistent styling
  Widget _card(BuildContext context, {required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.grayLight.withOpacity(0.6),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // Standardized list tile
  Widget _tile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.black,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: AppColors.primary,
        size: 22,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
    );
  }

  // Gradient filled button (e.g., Rate Us)
  Widget _gradientButton({
    required IconData icon,
    required String label,
    required List<Color> colors,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Outlined button (e.g., Logout)
  Widget _outlineButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
