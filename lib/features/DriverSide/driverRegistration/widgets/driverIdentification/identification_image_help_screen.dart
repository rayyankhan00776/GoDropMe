import 'package:flutter/material.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:image_picker/image_picker.dart';
import 'package:godropme/shared/widgets/document_help_screen.dart';

class IdentificationImageHelpScreen extends StatelessWidget {
  final String imagePath;
  final String title;

  const IdentificationImageHelpScreen({
    super.key,
    required this.imagePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return DocumentHelpScreen(
      title: title,
      helpLines: const [
        AppStrings.driverLicenceHelpLine1,
        AppStrings.driverLicenceHelpLine2,
      ],
      initialImagePath: imagePath,
      takeNewPictureLabel: AppStrings.driverLicenceTakeNewPicture,
      camera: const CameraConfig(
        device: CameraDevice.rear,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1200,
      ),
    );
  }
}
