import 'package:flutter/material.dart';
import 'package:godropme/core/widgets/custom_image_container.dart';
import 'package:godropme/core/utils/responsive.dart';
import 'package:godropme/core/utils/app_typography.dart';

/// Small reusable widget for the image preview + validation message used in
/// PersonalInfoScreen.
class PersonalinfoImage extends StatelessWidget {
  final String? imagePath;
  final VoidCallback? onTap;
  final bool showError;
  final String errorText;

  const PersonalinfoImage({
    super.key,
    required this.imagePath,
    required this.onTap,
    this.showError = false,
    this.errorText = 'Please add a profile picture',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomImageContainer(imagePath: imagePath, onTap: onTap),

        SizedBox(height: Responsive.scaleClamped(context, 8, 6, 12)),

        // Section heading under the image matching the size used above the
        // text fields in PersonalInfoScreen.
        Text('Personal Picture', style: AppTypography.optionTerms),

        SizedBox(height: Responsive.scaleClamped(context, 6, 4, 8)),

        SizedBox(
          height: 18,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              showError ? errorText : '',
              style: TextStyle(
                color: showError ? const Color(0xFFFF6B6B) : Colors.transparent,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
