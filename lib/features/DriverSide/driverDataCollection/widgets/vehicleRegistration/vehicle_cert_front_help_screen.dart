import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:godropme/core/widgets/custom_Appbar.dart';
import 'package:godropme/core/widgets/custom_button.dart';
import 'package:godropme/core/widgets/custom_image_container.dart';
import 'package:godropme/core/utils/app_typography.dart';
import 'package:godropme/core/utils/app_strings.dart';
import 'package:godropme/core/utils/responsive.dart';
import 'package:godropme/core/theme/colors.dart';

class VehicleCertFrontHelpScreen extends StatefulWidget {
  final String imagePath;
  const VehicleCertFrontHelpScreen({super.key, required this.imagePath});

  @override
  State<VehicleCertFrontHelpScreen> createState() =>
      _VehicleCertFrontHelpScreenState();
}

class _VehicleCertFrontHelpScreenState
    extends State<VehicleCertFrontHelpScreen> {
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
        setState(() => _currentImagePath = file.path);
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
                    icon: const Icon(Icons.arrow_back, color: AppColors.black),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(_currentImagePath),
                    child: Text(
                      AppStrings.done,
                      style: AppTypography.helpButton,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: Responsive.scaleClamped(context, 16, 12, 24)),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                AppStrings.vehicleCertFrontLabel,
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
                    AppStrings.vehicleCertHelpLine1,
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
                    AppStrings.vehicleCertHelpLine2,
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
              text: AppStrings.vehicleTakeNewPicture,
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
