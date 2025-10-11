// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:godropme/core/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:flutter/services.dart';

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
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    this.controller,
    this.hintText,
    this.validator,
    this.height = 56,
    this.showContainer = true,
    this.borderColor = AppColors.primary,
    this.hintColor,
    this.keyboardType,
    this.inputFormatters,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final input = TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      inputFormatters: inputFormatters,
      style: AppTypography.optionLineSecondary.copyWith(color: AppColors.black),
      // Keep caret size stable to avoid visual jumps
      cursorHeight: (AppTypography.optionLineSecondary.fontSize ?? 16) * 1.2,
      cursorWidth: 2,
      // Keep the text vertically centered inside the fixed-height container
      // so validation state changes won't adjust the container size.
      textAlignVertical: TextAlignVertical.center,
      // Keep single-line height and caret stable
      minLines: 1,
      expands: false,
      maxLines: 1,
      strutStyle: StrutStyle.fromTextStyle(
        AppTypography.optionLineSecondary,
        forceStrutHeight: true,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.optionTerms.copyWith(
          color: hintColor ?? AppColors.darkGray,
        ),
        border: InputBorder.none,
        isDense: true,
        // Provide symmetric vertical padding so the caret and text remain
        // vertically centered and do not jump on validation.
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
      // Keep the field expanded horizontally and vertically centered
      child: Row(children: [Expanded(child: input)]),
    );
  }
}
