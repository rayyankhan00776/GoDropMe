import 'package:flutter/material.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:image_picker/image_picker.dart';
import 'package:godropme/shared/widgets/document_help_screen.dart';

class SelfieWithLicenceHelpScreen extends StatelessWidget {
  final String imagePath;
  const SelfieWithLicenceHelpScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return DocumentHelpScreen(
      title: AppStrings.driverLicenseSelfieLabel,
      helpLines: const [
        AppStrings.driverLicenceSelfieHelpLine1,
        AppStrings.driverLicenceSelfieHelpLine2,
      ],
      initialImagePath: imagePath,
      takeNewPictureLabel: AppStrings.driverLicenceTakeNewPicture,
      camera: const CameraConfig(
        device: CameraDevice.front,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1600,
      ),
    );
  }
}
