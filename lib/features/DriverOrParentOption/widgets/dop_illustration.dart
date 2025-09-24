import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:godropme/core/utils/app_assets.dart';
import 'package:godropme/core/utils/responsive.dart';
import 'dart:math' as math;

/// Responsive illustration that mirrors the sizing logic used in
/// the option illustration to keep visual consistency across screens.
class DopIllustration extends StatelessWidget {
  const DopIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = Responsive.screenWidth(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight =
            constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : Responsive.screenHeight(context);

        // Prefer width-driven size but cap it by available height (80%).
        // Allow the max to grow on large screens so the illustration
        // becomes bigger on wide displays while keeping small-screen
        // behavior intact.
        final maxClamp = math.max(360.0, screenWidth * 0.45);
        final widthDriven = (screenWidth * 0.75).clamp(180.0, maxClamp);
        final heightCap = math.max(120.0, maxHeight * 0.8);
        final illustrationSize = math.min(widthDriven, heightCap);

        return SizedBox(
          width: illustrationSize,
          height: illustrationSize,
          child: SvgPicture.asset(
            AppAssets.dopIllustration,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }
}
