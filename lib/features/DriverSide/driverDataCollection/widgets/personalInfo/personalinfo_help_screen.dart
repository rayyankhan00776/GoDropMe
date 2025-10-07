import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/core/widgets/custom_Appbar.dart';
import 'package:godropme/core/widgets/custom_button.dart';
import 'package:godropme/core/widgets/custom_image_container.dart';
import 'package:godropme/core/theme/colors.dart';
import 'package:godropme/core/utils/app_typography.dart';
import 'package:godropme/core/utils/responsive.dart';
import 'package:godropme/core/utils/app_strings.dart';
import 'package:image_picker/image_picker.dart';

class PersonalinfoHelpScreen extends StatefulWidget {
  final String imagePath;

  const PersonalinfoHelpScreen({super.key, required this.imagePath});

  @override
  State<PersonalinfoHelpScreen> createState() => _PersonalinfoHelpScreenState();
}

class _PersonalinfoHelpScreenState extends State<PersonalinfoHelpScreen> {
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
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1600,
      );

      if (file != null && mounted) {
        setState(() {
          _currentImagePath = file.path;
        });
      }
    } catch (e) {
      // If permission denied or camera error, show a simple snackbar and stay
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
            // Back icon and title (match PersonalInfo screen heading)
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
                AppStrings.personalInfoTitle,
                style: AppTypography.optionHeading,
              ),
            ),
            SizedBox(height: Responsive.scaleClamped(context, 16, 12, 24)),

            // Two instruction rows with plain tick icons (black, size 30) and larger text
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check, color: Colors.black, size: 30),
                SizedBox(width: Responsive.scaleClamped(context, 8, 6, 12)),
                Expanded(
                  child: Text(
                    AppStrings.personalInfoHelpLine1,
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
                    AppStrings.personalInfoHelpLine2,
                    style: AppTypography.personalInfoHelper,
                  ),
                ),
              ],
            ),

            SizedBox(height: Responsive.scaleClamped(context, 60, 36, 100)),

            // Image preview container (re-using CustomImageContainer in read-only mode)
            Center(
              child: CustomImageContainer(
                imagePath: _currentImagePath,
                width: 300,
                height: 340,
                fit: BoxFit.fill,
                alignment: Alignment.center,
                backgroundColor: Colors.grey[50],
                onTap: null,
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            const Spacer(),

            // Take a new picture button
            CustomButton(
              text: AppStrings.personalInfoTakeNewPicture,
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
