import 'package:flutter/material.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:image_picker/image_picker.dart';
import 'package:godropme/shared/widgets/document_help_screen.dart';

class VehicleCertFrontHelpScreen extends StatelessWidget {
  final String imagePath;
  const VehicleCertFrontHelpScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return DocumentHelpScreen(
      title: AppStrings.vehicleCertFrontLabel,
      helpLines: const [
        AppStrings.vehicleCertHelpLine1,
        AppStrings.vehicleCertHelpLine2,
      ],
      initialImagePath: imagePath,
      takeNewPictureLabel: AppStrings.vehicleTakeNewPicture,
      camera: const CameraConfig(
        device: CameraDevice.rear,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1200,
      ),
    );
  }
}
