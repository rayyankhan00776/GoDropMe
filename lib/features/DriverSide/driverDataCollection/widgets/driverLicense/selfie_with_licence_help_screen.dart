import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/core/widgets/custom_Appbar.dart';
import 'package:godropme/core/widgets/custom_button.dart';
import 'dart:io';
import 'package:godropme/core/theme/colors.dart';
import 'package:godropme/core/utils/app_typography.dart';
import 'package:godropme/core/utils/responsive.dart';
import 'package:godropme/core/utils/app_strings.dart';
import 'package:image_picker/image_picker.dart';

class SelfieWithLicenceHelpScreen extends StatefulWidget {
  final String imagePath;
  const SelfieWithLicenceHelpScreen({super.key, required this.imagePath});

  @override
  State<SelfieWithLicenceHelpScreen> createState() =>
      _SelfieWithLicenceHelpScreenState();
}

class _SelfieWithLicenceHelpScreenState
    extends State<SelfieWithLicenceHelpScreen> {
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
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1600,
      );

      if (file != null && mounted) {
        setState(() {
          _currentImagePath = file.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to open camera: $e')));
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
                AppStrings.driverLicenseSelfieLabel,
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
                    AppStrings.driverLicenceSelfieHelpLine1,
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
                    AppStrings.driverLicenceSelfieHelpLine2,
                    style: AppTypography.personalInfoHelper,
                  ),
                ),
              ],
            ),

            SizedBox(height: Responsive.scaleClamped(context, 60, 36, 100)),

            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 280,
                  height: 280,
                  child: _currentImagePath.startsWith('assets/')
                      ? Image.asset(_currentImagePath, fit: BoxFit.cover)
                      : Image.file(File(_currentImagePath), fit: BoxFit.cover),
                ),
              ),
            ),

            const Spacer(),

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
