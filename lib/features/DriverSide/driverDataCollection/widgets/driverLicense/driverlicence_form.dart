import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:godropme/core/utils/app_strings.dart';
import 'package:godropme/core/widgets/custom_phone_text_field.dart';
import 'package:godropme/core/theme/colors.dart';
import 'package:godropme/core/utils/responsive.dart';

/// Formats input as DD-MM-YYYY while the user types.
/// It keeps only digits and inserts '-' after 2 and 4 digits.
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Keep only digits from the new input
    final onlyDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Limit to 8 digits: DDMMYYYY
    final limited = onlyDigits.length > 8
        ? onlyDigits.substring(0, 8)
        : onlyDigits;

    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      buffer.write(limited[i]);
      if (i == 1 || i == 3) buffer.write('-');
    }

    final formatted = buffer.toString();

    // Place cursor at the end of the formatted text
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class DriverLicenceForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController licenceNumberController;
  final TextEditingController expiryDateController;
  final bool showSubmittedErrors;

  const DriverLicenceForm({
    super.key,
    required this.formKey,
    required this.licenceNumberController,
    required this.expiryDateController,
    required this.showSubmittedErrors,
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
            CustonPhoneTextField(
              controller: licenceNumberController,
              hintText: AppStrings.driverLicenceNumberHint,
              borderColor: AppColors.gray,
              // allow only digits and limit to 5 characters
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(5),
              ],
              // simple validator: ensure exactly 5 numeric digits (no regex)
              validator: (v) {
                final val = v?.trim() ?? '';
                if (val.length != 5) return 'Licence number must be 5 digits';
                if (int.tryParse(val) == null) {
                  return 'Licence number must be numeric';
                }
                return null;
              },
            ),

            SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),

            // expiry date in DD-MM-YYYY format
            CustonPhoneTextField(
              controller: expiryDateController,
              hintText: AppStrings.driverLicenceExpiryHint,
              borderColor: AppColors.gray,
              // format as DD-MM-YYYY while typing and limit to 10 chars
              inputFormatters: [
                DateInputFormatter(),
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (v) {
                final val = v?.trim() ?? '';
                if (val.isEmpty) return 'Please enter expiry date';
                // Expect exactly 10 characters: DD-MM-YYYY
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

            SizedBox(height: Responsive.scaleClamped(context, 6, 4, 12)),

            SizedBox(
              height: 18,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  showSubmittedErrors
                      ? 'Please complete all fields and add images'
                      : '',
                  style: TextStyle(
                    color: showSubmittedErrors
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
