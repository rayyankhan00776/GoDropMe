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
    // If we have a local file path (non-asset), show Image.file
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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(12),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: Colors.white,
        child: FutureBuilder<Map<String, dynamic>?>(
          future: LocalStorage.getJson(StorageKeys.personalInfo),
          builder: (context, snapshot) {
            final imagePath = snapshot.data?['imagePath'] as String?;
            return _buildAvatar(imagePath);
          },
        ),
      ),
      title: FutureBuilder<String?>(
        future: LocalStorage.getString(StorageKeys.driverName),
        builder: (context, snapshot) {
          final raw = snapshot.data;
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
