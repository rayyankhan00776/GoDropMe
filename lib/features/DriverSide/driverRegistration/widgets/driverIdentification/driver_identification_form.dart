import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:godropme/common%20widgets/custom_phone_text_field.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/theme/colors.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final onlyDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limited = onlyDigits.length > 8
        ? onlyDigits.substring(0, 8)
        : onlyDigits;
    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      buffer.write(limited[i]);
      if (i == 1 || i == 3) buffer.write('-');
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formats CNIC as XXXXX-XXXXXXX-X while typing. Accepts up to 13 digits and
/// inserts hyphens after 5 and 12 digits (digit positions: 5 and 12).
class CnicInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final onlyDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limited = onlyDigits.length > 13
        ? onlyDigits.substring(0, 13)
        : onlyDigits;
    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      buffer.write(limited[i]);
      // after 5th digit (index 4) and after 12th digit (index 11) insert '-'
      if (i == 4 || i == 11) {
        if (i != limited.length - 1) buffer.write('-');
      }
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class DriverIdentificationForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController cnicController;
  final TextEditingController expiryController;
  final bool showSubmittedErrors;
  final bool showGlobalError;

  const DriverIdentificationForm({
    super.key,
    required this.formKey,
    required this.cnicController,
    required this.expiryController,
    this.showSubmittedErrors = false,
    this.showGlobalError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CNIC (13 digits) formatted as XXXXX-XXXXXXX-X
            SizedBox(
              width: double.infinity,
              child: CustonPhoneTextField(
                controller: cnicController,
                hintText: AppStrings.cnicFrontHint,
                borderColor: AppColors.gray,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  // limit raw digits to 13 before formatting
                  LengthLimitingTextInputFormatter(13),
                  CnicInputFormatter(),
                ],
                validator: (v) {
                  final digitsOnly = (v ?? '').replaceAll(
                    RegExp(r'[^0-9]'),
                    '',
                  );
                  if (digitsOnly.length != 13) return 'CNIC must be 13 digits';
                  if (int.tryParse(digitsOnly) == null) {
                    return 'CNIC must be numeric';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),

            // Expiry date
            SizedBox(
              width: double.infinity,
              child: CustonPhoneTextField(
                controller: expiryController,
                hintText: AppStrings.driverLicenceExpiryHint,
                borderColor: AppColors.gray,
                inputFormatters: [
                  DateInputFormatter(),
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (v) {
                  final val = v?.trim() ?? '';
                  if (val.isEmpty) return 'Please enter expiry date';
                  if (val.length != 10) return 'Enter date as DD-MM-YYYY';
                  final parts = val.split('-');
                  if (parts.length != 3) return 'Enter date as DD-MM-YYYY';
                  final day = int.tryParse(parts[0]);
                  final month = int.tryParse(parts[1]);
                  final year = int.tryParse(parts[2]);
                  if (day == null || month == null || year == null) {
                    return 'Enter date as DD-MM-YYYY';
                  }
                  if (parts[0].length != 2 ||
                      parts[1].length != 2 ||
                      parts[2].length != 4) {
                    return 'Enter date as DD-MM-YYYY';
                  }
                  if (month < 1 || month > 12) return 'Enter valid month';
                  if (day < 1 || day > 31) return 'Enter valid day';
                  return null;
                },
              ),
            ),
            SizedBox(height: Responsive.scaleClamped(context, 6, 4, 12)),

            SizedBox(
              height: 18,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  showGlobalError
                      ? 'Please complete all fields and add images'
                      : '',
                  style: TextStyle(
                    color: showGlobalError
                        ? const Color(0xFFFF6B6B)
                        : Colors.transparent,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
