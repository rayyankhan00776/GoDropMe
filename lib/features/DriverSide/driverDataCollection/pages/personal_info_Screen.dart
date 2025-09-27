// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/core/routes/routes.dart';
import 'package:godropme/core/theme/colors.dart';
import 'package:godropme/core/utils/app_strings.dart';
import 'package:godropme/core/utils/app_typography.dart';
import 'package:godropme/core/utils/app_assets.dart';
import 'package:godropme/core/widgets/custom_Appbar.dart';
import 'package:godropme/core/utils/responsive.dart';
import 'package:godropme/core/widgets/custom_image_container.dart';
import 'package:godropme/features/DriverSide/driverDataCollection/widgets/personalinfo/personalinfo_help_screen.dart';
import 'package:godropme/core/widgets/custom_text_field.dart';
import 'package:godropme/core/widgets/progress_next_bar.dart';

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
      body: Column(
        children: [
          Expanded(
            child: Padding(
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
                          onPressed: () =>
                              Get.offNamed(AppRoutes.vehicleSelection),
                          icon: const Icon(
                            Icons.close,
                            size: 29,
                            weight: 800,
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
                            AppStrings.help,
                            style: AppTypography.helpButton,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: Responsive.scaleClamped(context, 8, 6, 12)),

                  // Title (shifted slightly to the right)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      AppStrings.personalInfoTitle,
                      style: AppTypography.optionHeading,
                    ),
                  ),

                  SizedBox(
                    height: Responsive.scaleClamped(context, 18, 12, 24),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: CustomImageContainer(
                      imagePath: null,
                      onTap: () {
                        Get.to(
                          () => const PersonalinfoHelpScreen(
                            imagePath: AppAssets.samplePerson,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: Responsive.scaleClamped(context, 24, 16, 36),
                  ),
                  // Form fields for personal info (name, email, phone)
                  CustomTextField(
                    hintText: AppStrings.firstNameHint,
                    borderColor: AppColors.gray,
                  ),
                  SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),
                  CustomTextField(
                    hintText: AppStrings.surNameHint,
                    borderColor: AppColors.gray,
                  ),
                  SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),
                  CustomTextField(
                    hintText: AppStrings.lastNameHint,
                    borderColor: AppColors.gray,
                  ),
                ],
              ),
            ),
          ),

          // Reusable progress + next bar. No navigation wired; callbacks left null so
          // the user can provide their own handlers later.
          ProgressNextBar(
            currentStep: 1,
            totalSteps: 4,
            onNext: null,
            onPrevious: null,
            previousBackgroundColor: Colors.grey.shade100,
            previousIconColor: Colors.grey.shade400,
          ),
          SizedBox(height: Responsive.scaleClamped(context, 20, 14, 30)),
        ],
      ),
    );
  }
}
