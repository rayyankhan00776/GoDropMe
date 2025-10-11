// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/common%20widgets/custom_phone_text_field.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/regix/pakistan_number_formatter.dart';
import 'package:godropme/utils/app_assets.dart';

class PhoneInputRow extends StatelessWidget {
  final TextEditingController controller;
  final String selectedCode;
  final ValueChanged<String>? onCodeChanged;
  final double height;
  final PhoneValidator? validator;
  final bool showError;

  const PhoneInputRow({
    required this.controller,
    required this.selectedCode,
    this.onCodeChanged,
    this.height = 56,
    this.validator,
    this.showError = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Compute current validation message without calling FormState so we can
    // render a fixed-size error area below the input and avoid layout jumps.
    final String? errorText = validator?.call(controller.text);
    final String? displayError = showError ? errorText : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Row(
            children: [
              Image.asset(
                AppAssets.flag,
                width: height * 0.6,
                height: height * 0.6,
              ),
              SizedBox(width: Responsive.scaleClamped(context, 15, 8, 28)),
              // country code removed (we show +92 inside the text field)
              Expanded(
                child: CustonPhoneTextField(
                  controller: controller,
                  hintText: 'e.g. 3001234567',
                  hintColor: AppColors.black.withOpacity(0.6),
                  textColor: AppColors.black,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    PakistanPhoneNumberFormatter(),
                  ],
                  validator: validator,
                  height: height,
                  showContainer: false,
                ),
              ),
              IconButton(
                onPressed: () => controller.clear(),
                icon: const Icon(Icons.clear, color: AppColors.black),
              ),
            ],
          ),
        ),

        // Fixed-height area for validation messages so showing an error does
        // not resize surrounding widgets. We intentionally keep the height
        // small and consistent with typical form error text.
        SizedBox(height: Responsive.scaleClamped(context, 6, 4, 12)),
        SizedBox(
          height: 18,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              displayError ?? '',
              style: AppTypography.optionLineSecondary.copyWith(
                color: displayError != null
                    ? AppColors.accent
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
