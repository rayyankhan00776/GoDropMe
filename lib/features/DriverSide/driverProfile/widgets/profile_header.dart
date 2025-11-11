import 'package:flutter/material.dart';
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
              imagePath: personalInfo?['imagePath'] as String?,
            ),
          ),
          Text(
            displayName.isEmpty ? 'Driver' : displayName,
            style: AppTypography.optionLineSecondary.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
