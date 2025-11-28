import 'package:flutter/material.dart';
import 'package:godropme/common_widgets/app_dropdown.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/features/parentSide/addChildren/models/children_form_options.dart';
import 'package:godropme/utils/responsive.dart';

class ChildRelationshipSection extends StatelessWidget {
  final String? selectedRelation;
  final ChildrenFormOptions options;
  final ValueChanged<String?> onRelationChanged;
  const ChildRelationshipSection({
    super.key,
    required this.selectedRelation,
    required this.options,
    required this.onRelationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppDropdown(
          hint: AppStrings.childRelationshipHint,
          value: selectedRelation,
          items: options.relations,
          onSelect: onRelationChanged,
        ),
        SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),
      ],
    );
  }
}
