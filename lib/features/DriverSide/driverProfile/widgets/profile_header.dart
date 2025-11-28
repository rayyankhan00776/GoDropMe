import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/features/driverSide/driverProfile/controllers/driver_profile_controller.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'driver_profile_avatar.dart';

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic>? personalInfo;
  final String displayName;
  const ProfileHeader({
    super.key,
    required this.personalInfo,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: DriverProfileAvatar(
              size: Responsive.scaleClamped(context, 108, 96, 128),
              editable: true, // Make avatar editable
            ),
          ),
          // Use controller for reactive name display
          GetX<DriverProfileController>(
            init: Get.isRegistered<DriverProfileController>()
                ? Get.find<DriverProfileController>()
                : Get.put(DriverProfileController()),
            builder: (controller) {
              final name = controller.displayName.value.isNotEmpty 
                  ? controller.displayName.value 
                  : displayName;
              return Text(
                name.isEmpty ? 'Driver' : name,
                style: AppTypography.optionLineSecondary.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
