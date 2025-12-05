// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/common_widgets/custom_button.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/constants/button_dimensions.dart';

class ParentnameAction extends StatelessWidget {
  final VoidCallback onNext;
  final double height;
  final bool isLoading;

  const ParentnameAction({
    required this.onNext, 
    this.height = 64, 
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          text: isLoading ? 'Creating Profile...' : AppStrings.parentNameButton,
          onTap: isLoading ? null : onNext,
          height: height,
          width: double.infinity,
          borderRadius: BorderRadius.circular(AppButtonDimensions.borderRadius),
          textColor: Colors.white,
        ),
        SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),
      ],
    );
  }
}
