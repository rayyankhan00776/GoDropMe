import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/common%20widgets/custom_Appbar.dart';
import 'package:godropme/common%20widgets/custom_button.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:image_picker/image_picker.dart';
import 'package:godropme/common%20widgets/custom_image_container.dart';

class LicenceImageHelpScreen extends StatefulWidget {
  final String imagePath;
  const LicenceImageHelpScreen({super.key, required this.imagePath});

  @override
  State<LicenceImageHelpScreen> createState() => _LicenceImageHelpScreenState();
}

class _LicenceImageHelpScreenState extends State<LicenceImageHelpScreen> {
  final ImagePicker _picker = ImagePicker();
  late String _currentImagePath;

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.imagePath;
  }

  Future<void> _takeNewPicture() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1200,
      );

      if (file != null && mounted) {
        setState(() {
          _currentImagePath = file.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.unableToOpenCameraPrefix}$e')),
        );
      }
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
                    icon: Icon(Icons.arrow_back, color: AppColors.black),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_currentImagePath),
                    child: Text('Done', style: AppTypography.helpButton),
                  ),
                ),
              ],
            ),

            SizedBox(height: Responsive.scaleClamped(context, 16, 12, 24)),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                AppStrings.driverLicenceTitle,
                style: AppTypography.optionHeading,
              ),
            ),
            SizedBox(height: Responsive.scaleClamped(context, 16, 12, 24)),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check, color: Colors.black, size: 30),
                SizedBox(width: Responsive.scaleClamped(context, 8, 6, 12)),
                Expanded(
                  child: Text(
                    AppStrings.driverLicenceHelpLine1,
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
                    AppStrings.driverLicenceHelpLine2,
                    style: AppTypography.personalInfoHelper,
                  ),
                ),
              ],
            ),

            SizedBox(height: Responsive.scaleClamped(context, 12, 8, 20)),

            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomImageContainer(
                    imagePath: _currentImagePath,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    backgroundColor: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    onTap: null,
                  ),
                ),
              ),
            ),

            SizedBox(height: Responsive.scaleClamped(context, 12, 8, 20)),

            CustomButton(
              text: AppStrings.driverLicenceTakeNewPicture,
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
