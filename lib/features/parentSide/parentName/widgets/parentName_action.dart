// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/common%20widgets/custom_button.dart';
import 'package:godropme/utils/app_strings.dart';
import 'package:godropme/core/theme/button_dimensions.dart';

class ParentnameAction extends StatelessWidget {
  final VoidCallback onNext;
  final double height;

  const ParentnameAction({required this.onNext, this.height = 64, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          text: AppStrings.parentNameButton,
          onTap: onNext,
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
