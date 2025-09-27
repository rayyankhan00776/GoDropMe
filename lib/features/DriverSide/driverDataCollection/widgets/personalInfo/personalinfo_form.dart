import 'package:flutter/material.dart';
import 'package:godropme/core/widgets/custom_text_field.dart';
import 'package:godropme/core/utils/responsive.dart';
import 'package:godropme/core/theme/colors.dart';

/// Form widget for Personal Info screen. First name is optional; last name is required.
class PersonalinfoForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final bool showSubmittedErrors;

  const PersonalinfoForm({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.showSubmittedErrors,
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
            hintText: 'First name',
            borderColor: AppColors.gray,
            validator: (_) => null,
          ),

          SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),

          CustomTextField(
            controller: lastNameController,
            hintText: 'Last name',
            borderColor: AppColors.gray,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Please enter last name' : null,
          ),

          SizedBox(height: Responsive.scaleClamped(context, 6, 4, 12)),

          SizedBox(
            height: 18,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                showSubmittedErrors &&
                        (lastNameController.text.isEmpty ||
                            lastNameController.text.trim().isEmpty)
                    ? 'Please enter last name'
                    : '',
                style: TextStyle(
                  color:
                      showSubmittedErrors &&
                          (lastNameController.text.isEmpty ||
                              lastNameController.text.trim().isEmpty)
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
