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
        Stack(
          alignment: Alignment.centerRight,
          children: [
            CustonPhoneTextField(
              controller: controller,
              hintText: 'e.g. 3001234567',
              hintColor: AppColors.black.withValues(alpha: 0.6),
              textColor: AppColors.black,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                PakistanPhoneNumberFormatter(),
              ],
              validator: validator,
              height: height,
              prefix: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    AppAssets.flag,
                    width: height * 0.6,
                    height: height * 0.6,
                  ),
                  SizedBox(width: Responsive.scaleClamped(context, 12, 6, 22)),
                  // Keep +92 the same size and baseline as the input text
                  const Text('+92'),
                ],
              ),
            ),
            // Clear icon overlay (maintains original vertical centering)
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final hasText = value.text.trim().isNotEmpty;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: hasText
                      ? Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: IconButton(
                            key: const ValueKey('clear-visible'),
                            onPressed: () => controller.clear(),
                            icon: const Icon(
                              Icons.clear,
                              color: AppColors.black,
                            ),
                          ),
                        )
                      : const SizedBox(
                          key: ValueKey('clear-hidden'),
                          width: 0,
                          height: 0,
                        ),
                );
              },
            ),
          ],
        ),
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
