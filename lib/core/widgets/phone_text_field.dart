// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:godropme/core/theme/colors.dart';
import 'package:godropme/core/utils/app_typography.dart';
import 'package:godropme/core/utils/responsive.dart';

typedef PhoneValidator = String? Function(String? value);

// Default validator that accepts Pakistani mobile numbers in common formats:
// - +923XXXXXXXXX (international)
// - 03XXXXXXXXX (with leading 0)
// - 3XXXXXXXXX (local without leading 0)
String? pakistanPhoneValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Please enter phone number';
  final cleaned = value.trim();
  // Allow inputs like: +923XXXXXXXXX, 03XXXXXXXXX, 3XXXXXXXXX, or just digits where user typed national part
  final onlyDigits = cleaned.replaceAll(RegExp(r'[^0-9]'), '');

  // Normalize to national form: ensure it starts with 3 and has 10 digits total (3XXXXXXXXX)
  String national = onlyDigits;
  if (national.startsWith('92')) national = national.substring(2);
  if (national.startsWith('0')) national = national.substring(1);

  if (national.isEmpty) return 'Please enter phone number';
  if (!national.startsWith('3')) return 'Please add a valid Phone Number';
  if (national.length != 10) return 'Enter a valid Pakistani mobile number';
  return null;
}

class PhoneTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final Widget? prefix;
  final List<TextInputFormatter>? inputFormatters;
  final PhoneValidator? validator;
  final double height;
  final bool showContainer;
  final Color? hintColor;
  final Color? textColor;

  const PhoneTextField({
    this.controller,
    this.hintText,
    this.prefix,
    this.inputFormatters,
    this.validator,
    this.height = 56,
    this.showContainer = true,
    this.hintColor,
    this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final input = TextFormField(
      controller: controller,
      inputFormatters: inputFormatters,
      keyboardType: TextInputType.phone,
      style: AppTypography.optionLineSecondary.copyWith(
        color: textColor ?? AppColors.white,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        // allow overriding hint color; default to a lighter black and slightly larger size
        hintStyle: AppTypography.optionTerms.copyWith(
          color: hintColor ?? AppColors.black.withOpacity(0.5),
          fontSize: (AppTypography.optionTerms.fontSize ?? 12) + 1,
        ),
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        // When this widget is embedded in a custom container (showContainer == false)
        // we want to suppress the TextFormField's default error text so it doesn't
        // add extra vertical space. The calling parent (PhoneInputRow) manages
        // a fixed error area instead.
        errorStyle: showContainer
            ? null
            : const TextStyle(height: 0, fontSize: 0),
      ),
      validator: validator ?? pakistanPhoneValidator,
    );

    if (!showContainer) return input;

    return Container(
      height: Responsive.scaleClamped(context, height, 40, 80),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.scaleClamped(context, 8, 6, 14),
      ),
      child: Row(
        children: [
          if (prefix != null) ...[
            prefix!,
            SizedBox(width: Responsive.scaleClamped(context, 8, 6, 14)),
          ],
          Expanded(child: input),
        ],
      ),
    );
  }
}
