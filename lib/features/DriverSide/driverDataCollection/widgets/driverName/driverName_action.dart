// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:godropme/core/utils/responsive.dart';
import 'package:godropme/core/widgets/custom_button.dart';
import 'package:godropme/core/utils/app_strings.dart';

class DrivernameAction extends StatelessWidget {
  final VoidCallback onNext;
  final double height;

  const DrivernameAction({required this.onNext, this.height = 64, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          text: AppStrings.driverNameButton,
          onTap: onNext,
          height: height,
          width: double.infinity,
          borderRadius: BorderRadius.circular(12),
          textColor: Colors.white,
        ),
        SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),
      ],
    );
  }
}
