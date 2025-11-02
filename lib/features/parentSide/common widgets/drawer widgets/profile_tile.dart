// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_assets.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/models/parent_profile.dart';

class ProfileTile extends StatelessWidget {
  final VoidCallback? onTap;
  const ProfileTile({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
      title: FutureBuilder<ParentProfile>(
        future: ParentProfile.loadFromLocal(),
        builder: (context, snapshot) {
          final raw = snapshot.data?.fullName;
          final displayName = (raw != null && raw.trim().isNotEmpty)
              ? raw.trim()
              : AppStrings.drawerProfileNamePlaceholder;
          return Text(
            displayName,
            style: AppTypography.optionLineSecondary.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          );
        },
      ),
      subtitle: Text(
        AppStrings.drawerProfileRoleParent,
        style: AppTypography.optionLineSecondary.copyWith(
          fontSize: 13,
          color: AppColors.darkGray,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: AppColors.primary,
        size: 24,
      ),
      onTap: onTap,
    );
  }
}
