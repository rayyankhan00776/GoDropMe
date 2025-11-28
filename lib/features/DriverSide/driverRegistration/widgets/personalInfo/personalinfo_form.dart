import 'package:flutter/material.dart';
// CustomTextField is used via TextFieldItem in DynamicFormBuilder
import 'package:godropme/common_widgets/forms/dynamic_form_builder.dart';
import 'package:godropme/common_widgets/forms/form_items.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/common_widgets/custom_phone_text_field.dart';
import 'package:flutter/services.dart';
import 'package:godropme/regix/pakistan_number_formatter.dart';

/// Form widget for Personal Info screen. First name is optional; last name is required.
class PersonalinfoForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController surNameController;
  final TextEditingController lastNameController;
  final TextEditingController phoneController;
  final bool showSubmittedErrors;
  final bool showGlobalError;

  const PersonalinfoForm({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.surNameController,
    required this.lastNameController,
    required this.phoneController,
    required this.showSubmittedErrors,
    this.showGlobalError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: DynamicFormBuilder(
        padding: EdgeInsets.zero,
        items: [
          // First name field (required)
          TextFieldItem(
            controller: firstNameController,
            hintText: AppStrings.firstNameHint,
            borderColor: AppColors.gray,
            validator: (v) => v == null || v.trim().isEmpty
                ? AppStrings.firstNameRequired
                : null,
          ),
          GapItem(Responsive.scaleClamped(context, 12, 8, 18)),
          // Optional SurName field
          TextFieldItem(
            controller: surNameController,
            hintText: AppStrings.surNameHint,
            borderColor: AppColors.gray,
            validator: (_) => null,
          ),
          GapItem(Responsive.scaleClamped(context, 12, 8, 18)),
          // Last name optional
          TextFieldItem(
            controller: lastNameController,
            hintText: AppStrings.lastNameHint,
            borderColor: AppColors.gray,
            validator: (_) => null,
          ),
          GapItem(Responsive.scaleClamped(context, 12, 8, 18)),
          // Phone number (Pakistani format) beneath name fields
          LabelItem(
            child: SizedBox(
              width: double.infinity,
              child: CustonPhoneTextField(
                controller: phoneController,
                hintText: '',
                borderColor: AppColors.gray,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  PakistanPhoneNumberFormatter(),
                ],
                validator: pakistanPhoneValidator,
                prefix: const Text('+92'),
              ),
            ),
          ),
          GapItem(Responsive.scaleClamped(context, 6, 4, 12)),
          // Fixed-height error line for phone field (to avoid layout jump)
          LabelItem(
            child: SizedBox(
              height: 18,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  showSubmittedErrors
                      ? (pakistanPhoneValidator(phoneController.text) ?? '')
                      : '',
                  style: TextStyle(
                    color:
                        showSubmittedErrors &&
                            pakistanPhoneValidator(phoneController.text) != null
                        ? AppColors.accent
                        : Colors.transparent,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          GapItem(Responsive.scaleClamped(context, 6, 4, 12)),
          LabelItem(
            child: SizedBox(
              height: 18,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  showGlobalError
                      ? 'Please complete all fields and add image'
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
          ),
        ],
      ),
    );
  }
}
