import 'package:flutter/material.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:image_picker/image_picker.dart';
import 'package:godropme/shared/widgets/document_help_screen.dart';

class PersonalinfoHelpScreen extends StatelessWidget {
  final String imagePath;
  const PersonalinfoHelpScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return DocumentHelpScreen(
      title: AppStrings.personalInfoTitle,
      helpLines: const [
        AppStrings.personalInfoHelpLine1,
        AppStrings.personalInfoHelpLine2,
      ],
      initialImagePath: imagePath,
      takeNewPictureLabel: AppStrings.personalInfoTakeNewPicture,
      camera: const CameraConfig(
        device: CameraDevice.front,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1600,
      ),
    );
  }
}
