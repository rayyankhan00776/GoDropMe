import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/features/onboard/controllers/onboard_controller.dart';
import 'package:godropme/features/onboard/onboard_constants.dart';
import 'package:godropme/core/theme/colors.dart';
import 'package:godropme/core/utlis/app_strings.dart';
import 'package:godropme/core/utlis/app_typography.dart';
import 'package:godropme/core/utlis/app_assets.dart';
import 'package:godropme/features/onboard/widgets/onboard_page.dart';
import 'package:godropme/features/onboard/widgets/progress_bar.dart';

class OnboardScreen extends StatelessWidget {
  const OnboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller is provided by the route binding; find the instance here.
    final OnboardController ctrl = Get.find();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Use a Stack so we can overlay controls (skip button and right-side dots)
            Expanded(
              child: Stack(
                children: [
                  PageView(
                    controller: ctrl.pageController,
                    onPageChanged: (i) => ctrl.pageIndex.value = i,
                    children: const [
                      OnboardPage(
                        image: AppAssets.onboard1,
                        title: AppStrings.onboardTitle1,
                        subtitle: AppStrings.onboardSubtitle1,
                        titleStyle: AppTypography.onboardTitle,
                        subtitleStyle: AppTypography.onboardSubtitle,
                        showButton: false,
                      ),
                      OnboardPage(
                        image: AppAssets.onboard2,
                        title: AppStrings.onboardTitle2,
                        subtitle: AppStrings.onboardSubtitle2,
                        titleStyle: AppTypography.onboardTitle,
                        subtitleStyle: AppTypography.onboardSubtitle,
                        showButton: false,
                      ),
                      OnboardPage(
                        image: AppAssets.onboard3,
                        title: AppStrings.onboardTitle3,
                        subtitle: AppStrings.onboardSubtitle3,
                        titleStyle: AppTypography.onboardTitle,
                        subtitleStyle: AppTypography.onboardSubtitle,
                        showButton: true,
                      ),
                    ],
                  ),

                  // Top-right skip button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: SafeArea(
                      top: true,
                      child: TextButton(
                        onPressed:
                            () =>
                                ctrl.jumpToPage(OnboardConstants.pageCount - 1),
                        child: Text(
                          AppStrings.onboardSkip,
                          style: AppTypography.onboardSkip,
                        ),
                      ),
                    ),
                  ),

                  // Bottom-centered progress pill (we position it from the bottom)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 28,
                    child: Obx(() => ProgressBar(index: ctrl.pageIndex.value)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// The page and progress bar widgets were moved to `features/onboard/widgets/`.
// See `onboard_page.dart` and `progress_bar.dart` for their implementations.
