import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:godropme/common_widgets/custom_text_field.dart';
import 'package:godropme/common_widgets/app_dropdown.dart';
import 'package:godropme/common_widgets/form_error_line.dart';
import 'package:godropme/theme/colors.dart';

abstract class FormItem {
  const FormItem();
  Widget build(BuildContext context);
}

class GapItem extends FormItem {
  final double height;
  const GapItem(this.height);
  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}

class LabelItem extends FormItem {
  final Widget child;
  const LabelItem({required this.child});
  @override
  Widget build(BuildContext context) => child;
}

class TextFieldItem extends FormItem {
  final TextEditingController controller;
  final String hintText;
  final Color borderColor;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  const TextFieldItem({
    required this.controller,
    required this.hintText,
    this.borderColor = AppColors.gray,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });
  @override
  Widget build(BuildContext context) => CustomTextField(
    controller: controller,
    hintText: hintText,
    borderColor: borderColor,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    validator: validator,
  );
}

class DropdownItem extends FormItem {
  final String hint;
  final String? value;
  final List<String> items;
  final bool enabled;
  final void Function(String value) onSelect;
  const DropdownItem({
    required this.hint,
    required this.value,
    required this.items,
    required this.onSelect,
    this.enabled = true,
  });
  @override
  Widget build(BuildContext context) => AppDropdown(
    hint: hint,
    value: value,
    items: items,
    enabled: enabled,
    onSelect: onSelect,
  );
}

class ErrorLineItem extends FormItem {
  final String message;
  final bool visible;
  const ErrorLineItem({required this.message, required this.visible});
  @override
  Widget build(BuildContext context) =>
      FormErrorLine(message: message, visible: visible);
}
