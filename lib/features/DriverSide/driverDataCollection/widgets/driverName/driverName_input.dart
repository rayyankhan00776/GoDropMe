// ignore_for_file: file_names

import 'package:flutter/material.dart';
// import 'package:godropme/core/theme/colors.dart';
// import 'package:godropme/core/utils/app_typography.dart';
import 'package:godropme/core/widgets/custom_text_field.dart';

class DrivernameInput extends StatelessWidget {
  final TextEditingController controller;
  final double height;
  final TextValidator? validator;
  final bool showError;

  const DrivernameInput({
    required this.controller,
    this.height = 69,
    this.validator,
    this.showError = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Use provided validator or fallback to non-empty check
    final TextValidator localValidator =
        validator ??
        (v) => v == null || v.trim().isEmpty ? 'Please enter full name' : null;

    // Compute current validation text from controller value so we can
    // display a fixed-height error area beneath the input like PhoneInputRow.
    final String? errorText = localValidator.call(controller.text);
    final String? displayError = showError ? errorText : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: controller,
          hintText: 'Full Name',
          height: height,
          borderColor: const Color(0xFF756AED), // primary
          validator: localValidator,
        ),
        const SizedBox(height: 6),

        // Fixed-height area for validation messages so showing an error does
        // not resize surrounding widgets. Matches PhoneInputRow behavior.
        SizedBox(
          height: 18,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              displayError ?? '',
              style: TextStyle(
                color: displayError != null
                    ? const Color(0xFFFF6B6B)
                    : Colors.transparent,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
