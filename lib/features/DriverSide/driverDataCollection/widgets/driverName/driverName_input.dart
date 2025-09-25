// ignore_for_file: file_names

import 'package:flutter/material.dart';
// import 'package:godropme/core/theme/colors.dart';
// import 'package:godropme/core/utils/app_typography.dart';
import 'package:godropme/core/widgets/custom_text_field.dart';

class DrivernameInput extends StatelessWidget {
  final TextEditingController controller;
  final double height;

  const DrivernameInput({
    required this.controller,
    this.height = 64,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // final String? errorText = validator?.call(controller.text);
    return Column(
      children: [
        CustomTextField(
          controller: controller,
          hintText: 'Full Name',
          height: height,
          borderColor: const Color(0xFF756AED), // primary
          validator:
              (v) =>
                  v == null || v.trim().isEmpty
                      ? 'Please enter full name'
                      : null,
        ),
        const SizedBox(height: 6),
        // SizedBox(
        //   height: 18,
        //   child: Align(
        //     alignment: Alignment.center,
        //     child: Text(
        //       errorText ?? '',
        //       style: AppTypography.optionLineSecondary.copyWith(
        //         color:
        //             errorText != null ? AppColors.accent : Colors.transparent,
        //         fontSize: 12,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
