import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:godropme/common_widgets/custom_Appbar.dart';
import 'package:godropme/common_widgets/custom_button.dart';
import 'package:godropme/common_widgets/custom_image_container.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/constants/app_strings.dart';

class CameraConfig {
  final CameraDevice device;
  final int imageQuality; // 0-100
  final double? maxWidth;
  final double? maxHeight;

  const CameraConfig({
    required this.device,
    this.imageQuality = 85,
    this.maxWidth,
    this.maxHeight,
  });
}

/// A parameterized help screen used across driver onboarding flows to preview
/// an image, show 1-2 instruction lines, and allow retaking the picture.
///
/// It preserves the exact structure and styling used by existing help screens
/// while centralizing the repeated UI/logic. When the user taps Done, the
/// current image path is returned via Navigator.pop<>(path).
class DocumentHelpScreen extends StatefulWidget {
  final String title;
  final List<String> helpLines; // rendered as two bullet rows when length==2
  final String initialImagePath;
  final String doneLabel;
  final String takeNewPictureLabel;
  final CameraConfig camera;

  const DocumentHelpScreen({
    super.key,
    required this.title,
    required this.helpLines,
    required this.initialImagePath,
    this.doneLabel = AppStrings.done,
    required this.takeNewPictureLabel,
    required this.camera,
  });

  @override
  State<DocumentHelpScreen> createState() => _DocumentHelpScreenState();
}

class _DocumentHelpScreenState extends State<DocumentHelpScreen> {
  final ImagePicker _picker = ImagePicker();
  late String _currentImagePath;

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.initialImagePath;
  }

  Future<void> _takeNewPicture() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: widget.camera.device,
        imageQuality: widget.camera.imageQuality,
        maxWidth: widget.camera.maxWidth,
        maxHeight: widget.camera.maxHeight,
      );
      if (file != null && mounted) {
        setState(() => _currentImagePath = file.path);
      }
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Camera',
        '${AppStrings.unableToOpenCameraPrefix}$e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black.withValues(alpha: 0.85),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomBlurAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.black),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_currentImagePath),
                    child: Text(
                      widget.doneLabel,
                      style: AppTypography.helpButton,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: Responsive.scaleClamped(context, 16, 12, 24)),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(widget.title, style: AppTypography.optionHeading),
            ),
            SizedBox(height: Responsive.scaleClamped(context, 16, 12, 24)),

            // Up to two instruction rows, matching original visuals
            for (int i = 0; i < widget.helpLines.length && i < 2; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check, color: Colors.black, size: 30),
                  SizedBox(width: Responsive.scaleClamped(context, 8, 6, 12)),
                  Expanded(
                    child: Text(
                      widget.helpLines[i],
                      style: AppTypography.personalInfoHelper,
                    ),
                  ),
                ],
              ),
              if (i == 0)
                SizedBox(height: Responsive.scaleClamped(context, 8, 6, 12)),
            ],

            SizedBox(height: Responsive.scaleClamped(context, 12, 8, 20)),

            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomImageContainer(
                    imagePath: _currentImagePath,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    backgroundColor: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    onTap: null,
                  ),
                ),
              ),
            ),

            SizedBox(height: Responsive.scaleClamped(context, 12, 8, 20)),

            CustomButton(
              text: widget.takeNewPictureLabel,
              onTap: _takeNewPicture,
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
