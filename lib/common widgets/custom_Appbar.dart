// ignore_for_file: deprecated_member_use, file_names

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/routes/routes.dart';
import 'package:godropme/utils/local_storage.dart';
import 'package:godropme/core/theme/colors.dart';

class CustomBlurAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomBlurAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 2);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 4,
      automaticallyImplyLeading: false,
      title: Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: () async {
            // Clear any cached onboarding progress so the next time the user
            // enters onboarding they start fresh.
            await Future.microtask(() {}); // keep async slot
            try {
              await LocalStorage.clearOnboardingData();
            } catch (_) {}
            Get.offNamed(AppRoutes.dopOption);
          },
          child: Text(
            "Close",
            style: TextStyle(
              color: AppColors.darkGray,
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      // Provide a blurred dark translucent background behind the app bar
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(color: Colors.black.withOpacity(0.03)),
        ),
      ),
    );
  }
}
