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
/// `CustonPhoneTextField` but for general text input.
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
    this.height = 56,
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
      // Keep the text vertically centered inside the fixed-height container
      // so validation state changes won't adjust the container size.
      textAlignVertical: TextAlignVertical.center,
      expands: false,
      maxLines: 1,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.optionTerms.copyWith(
          color: hintColor ?? AppColors.darkGray,
        ),
        border: InputBorder.none,
        isDense: true,
        // Remove inner content padding so the surrounding Container fully
        // controls sizing. Also hide any inline error text by making it
        // transparent and collapsed so it doesn't reserve vertical space
        // (validation messages are shown externally in a fixed area).
        isCollapsed: true,
        contentPadding: EdgeInsets.zero,
        errorStyle: const TextStyle(
          height: 0,
          color: Colors.transparent,
          fontSize: 0,
        ),
        errorMaxLines: 1,
      ),
      validator: validator ?? nonEmptyValidator,
      // Prevent the TextFormField from showing its own inline error text —
      // we render validation messages in an external fixed box instead.
      autovalidateMode: AutovalidateMode.disabled,
    );

    if (!showContainer) return input;

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      child: Row(children: [Expanded(child: input)]),
    );
  }
}
