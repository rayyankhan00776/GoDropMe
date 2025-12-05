import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:godropme/common_widgets/custom_phone_text_field.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/validators.dart';
import 'package:godropme/utils/validators_extra.dart';

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
                validator: Validators.cnic,
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
                  ExtraInputFormatters.dateDmy,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: Validators.dateDMYFuture,
              ),
            ),
            SizedBox(height: Responsive.scaleClamped(context, 6, 4, 12)),

            SizedBox(
              height: 18,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  showGlobalError ? AppStrings.formGlobalError : '',
                  style: showGlobalError
                      ? AppTypography.errorSmall
                      : AppTypography.errorSmall.copyWith(
                          color: Colors.transparent,
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
