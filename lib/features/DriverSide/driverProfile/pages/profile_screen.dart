import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/features/driverSide/common_widgets/driver_drawer_shell.dart';
import 'package:godropme/features/DriverSide/driverProfile/controllers/driver_profile_controller.dart';
import 'package:godropme/features/driverSide/driverProfile/widgets/driver_profile_avatar.dart';
import 'package:godropme/features/driverSide/driverProfile/widgets/driver_profile_caption.dart';
import 'package:godropme/features/driverSide/driverProfile/widgets/driver_profile_section.dart';
import 'package:godropme/features/driverSide/driverProfile/widgets/driver_profile_tile.dart';
import 'package:godropme/services/Terms_uri_opener.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.isRegistered<DriverProfileController>()
        ? Get.find<DriverProfileController>()
        : Get.put(DriverProfileController());

    return DriverDrawerShell(
      body: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            final profile = controller.profile;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Leave space beneath the overlaid drawer button
                SizedBox(height: Responsive.scaleClamped(context, 60, 48, 72)),

                // Title centered
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      AppStrings.profileTitle,
                      textAlign: TextAlign.center,
                      style: AppTypography.optionHeading,
                    ),
                  ),
                ),

                // Avatar + Name (using controller)
                Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: DriverProfileAvatar(
                          size: Responsive.scaleClamped(context, 108, 96, 128),
                          editable: true,
                        ),
                      ),
                      Obx(() => Text(
                        controller.displayName.value.isEmpty 
                            ? 'Driver' 
                            : controller.displayName.value,
                        style: AppTypography.optionLineSecondary.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      )),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                const DriverProfileCaption('Account'),
                DriverProfileSection(
                  children: [
                    // Name tile
                    Obx(() {
                      final name = controller.displayName.value;
                      return DriverProfileTile(
                        title: 'Name',
                        subtitle: name.isEmpty ? 'Not set' : name,
                        showIosChevron: false,
                      );
                    }),
                    const Divider(height: 1),
                    // Email tile
                    Obx(() {
                      final email = (profile['email'] ?? '').toString().trim();
                      return DriverProfileTile(
                        title: 'Email',
                        subtitle: email.isEmpty ? 'Not set' : email,
                        showIosChevron: false,
                      );
                    }),
                    const Divider(height: 1),
                    // Phone tile
                    Obx(() {
                      final phone = (profile['phone'] ?? '').toString().trim();
                      return DriverProfileTile(
                        title: 'Phone',
                        subtitle: phone.isEmpty ? 'Not set' : phone,
                        showIosChevron: false,
                      );
                    }),
                  ],
                ),

                const DriverProfileCaption('Verification'),
                DriverProfileSection(
                  children: [
                    // CNIC
                    Obx(() {
                      final cnic = (profile['cnicNumber'] ?? '').toString().trim();
                      return DriverProfileTile(
                        title: 'CNIC',
                        subtitle: cnic.isEmpty ? 'Not verified' : _formatCnic(cnic),
                        showIosChevron: false,
                      );
                    }),
                    const Divider(height: 1),
                    // License
                    Obx(() {
                      final license = (profile['licenseNumber'] ?? '').toString().trim();
                      return DriverProfileTile(
                        title: 'License',
                        subtitle: license.isEmpty ? 'Not verified' : license,
                        showIosChevron: false,
                      );
                    }),
                  ],
                ),

                // const DriverProfileCaption('Vehicle'),
                // DriverProfileSection(
                //   children: [
                //     // Vehicle info comes from relationships - for now show placeholder
                //     const DriverProfileTile(
                //       title: 'Vehicle',
                //       subtitle: 'View in vehicle section',
                //       showIosChevron: true,
                //     ),
                //   ],
                // ),

                const DriverProfileCaption('Other'),
                DriverProfileSection(
                  children: [
                    DriverProfileTile(
                      title: 'Terms & Conditions',
                      onTap: () async => termsUriOpener(),
                      showIosChevron: true,
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// Format CNIC number with dashes (12345-1234567-1)
  String _formatCnic(String cnic) {
    if (cnic.length == 13) {
      return '${cnic.substring(0, 5)}-${cnic.substring(5, 12)}-${cnic.substring(12)}';
    }
    return cnic;
  }
}
