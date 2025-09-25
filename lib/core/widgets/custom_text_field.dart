// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:godropme/core/theme/colors.dart';
import 'package:godropme/core/utils/app_typography.dart';

typedef TextValidator = String? Function(String? value);

String? nonEmptyValidator(String? v) {
  if (v == null || v.trim().isEmpty) return 'This field cannot be empty';
  return null;
}

/// A small, reusable text field that mirrors the visual style of
/// `PhoneTextField` but for general text input.
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final TextValidator? validator;
  final double height;
  final bool showContainer;
  final Color borderColor;
  final Color? hintColor;

  const CustomTextField({
    this.controller,
    this.hintText,
    this.validator,
    this.height = 64,
    this.showContainer = true,
    this.borderColor = AppColors.primary,
    this.hintColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final input = TextFormField(
      controller: controller,
      keyboardType: TextInputType.text,
      style: AppTypography.optionLineSecondary.copyWith(color: AppColors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.optionTerms.copyWith(
          color: hintColor ?? AppColors.darkGray,
        ),
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
      validator: validator ?? nonEmptyValidator,
    );

    if (!showContainer) return input;

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(children: [Expanded(child: input)]),
    );
  }
}
