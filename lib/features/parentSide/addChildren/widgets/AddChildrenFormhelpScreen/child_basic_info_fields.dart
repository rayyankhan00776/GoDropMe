import 'package:flutter/material.dart';
import 'package:godropme/common%20widgets/custom_text_field.dart';
import 'package:godropme/common%20widgets/app_dropdown.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/features/parentSide/addChildren/models/children_form_options.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/responsive.dart';

class ChildBasicInfoFields extends StatelessWidget {
  final TextEditingController nameController;
  final String? selectedAge;
  final String? selectedGender;
  final String? selectedSchool;
  final ChildrenFormOptions options;
  final ValueChanged<String?> onAgeChanged;
  final ValueChanged<String?> onGenderChanged;
  final ValueChanged<String?> onSchoolChanged;

  const ChildBasicInfoFields({
    super.key,
    required this.nameController,
    required this.selectedAge,
    required this.selectedGender,
    required this.selectedSchool,
    required this.options,
    required this.onAgeChanged,
    required this.onGenderChanged,
    required this.onSchoolChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          borderColor: AppColors.gray,
          controller: nameController,
          hintText: AppStrings.childNameHint,
        ),
        SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),
        AppDropdown(
          hint: AppStrings.childAgeHint,
          value: selectedAge,
          items: options.ages,
          onSelect: onAgeChanged,
        ),
        SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),
        AppDropdown(
          hint: AppStrings.childGenderHint,
          value: selectedGender,
          items: options.genders,
          onSelect: onGenderChanged,
        ),
        SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),
        AppDropdown(
          hint: AppStrings.childSchoolHint,
          value: selectedSchool,
          items: options.schools,
          onSelect: onSchoolChanged,
        ),
      ],
    );
  }
}
