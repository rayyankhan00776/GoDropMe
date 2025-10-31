// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/utils/app_assets.dart';

class DriverProfileAvatar extends StatelessWidget {
  final double size;
  final String? imagePath;
  const DriverProfileAvatar({super.key, this.size = 108, this.imagePath});

  Widget _buildAvatar(BuildContext context, String? path) {
    // If it's an asset placeholder or null/empty, show default SVG
    if (path == null || path.isEmpty || path.startsWith('assets/')) {
      return ClipOval(
        child: SvgPicture.asset(
          AppAssets.defaultPersonSvg,
          width: size * 0.7,
          height: size * 0.7,
          fit: BoxFit.cover,
        ),
      );
    }

    // Avoid synchronous disk I/O in build; rely on errorBuilder fallback.
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final target = (size * dpr).clamp(64, 1024).round();
    return ClipOval(
      child: Image.file(
        File(path),
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: target,
        cacheHeight: target,
        filterQuality: FilterQuality.low,
        errorBuilder: (context, error, stack) => SvgPicture.asset(
          AppAssets.defaultPersonSvg,
          width: size * 0.7,
          height: size * 0.7,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If a path is provided, use it directly to avoid extra futures
    if (imagePath != null) {
      return RepaintBoundary(
        child: SizedBox(
          width: size,
          height: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
              border: Border.all(color: Colors.grey.shade400, width: 2),
            ),
            child: Center(child: _buildAvatar(context, imagePath)),
          ),
        ),
      );
    }
    // Fallback: fetch from storage if no path was passed
    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: FutureBuilder<Map<String, dynamic>?>(
          future: LocalStorage.getJson(StorageKeys.personalInfo),
          builder: (context, snapshot) {
            final path = snapshot.data?['imagePath'] as String?;
            return DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.grey.shade400, width: 2),
              ),
              child: Center(child: _buildAvatar(context, path)),
            );
          },
        ),
      ),
    );
  }
}
