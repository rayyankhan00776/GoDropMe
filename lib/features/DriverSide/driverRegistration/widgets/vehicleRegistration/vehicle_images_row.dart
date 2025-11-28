import 'package:flutter/material.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/common_widgets/custom_image_container.dart';

class VehicleImagesRow extends StatelessWidget {
  final String? photoPath;
  final String? certFrontPath;
  final String? certBackPath;
  final VoidCallback? onPhotoTap;
  final VoidCallback? onCertFrontTap;
  final VoidCallback? onCertBackTap;
  final String photoLabel;
  final String certFrontLabel;
  final String certBackLabel;

  const VehicleImagesRow({
    super.key,
    required this.photoPath,
    required this.certFrontPath,
    required this.certBackPath,
    this.onPhotoTap,
    this.onCertFrontTap,
    this.onCertBackTap,
    required this.photoLabel,
    required this.certFrontLabel,
    required this.certBackLabel,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure labels do not change the overall height by fixing a caption area
    final captionHeight = Responsive.scaleClamped(context, 36, 28, 44);
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomImageContainer(
                  imagePath: photoPath,
                  width: double.infinity,
                  height: 120,
                  onTap: onPhotoTap,
                ),
                SizedBox(height: Responsive.scaleClamped(context, 8, 6, 12)),
                SizedBox(
                  height: captionHeight,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      photoLabel,
                      style: AppTypography.optionTerms,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomImageContainer(
                  imagePath: certFrontPath,
                  width: double.infinity,
                  height: 120,
                  onTap: onCertFrontTap,
                ),
                SizedBox(height: Responsive.scaleClamped(context, 8, 6, 12)),
                SizedBox(
                  height: captionHeight,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      certFrontLabel,
                      style: AppTypography.optionTerms,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomImageContainer(
                  imagePath: certBackPath,
                  width: double.infinity,
                  height: 120,
                  onTap: onCertBackTap,
                ),
                SizedBox(height: Responsive.scaleClamped(context, 8, 6, 12)),
                SizedBox(
                  height: captionHeight,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      certBackLabel,
                      style: AppTypography.optionTerms,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
