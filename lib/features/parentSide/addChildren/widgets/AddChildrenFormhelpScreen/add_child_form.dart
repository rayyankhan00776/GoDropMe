// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:godropme/common%20widgets/custom_text_field.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/features/parentSide/addChildren/models/children_form_options.dart';
import 'package:godropme/features/parentSide/addChildren/utils/children_form_options_loader.dart';
import 'package:godropme/features/parentSide/addChildren/widgets/AddChildrenFormhelpScreen/dropdown_field.dart';
import 'package:godropme/features/parentSide/addChildren/widgets/AddChildrenFormhelpScreen/selection_bottom_sheet.dart';
import 'package:godropme/features/parentSide/addChildren/widgets/AddChildrenFormhelpScreen/time_picker_field.dart';
import 'package:godropme/theme/colors.dart';

typedef OnSaveChild = void Function(Map<String, dynamic> childData);

class AddChildForm extends StatefulWidget {
  final OnSaveChild? onSave;

  const AddChildForm({this.onSave, super.key});

  @override
  State<AddChildForm> createState() => AddChildFormState();
}

class AddChildFormState extends State<AddChildForm> {
  // form key removed — validation is performed at save-time like driver-side pattern
  final _nameController = TextEditingController();
  // Text controllers kept only for text fields
  final _pickPointController = TextEditingController();
  final _dropPointController = TextEditingController();
  TimeOfDay? _pickupTime;
  // Single global error message shown when any required field is missing
  String? _globalError;

  // Dropdown selections
  String? _selectedAge;
  String? _selectedGender;
  String? _selectedSchool;
  String? _selectedRelation;

  // Options loaded from asset (via loader)
  ChildrenFormOptions _options = ChildrenFormOptions.fallback();

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    final loaded = await ChildrenFormOptionsLoader.load();
    if (!mounted) return;
    setState(() => _options = loaded);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pickPointController.dispose();
    _dropPointController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t != null) setState(() => _pickupTime = t);
  }

  void _save() {
    // reset global error
    _globalError = null;

    final name = _nameController.text.trim();
    final age = _selectedAge?.trim() ?? '';
    final gender = _selectedGender?.trim() ?? '';
    final school = _selectedSchool?.trim() ?? '';
    final pick = _pickPointController.text.trim();
    final drop = _dropPointController.text.trim();
    final rel = _selectedRelation?.trim() ?? '';

    // If any required field is empty, show a single global message
    final requiredMissing = [
      name,
      age,
      gender,
      school,
      pick,
      drop,
      rel,
    ].any((s) => s.isEmpty);
    if (requiredMissing) {
      _globalError = AppStrings.childFormGlobalError;
      setState(() {});
      return;
    }

    final data = {
      'name': name,
      'age': age,
      'gender': gender,
      'school': school,
      'pick_point': pick,
      'drop_point': drop,
      'relationship': rel,
      'pickup_time': _pickupTime?.format(context) ?? '',
    };

    // Delegate persistence and navigation to parent screen
    widget.onSave?.call(data);
  }

  /// Public helper so parents can trigger the save from outside via a GlobalKey.
  void submitForm() => _save();

  @override
  Widget build(BuildContext context) {
    // Always render the form; dropdown options populate when ready.
    // Use small vertical spacing and AppTypography
    return SingleChildScrollView(
      child: Column(
        children: [
          // Name
          CustomTextField(
            borderColor: AppColors.gray,
            controller: _nameController,
            hintText: AppStrings.childNameHint,
          ),
          SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),

          // Age dropdown
          DropdownField(
            hint: AppStrings.childAgeHint,
            value: _selectedAge,
            items: _options.ages,
            onChanged: (val) => setState(() => _selectedAge = val),
            onTap: () => showSelectionBottomSheet(
              context: context,
              title: AppStrings.childAgeHint,
              items: _options.ages,
              selected: _selectedAge,
              onSelect: (sel) => setState(() => _selectedAge = sel),
            ),
          ),
          SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),

          // Gender
          DropdownField(
            hint: AppStrings.childGenderHint,
            value: _selectedGender,
            items: _options.genders,
            onChanged: (val) => setState(() => _selectedGender = val),
            onTap: () => showSelectionBottomSheet(
              context: context,
              title: AppStrings.childGenderHint,
              items: _options.genders,
              selected: _selectedGender,
              onSelect: (sel) => setState(() => _selectedGender = sel),
            ),
          ),
          SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),

          // School
          DropdownField(
            hint: AppStrings.childSchoolHint,
            value: _selectedSchool,
            items: _options.schools,
            onChanged: (val) => setState(() => _selectedSchool = val),
            onTap: () => showSelectionBottomSheet(
              context: context,
              title: AppStrings.childSchoolHint,
              items: _options.schools,
              selected: _selectedSchool,
              onSelect: (sel) => setState(() => _selectedSchool = sel),
            ),
          ),
          SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),

          // Pick point
          CustomTextField(
            borderColor: AppColors.gray,
            controller: _pickPointController,
            hintText: AppStrings.childPickPointHint,
          ),
          SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),

          // Drop point
          CustomTextField(
            borderColor: AppColors.gray,
            controller: _dropPointController,
            hintText: AppStrings.childDropPointHint,
          ),
          SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),

          // Relationship
          DropdownField(
            hint: AppStrings.childRelationshipHint,
            value: _selectedRelation,
            items: _options.relations,
            onChanged: (val) => setState(() => _selectedRelation = val),
            onTap: () => showSelectionBottomSheet(
              context: context,
              title: AppStrings.childRelationshipHint,
              items: _options.relations,
              selected: _selectedRelation,
              onSelect: (sel) => setState(() => _selectedRelation = sel),
            ),
          ),

          SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),
          // Time picker row
          TimePickerField(time: _pickupTime, onPick: _pickTime),
          SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),
          // Global validation message area (fixed height)
          SizedBox(
            height: 18,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                _globalError ?? '',
                style: TextStyle(
                  color: _globalError != null
                      ? const Color(0xFFFF6B6B)
                      : Colors.transparent,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          SizedBox(height: Responsive.scaleClamped(context, 18, 12, 24)),
          SizedBox(height: Responsive.scaleClamped(context, 24, 16, 32)),
        ],
      ),
    );
  }

  // All UI primitives moved into reusable widgets
}
