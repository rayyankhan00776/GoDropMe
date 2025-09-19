import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/features/onboard/controllers/onboard_controller.dart';
import 'package:godropme/core/theme/colors.dart';

/// Animated, tappable progress bar for onboarding.
/// It responds smoothly to the PageView scroll via [OnboardController.pageOffset].
class ProgressBar extends StatelessWidget {
  final int index;

  const ProgressBar({required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardController ctrl = Get.find();

    // Bottom-centered pill style: a light track with a colored filled portion
    // representing progress. Progress is driven by pageOffset (0..2) and
    // mapped to 0..1 fill percentage.
    return SizedBox(
      height: 24,
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = 160.0; // visual width of the pill

            return SizedBox(
              width: totalWidth,
              child: Obx(() {
                final offset = ctrl.pageOffset.value.clamp(0.0, 2.0);
                final fillPercent = (offset / 2.0).clamp(0.0, 1.0);

                return Stack(
                  children: [
                    // track
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.grayLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    // filled portion
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: totalWidth * fillPercent,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
