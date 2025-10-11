import 'package:flutter/material.dart';
import 'package:godropme/common%20widgets/custom_text_field.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/core/theme/colors.dart';
import 'package:godropme/utils/app_strings.dart';

/// Form widget for Personal Info screen. First name is optional; last name is required.
class PersonalinfoForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController surNameController;
  final TextEditingController lastNameController;
  final bool showSubmittedErrors;
  final bool showGlobalError;

  const PersonalinfoForm({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.surNameController,
    required this.lastNameController,
    required this.showSubmittedErrors,
    this.showGlobalError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: firstNameController,
            hintText: AppStrings.firstNameHint,
            borderColor: AppColors.gray,
            validator: (v) => v == null || v.trim().isEmpty
                ? AppStrings.firstNameRequired
                : null,
          ),

          SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),

          // Optional SurName field (no validation)
          CustomTextField(
            controller: surNameController,
            hintText: AppStrings.surNameHint,
            borderColor: AppColors.gray,
            validator: (_) => null,
          ),

          SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),

          CustomTextField(
            controller: lastNameController,
            hintText: AppStrings.lastNameHint,
            borderColor: AppColors.gray,
            // last name is optional now
            validator: (_) => null,
          ),

          SizedBox(height: Responsive.scaleClamped(context, 6, 4, 12)),

          SizedBox(
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
        ],
      ),
    );
  }
}
