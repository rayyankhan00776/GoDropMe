import 'package:flutter/material.dart';
import 'package:godropme/core/widgets/custom_text_field.dart';
import 'package:godropme/core/theme/colors.dart';
import 'package:godropme/core/utils/responsive.dart';

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
            CustomTextField(
              controller: licenceNumberController,
              hintText: 'Licence Number',
              borderColor: AppColors.gray,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Please enter licence number'
                  : null,
            ),

            SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),

            CustomTextField(
              controller: expiryDateController,
              hintText: 'Expiry Date',
              borderColor: AppColors.gray,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Please enter expiry date'
                  : null,
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
