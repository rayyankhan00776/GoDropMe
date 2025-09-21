import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/features/onboard/controllers/onboard_controller.dart';
import 'package:godropme/core/theme/colors.dart';
import 'package:godropme/core/utils/responsive.dart';

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
            // Make pill width responsive: prefer 40% of available width but
            // clamp between 120 and 220 to preserve original visual weight.
            final maxAvailable = constraints.maxWidth;
            final preferred = maxAvailable * 0.4;
            final totalWidth = preferred.clamp(
              Responsive.scaleClamped(context, 120, 120, 220),
              220.0,
            );

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
