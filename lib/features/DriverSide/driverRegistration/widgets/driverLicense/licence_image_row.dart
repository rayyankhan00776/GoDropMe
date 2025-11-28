import 'package:flutter/material.dart';
import 'package:godropme/common_widgets/custom_image_container.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/utils/app_typography.dart';

/// A small reusable widget that shows two image containers side-by-side:
/// - left: licence image
/// - right: selfie with licence
///
/// Taps are delegated to the provided callbacks so the parent can open help
/// screens and receive the selected image path.
class LicenceImageRow extends StatelessWidget {
  final String? licenceImagePath;
  final String? selfieImagePath;
  final VoidCallback? onLicenceTap;
  final VoidCallback? onSelfieTap;

  const LicenceImageRow({
    super.key,
    required this.licenceImagePath,
    required this.selfieImagePath,
    this.onLicenceTap,
    this.onSelfieTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomImageContainer(
                  imagePath: licenceImagePath,
                  width: double.infinity,
                  height: 140,
                  onTap: onLicenceTap,
                ),
                SizedBox(height: Responsive.scaleClamped(context, 8, 6, 12)),
                Text('Licence', style: AppTypography.optionTerms),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomImageContainer(
                  imagePath: selfieImagePath,
                  width: double.infinity,
                  height: 140,
                  onTap: onSelfieTap,
                ),
                SizedBox(height: Responsive.scaleClamped(context, 8, 6, 12)),
                Text('Selfie with Licence', style: AppTypography.optionTerms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
