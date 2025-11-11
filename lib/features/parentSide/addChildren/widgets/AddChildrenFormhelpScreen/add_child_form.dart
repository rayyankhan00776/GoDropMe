import 'package:flutter/material.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/features/parentSide/addChildren/models/children_form_options.dart';
import 'package:godropme/features/parentSide/addChildren/utils/children_form_options_loader.dart';
import 'package:godropme/features/parentSide/addChildren/widgets/AddChildrenFormhelpScreen/time_picker_field.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godropme/shared/bottom_sheets/location_picker_bottom_sheet.dart';
// section header and typography now used within extracted widgets
import 'child_basic_info_fields.dart';
import 'child_pickup_section.dart';
import 'child_drop_section.dart';
import 'child_relationship_section.dart';
import 'child_global_error_line.dart';

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
  LatLng? _pickLatLng; // kept for re-centering map when reopening picker
  LatLng? _dropLatLng; // kept for re-centering map when reopening picker
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
      'relationship': rel,
      'pickup_time': _pickupTime?.format(context) ?? '',
    };

    // Delegate persistence and navigation to parent screen
    widget.onSave?.call(data);
  }

  /// Public helper so parents can trigger the save from outside via a GlobalKey.
  void submitForm() => _save();

  Future<void> _selectPickLocation() async {
    final result = await showAddressLocationPickerBottomSheet(
      context,
      initial: _pickLatLng,
    );
    if (result != null) {
      setState(() {
        _pickLatLng = result.position;
        _pickPointController.text = result.address; // store/show address
        if (_sameAsPick) {
          _dropLatLng = result.position;
          _dropPointController.text = _pickPointController.text;
        }
      });
    }
  }

  Future<void> _selectDropLocation() async {
    if (_sameAsPick) return; // disabled when same-as-pick is on
    final result = await showAddressLocationPickerBottomSheet(
      context,
      initial: _dropLatLng ?? _pickLatLng,
    );
    if (result != null) {
      setState(() {
        _dropLatLng = result.position;
        _dropPointController.text = result.address; // store/show address
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
          ChildBasicInfoFields(
            nameController: _nameController,
            selectedAge: _selectedAge,
            selectedGender: _selectedGender,
            selectedSchool: _selectedSchool,
            options: _options,
            onAgeChanged: (sel) => setState(() => _selectedAge = sel),
            onGenderChanged: (sel) => setState(() => _selectedGender = sel),
            onSchoolChanged: (sel) => setState(() => _selectedSchool = sel),
          ),
          SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),

          ChildPickupSection(
            controller: _pickPointController,
            value: _pickLatLng,
            onPickLocation: _selectPickLocation,
          ),

          // Drop point header with Same as pick toggle (centralized SectionHeader)
          ChildDropSection(
            controller: _dropPointController,
            value: _dropLatLng,
            sameAsPick: _sameAsPick,
            onSameAsPickChanged: (val) {
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
            onPickDropLocation: _selectDropLocation,
          ),

          ChildRelationshipSection(
            selectedRelation: _selectedRelation,
            options: _options,
            onRelationChanged: (sel) => setState(() => _selectedRelation = sel),
          ),
          TimePickerField(time: _pickupTime, onPick: _pickTime),
          SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),
          ChildGlobalErrorLine(visible: _globalError != null),

          SizedBox(height: Responsive.scaleClamped(context, 18, 12, 24)),
          SizedBox(height: Responsive.scaleClamped(context, 24, 16, 32)),
        ],
      ),
    );
  }

  // All UI primitives moved into reusable widgets
}
