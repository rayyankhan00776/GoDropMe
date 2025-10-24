// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:godropme/common%20widgets/custom_text_field.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/features/parentSide/addChildren/models/children_form_options.dart';
import 'package:godropme/features/parentSide/addChildren/utils/children_form_options_loader.dart';
import 'package:godropme/common%20widgets/app_dropdown.dart';
import 'package:godropme/common%20widgets/form_error_line.dart';
import 'package:godropme/features/parentSide/addChildren/widgets/AddChildrenFormhelpScreen/time_picker_field.dart';
import 'package:godropme/theme/colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godropme/shared/bottom_sheets/location_picker_bottom_sheet.dart';
import 'package:godropme/shared/widgets/section_header.dart';
import 'package:godropme/utils/app_typography.dart';

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
  LatLng? _pickLatLng;
  LatLng? _dropLatLng;
  bool _sameAsPick = false;
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
      'pick_lat': _pickLatLng?.latitude,
      'pick_lng': _pickLatLng?.longitude,
      'drop_lat': _dropLatLng?.latitude,
      'drop_lng': _dropLatLng?.longitude,
      'relationship': rel,
      'pickup_time': _pickupTime?.format(context) ?? '',
    };

    // Delegate persistence and navigation to parent screen
    widget.onSave?.call(data);
  }

  /// Public helper so parents can trigger the save from outside via a GlobalKey.
  void submitForm() => _save();

  Future<void> _selectPickLocation() async {
    final result = await showLocationPickerBottomSheet(
      context,
      initial: _pickLatLng,
    );
    if (result != null) {
      setState(() {
        _pickLatLng = result;
        _pickPointController.text =
            '${result.latitude.toStringAsFixed(6)}, ${result.longitude.toStringAsFixed(6)}';
        if (_sameAsPick) {
          _dropLatLng = result;
          _dropPointController.text = _pickPointController.text;
        }
      });
    }
  }

  Future<void> _selectDropLocation() async {
    if (_sameAsPick) return; // disabled when same-as-pick is on
    final result = await showLocationPickerBottomSheet(
      context,
      initial: _dropLatLng ?? _pickLatLng,
    );
    if (result != null) {
      setState(() {
        _dropLatLng = result;
        _dropPointController.text =
            '${result.latitude.toStringAsFixed(6)}, ${result.longitude.toStringAsFixed(6)}';
      });
    }
  }

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
          AppDropdown(
            hint: AppStrings.childAgeHint,
            value: _selectedAge,
            items: _options.ages,
            onSelect: (sel) => setState(() => _selectedAge = sel),
          ),
          SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),

          // Gender
          AppDropdown(
            hint: AppStrings.childGenderHint,
            value: _selectedGender,
            items: _options.genders,
            onSelect: (sel) => setState(() => _selectedGender = sel),
          ),
          SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),

          // School
          AppDropdown(
            hint: AppStrings.childSchoolHint,
            value: _selectedSchool,
            items: _options.schools,
            onSelect: (sel) => setState(() => _selectedSchool = sel),
          ),
          SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),

          // Pick point (map picker)
          GestureDetector(
            onTap: _selectPickLocation,
            child: AbsorbPointer(
              child: CustomTextField(
                borderColor: AppColors.gray,
                controller: _pickPointController,
                hintText: AppStrings.childPickPointHint,
              ),
            ),
          ),
          SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),

          // Drop point header with Same as pick toggle (centralized SectionHeader)
          SectionHeader(
            title: AppStrings.childDropPointHint,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppStrings.sameAsPick, style: AppTypography.helperSmall),
                const SizedBox(width: 8),
                Switch(
                  value: _sameAsPick,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _sameAsPick = val;
                      if (_sameAsPick) {
                        _dropLatLng = _pickLatLng;
                        _dropPointController.text = _pickPointController.text;
                      } else {
                        _dropLatLng = null;
                        _dropPointController.clear();
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _selectDropLocation,
            child: AbsorbPointer(
              child: CustomTextField(
                borderColor: _sameAsPick ? AppColors.grayLight : AppColors.gray,
                controller: _dropPointController,
                hintText: AppStrings.tapToSelectOnMap,
              ),
            ),
          ),
          SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),

          // Relationship
          AppDropdown(
            hint: AppStrings.childRelationshipHint,
            value: _selectedRelation,
            items: _options.relations,
            onSelect: (sel) => setState(() => _selectedRelation = sel),
          ),

          SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),
          // Time picker row
          TimePickerField(time: _pickupTime, onPick: _pickTime),
          SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),
          // Global validation message area (fixed height)
          FormErrorLine(
            message: AppStrings.childFormGlobalError,
            visible: _globalError != null,
          ),

          SizedBox(height: Responsive.scaleClamped(context, 18, 12, 24)),
          SizedBox(height: Responsive.scaleClamped(context, 24, 16, 32)),
        ],
      ),
    );
  }

  // All UI primitives moved into reusable widgets
}
