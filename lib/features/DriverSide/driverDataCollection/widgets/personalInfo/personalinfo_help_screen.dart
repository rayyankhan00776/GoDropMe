import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/core/widgets/custom_Appbar.dart';
import 'package:godropme/core/widgets/custom_button.dart';
import 'package:godropme/core/widgets/custom_image_container.dart';
import 'package:godropme/core/theme/colors.dart';
import 'package:godropme/core/utils/app_typography.dart';
import 'package:godropme/core/utils/responsive.dart';
import 'package:godropme/core/utils/app_strings.dart';

class PersonalinfoHelpScreen extends StatelessWidget {
  final String imagePath;

  const PersonalinfoHelpScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomBlurAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back icon and title (match PersonalInfo screen heading)
            Row(
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.arrow_back, color: AppColors.black),
                ),
                SizedBox(width: Responsive.scaleClamped(context, 8, 6, 12)),
              ],
            ),

            SizedBox(height: Responsive.scaleClamped(context, 16, 12, 24)),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                AppStrings.personalInfoTitle,
                style: AppTypography.optionHeading,
              ),
            ),
            SizedBox(height: Responsive.scaleClamped(context, 16, 12, 24)),

            // Two instruction rows with plain tick icons (black, size 30) and larger text
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check, color: Colors.black, size: 30),
                SizedBox(width: Responsive.scaleClamped(context, 8, 6, 12)),
                Expanded(
                  child: Text(
                    AppStrings.personalInfoHelpLine1,
                    style: AppTypography.personalInfoHelper,
                  ),
                ),
              ],
            ),

            SizedBox(height: Responsive.scaleClamped(context, 8, 6, 12)),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check, color: Colors.black, size: 30),
                SizedBox(width: Responsive.scaleClamped(context, 8, 6, 12)),
                Expanded(
                  child: Text(
                    AppStrings.personalInfoHelpLine2,
                    style: AppTypography.personalInfoHelper,
                  ),
                ),
              ],
            ),

            SizedBox(height: Responsive.scaleClamped(context, 60, 36, 100)),

            // Image preview container (re-using CustomImageContainer in read-only mode)
            Center(
              child: CustomImageContainer(
                imagePath: imagePath,
                width: 280,
                height: 280,
                onTap: null,
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            const Spacer(),

            // Take a new picture button
            CustomButton(
              text: AppStrings.personalInfoTakeNewPicture,
              onTap: () {},
              height: 59,
              borderRadius: BorderRadius.circular(12),
            ),
            SizedBox(height: Responsive.scaleClamped(context, 20, 14, 30)),
          ],
        ),
      ),
    );
  }
}
