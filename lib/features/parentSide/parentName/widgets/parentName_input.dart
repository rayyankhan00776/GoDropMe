// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:godropme/utils/responsive.dart';
// import 'package:godropme/core/theme/colors.dart';
// import 'package:godropme/core/utils/app_typography.dart';
import 'package:godropme/common%20widgets/custom_text_field.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/theme/colors.dart';

class ParentnameInput extends StatelessWidget {
  final TextEditingController controller;
  final double height;
  final TextValidator? validator;
  final bool showError;

  const ParentnameInput({
    required this.controller,
    this.height = 56,
    this.validator,
    this.showError = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Use provided validator or fallback to non-empty check
    final TextValidator localValidator =
        validator ??
        (v) => v == null || v.trim().isEmpty ? AppStrings.enterFullName : null;

    // Compute current validation text from controller value so we can
    // display a fixed-height error area beneath the input like PhoneInputRow.
    final String? errorText = localValidator.call(controller.text);
    final String? displayError = showError ? errorText : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: controller,
          hintText: AppStrings.fullNameHint,
          height: height,
          borderColor: AppColors.primary,
          validator: localValidator,
        ),
        SizedBox(height: Responsive.scaleClamped(context, 6, 4, 12)),

        // Fixed-height area for validation messages so showing an error does
        // not resize surrounding widgets. Matches PhoneInputRow behavior.
        SizedBox(
          height: 18,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              displayError ?? '',
              style: displayError != null
                  ? AppTypography.errorSmall
                  : AppTypography.errorSmall.copyWith(
                      color: Colors.transparent,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
