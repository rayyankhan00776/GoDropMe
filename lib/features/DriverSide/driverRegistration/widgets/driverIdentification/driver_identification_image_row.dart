import 'package:flutter/material.dart';
import 'package:godropme/common%20widgets/custom_image_container.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/utils/app_typography.dart';

class DriverIdentificationImageRow extends StatelessWidget {
  final String? frontImagePath;
  final String? backImagePath;
  final VoidCallback? onFrontTap;
  final VoidCallback? onBackTap;

  const DriverIdentificationImageRow({
    super.key,
    required this.frontImagePath,
    required this.backImagePath,
    this.onFrontTap,
    this.onBackTap,
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
                  imagePath: frontImagePath,
                  width: double.infinity,
                  height: 140,
                  onTap: onFrontTap,
                ),
                SizedBox(height: Responsive.scaleClamped(context, 8, 6, 12)),
                Text('CNIC Front Side', style: AppTypography.optionTerms),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomImageContainer(
                  imagePath: backImagePath,
                  width: double.infinity,
                  height: 140,
                  onTap: onBackTap,
                ),
                SizedBox(height: Responsive.scaleClamped(context, 8, 6, 12)),
                Text('CNIC Back Side', style: AppTypography.optionTerms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
