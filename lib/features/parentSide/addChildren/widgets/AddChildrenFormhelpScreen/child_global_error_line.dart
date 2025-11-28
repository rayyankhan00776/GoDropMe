import 'package:flutter/material.dart';
import 'package:godropme/common_widgets/form_error_line.dart';
import 'package:godropme/constants/app_strings.dart';

class ChildGlobalErrorLine extends StatelessWidget {
  final bool visible;
  const ChildGlobalErrorLine({super.key, required this.visible});

  @override
  Widget build(BuildContext context) {
    return FormErrorLine(
      message: AppStrings.childFormGlobalError,
      visible: visible,
    );
  }
}
