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
import 'child_photo_picker.dart';

typedef OnSaveChild = void Function(Map<String, dynamic> childData);

class AddChildForm extends StatefulWidget {
  final OnSaveChild? onSave;
  final Map<String, dynamic>? initialData;

  const AddChildForm({this.onSave, this.initialData, super.key});

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
  TimeOfDay? _schoolOpenTime;
  TimeOfDay? _schoolOffTime;
  // Single global error message shown when any required field is missing
  String? _globalError;

  // Dropdown selections
  String? _selectedAge;
  String? _selectedGender;
  String? _selectedSchool;
  String? _selectedRelation;
  
  // Child photo path (optional)
  String? _childPhotoPath;

  // Options loaded from asset (via loader)
  ChildrenFormOptions _options = ChildrenFormOptions.empty;

  @override
  void initState() {
    super.initState();
    _loadOptions();
    _populateFromInitialData();
  }

  void _populateFromInitialData() {
    final data = widget.initialData;
    if (data == null) return;
    
    // Populate text fields
    _nameController.text = data['name']?.toString() ?? '';
    _pickPointController.text = data['pickPoint']?.toString() ?? '';
    _dropPointController.text = data['dropPoint']?.toString() ?? '';
    
    // Populate dropdowns
    final age = data['age'];
    if (age != null) {
      _selectedAge = '$age years';
    }
    _selectedGender = data['gender']?.toString();
    
    // For school, try to get from _schoolName (pre-populated by controller)
    // or resolve from schoolId once options are loaded
    _selectedSchool = data['_schoolName']?.toString();
    
    _selectedRelation = data['relationshipToChild']?.toString();
    
    // Populate locations
    final pickLoc = data['pickLocation'];
    if (pickLoc is List && pickLoc.length >= 2) {
      _pickLatLng = LatLng(pickLoc[1].toDouble(), pickLoc[0].toDouble()); // [lng, lat] -> LatLng(lat, lng)
    }
    final dropLoc = data['dropLocation'];
    if (dropLoc is List && dropLoc.length >= 2) {
      _dropLatLng = LatLng(dropLoc[1].toDouble(), dropLoc[0].toDouble());
    }
    
    // Check if same as pick
    _sameAsPick = _pickPointController.text == _dropPointController.text && 
                  _pickPointController.text.isNotEmpty;
    
    // Populate times
    final openTime = data['schoolOpenTime']?.toString();
    if (openTime != null && openTime.isNotEmpty) {
      _schoolOpenTime = _parseTimeOfDay(openTime);
    }
    final offTime = data['schoolOffTime']?.toString();
    if (offTime != null && offTime.isNotEmpty) {
      _schoolOffTime = _parseTimeOfDay(offTime);
    }
    
    // Populate photo
    _childPhotoPath = data['photoPath']?.toString();
    // Also check for photoUrl for Appwrite stored images
    if (_childPhotoPath == null || _childPhotoPath!.isEmpty) {
      _childPhotoPath = data['photoUrl']?.toString();
    }
  }
  
  /// Parse time string like "7:30 AM" to TimeOfDay
  TimeOfDay? _parseTimeOfDay(String timeStr) {
    try {
      final parts = timeStr.split(' ');
      if (parts.length != 2) return null;
      
      final timeParts = parts[0].split(':');
      if (timeParts.length != 2) return null;
      
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final isPM = parts[1].toUpperCase() == 'PM';
      
      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadOptions() async {
    final loaded = await ChildrenFormOptionsLoader.load();
    if (!mounted) return;
    setState(() {
      _options = loaded;
      // If school wasn't pre-populated, resolve it now from schoolId
      if ((_selectedSchool == null || _selectedSchool!.isEmpty) && widget.initialData != null) {
        final schoolId = widget.initialData!['schoolId']?.toString();
        if (schoolId != null && schoolId.isNotEmpty) {
          final school = _options.getSchoolById(schoolId);
          if (school != null) {
            _selectedSchool = school.name;
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pickPointController.dispose();
    _dropPointController.dispose();
    super.dispose();
  }

  Future<void> _pickOpenTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _schoolOpenTime ?? const TimeOfDay(hour: 7, minute: 30),
    );
    if (t != null) setState(() => _schoolOpenTime = t);
  }

  Future<void> _pickOffTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _schoolOffTime ?? const TimeOfDay(hour: 13, minute: 30),
    );
    if (t != null) setState(() => _schoolOffTime = t);
  }

  /// Parse age from dropdown string (e.g., "5 years") to integer
  int _parseAge(String ageStr) {
    final digits = ageStr.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  void _save() {
    // reset global error
    _globalError = null;

    final name = _nameController.text.trim();
    final age = _selectedAge?.trim() ?? '';
    final gender = _selectedGender?.trim() ?? '';
    final schoolName = _selectedSchool?.trim() ?? '';
    final pick = _pickPointController.text.trim();
    final drop = _dropPointController.text.trim();
    final rel = _selectedRelation?.trim() ?? '';

    // If any required field is empty, show a single global message
    final requiredMissing = [
      name,
      age,
      gender,
      schoolName,
      pick,
      drop,
      rel,
    ].any((s) => s.isEmpty);
    if (requiredMissing) {
      _globalError = AppStrings.childFormGlobalError;
      setState(() {});
      return;
    }

    // Get the school object to extract ID (primary key for database)
    final schoolObj = _options.getSchoolByName(schoolName);
    final schoolId = schoolObj?.id ?? '';
    
    // Validate school was found
    if (schoolId.isEmpty) {
      _globalError = 'Please select a valid school';
      setState(() {});
      return;
    }

    final data = {
      'name': name,
      'age': _parseAge(age), // Store as integer
      'gender': gender,
      'schoolId': schoolId, // Foreign key to schools table
      'pickPoint': pick,
      'dropPoint': drop,
      // Store as [lng, lat] for Appwrite point type
      'pickLocation': _pickLatLng != null 
          ? [_pickLatLng!.longitude, _pickLatLng!.latitude] 
          : null,
      'dropLocation': _dropLatLng != null 
          ? [_dropLatLng!.longitude, _dropLatLng!.latitude] 
          : null,
      'relationshipToChild': rel,
      'schoolOpenTime': _schoolOpenTime?.format(context) ?? '',
      'schoolOffTime': _schoolOffTime?.format(context) ?? '',
      'photoPath': _childPhotoPath, // Local file path for child photo
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
          // Child photo picker (optional)
          ChildPhotoPicker(
            imagePath: _childPhotoPath,
            onImageSelected: (path) => setState(() => _childPhotoPath = path),
          ),
          SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),
          
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
          TimePickerField(
            label: AppStrings.childSchoolOpenTime,
            time: _schoolOpenTime,
            onPick: _pickOpenTime,
          ),
          SizedBox(height: Responsive.scaleClamped(context, 8, 6, 12)),
          TimePickerField(
            label: AppStrings.childSchoolOffTime,
            time: _schoolOffTime,
            onPick: _pickOffTime,
          ),
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
