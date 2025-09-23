// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:godropme/core/theme/colors.dart';
import 'package:godropme/core/widgets/phone_text_field.dart';
import 'package:godropme/core/regix/pakistan_number_formatter.dart';
import 'package:godropme/core/utlis/app_assets.dart';

class PhoneInputRow extends StatelessWidget {
  final TextEditingController controller;
  final String selectedCode;
  final ValueChanged<String>? onCodeChanged;
  final double height;
  final PhoneValidator? validator;

  const PhoneInputRow({
    required this.controller,
    required this.selectedCode,
    this.onCodeChanged,
    this.height = 56,
    this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const SizedBox(width: 15),
          // country code removed (we show +92 inside the text field)
          Expanded(
            child: PhoneTextField(
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
    );
  }
}
