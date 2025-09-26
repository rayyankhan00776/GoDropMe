// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/core/routes/routes.dart';
import 'package:godropme/core/theme/colors.dart';
import 'package:godropme/core/utils/app_strings.dart';
import 'package:godropme/core/utils/app_typography.dart';
import 'package:godropme/core/widgets/custom_Appbar.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomBlurAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon-only back button under appbar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Get.offNamed(AppRoutes.vehicleSelection),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      size: 25,
                      color: AppColors.darkGray,
                    ),
                    splashRadius: 20,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "Help",
                      style: TextStyle(
                        color: AppColors.lightGreen,
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Title (shifted slightly to the right)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                AppStrings.personalInfoTitle,
                style: AppTypography.optionHeading,
              ),
            ),

            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
