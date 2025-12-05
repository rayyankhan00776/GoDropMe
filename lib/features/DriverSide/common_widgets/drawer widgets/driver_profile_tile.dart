// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_assets.dart';
import 'package:godropme/utils/app_typography.dart';

class DriverProfileTile extends StatelessWidget {
  final VoidCallback? onTap;
  const DriverProfileTile({super.key, this.onTap});

  Widget _buildAvatar(String? path) {
    // First check driverProfileImage, then fallback to personalInfo imagePath
    if (path != null && path.isNotEmpty && !path.startsWith('assets/')) {
      final file = File(path);
      if (file.existsSync()) {
        return ClipOval(
          child: Image.file(file, width: 52, height: 52, fit: BoxFit.cover),
        );
      }
    }
    // If it's an asset path or null, fallback to default SVG avatar
    return ClipOval(
      child: SvgPicture.asset(
        AppAssets.defaultPersonSvg,
        width: 38,
        height: 38,
        fit: BoxFit.cover,
      ),
    );
  }
  
  /// Get full name from KYC personal info, fallback to registration name
  Future<String> _getDisplayName() async {
    // First try KYC personal info
    final personalInfo = await LocalStorage.getJson(StorageKeys.personalInfo);
    if (personalInfo != null) {
      final f = (personalInfo['firstName'] ?? '').toString().trim();
      final s = (personalInfo['surName'] ?? '').toString().trim();
      final l = (personalInfo['lastName'] ?? '').toString().trim();
      final kycName = [f, s, l].where((e) => e.isNotEmpty).join(' ');
      if (kycName.isNotEmpty) return kycName;
    }
    // Fallback to registration name
    final regName = await LocalStorage.getString(StorageKeys.driverName);
    return regName ?? '';
  }
  
  /// Get profile image path - check driverProfileImage first, then personalInfo
  Future<String?> _getProfileImagePath() async {
    // First check dedicated profile image
    final profileImage = await LocalStorage.getString(StorageKeys.driverProfileImage);
    if (profileImage != null && profileImage.isNotEmpty) {
      return profileImage;
    }
    // Fallback to personalInfo imagePath
    final personalInfo = await LocalStorage.getJson(StorageKeys.personalInfo);
    return personalInfo?['imagePath'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(12),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: Colors.white,
        child: FutureBuilder<String?>(
          future: _getProfileImagePath(),
          builder: (context, snapshot) {
            return _buildAvatar(snapshot.data);
          },
        ),
      ),
      title: FutureBuilder<String>(
        future: _getDisplayName(),
        builder: (context, snapshot) {
          final displayName = (snapshot.data != null && snapshot.data!.trim().isNotEmpty)
              ? snapshot.data!.trim()
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
        'Driver',
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
