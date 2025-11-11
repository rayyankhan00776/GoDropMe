import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Removed unused UI imports after extracting form items.
// CustomTextField used via TextFieldItem in DynamicFormBuilder
import 'package:godropme/common%20widgets/forms/dynamic_form_builder.dart';
import 'package:godropme/features/driverSide/driverRegistration/utils/driver_service_options_loader.dart';
import 'package:godropme/features/driverSide/driverRegistration/models/driver_service_options.dart';
import 'package:godropme/shared/bottom_sheets/location_picker_bottom_sheet.dart';
import 'package:godropme/constants/app_strings.dart';
// Dropdown, error line replaced by DynamicFormBuilder FormItems
import 'service_form_items.dart';
// MapPickField used inside service_form_items.dart

class ServiceDetailsForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final void Function(Map<String, dynamic> values) onSubmit;

  const ServiceDetailsForm({
    super.key,
    required this.formKey,
    required this.onSubmit,
  });

  @override
  State<ServiceDetailsForm> createState() => ServiceDetailsFormState();
}

class ServiceDetailsFormState extends State<ServiceDetailsForm> {
  DriverServiceOptions? _options;
  String? _dutyType;
  String? _operatingDays;
  List<String> _selectedSchools = [];

  // coords
  LatLng? _routeStart;
  String? _routeStartAddress; // human-readable address for display/storage

  // fields
  final _notesCtrl = TextEditingController();
  bool _active = true;
  bool _showGlobalError = false;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    final opts = await DriverServiceOptionsLoader.load();
    if (!mounted) return;
    setState(() => _options = opts);
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  // Spacing handled by GapItem; legacy helper removed
  Future<void> _pickStart() async {
    final res = await showAddressLocationPickerBottomSheet(
      context,
      initial: _routeStart,
    );
    if (res != null && mounted) {
      setState(() {
        _routeStart = res.position;
        _routeStartAddress = res.address;
      });
    }
  }

  // Removed Route End selection as per requirement

  @override
  Widget build(BuildContext context) {
    final options = _options;
    if (options == null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            const SizedBox.shrink(),
            Text(AppStrings.loadingOptions),
          ],
        ),
      );
    }

    return Form(
      key: widget.formKey,
      child: DynamicFormBuilder(
        padding: EdgeInsets.zero,
        items: buildServiceFormItems(
          context: context,
          options: options,
          selectedSchools: _selectedSchools,
          dutyType: _dutyType,
          operatingDays: _operatingDays,
          notesController: _notesCtrl,
          active: _active,
          showGlobalError: _showGlobalError,
          onPickStart: _pickStart,
          routeStartAddress: _routeStartAddress,
          routeStartValue: _routeStart,
          onSchoolsChanged: (v) => setState(() => _selectedSchools = v),
          onDutyTypeChanged: (v) => setState(() => _dutyType = v),
          onOperatingDaysChanged: (v) => setState(() => _operatingDays = v),
          onActiveChanged: (v) => setState(() => _active = v),
        ),
      ),
    );
  }

  bool _validate() {
    final valid = widget.formKey.currentState?.validate() ?? false;
    final requiredOk =
        _selectedSchools.isNotEmpty &&
        _dutyType != null &&
        _routeStart != null &&
        _operatingDays != null;
    setState(() => _showGlobalError = !(valid && requiredOk));
    return valid && requiredOk;
  }

  void submit() {
    if (!_validate()) return;
    widget.onSubmit({
      'schoolNames': _selectedSchools,
      'dutyType': _dutyType,
      'routeStart': _routeStart,
      'routeStartAddress': _routeStartAddress,
      'operatingDays': _operatingDays,
      // Treat extra notes as optional; send null when empty so it never
      // participates in validation logic upstream.
      'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      'active': _active,
    });
  }
}

// _DropdownField removed in favor of shared AppDropdown widget.

// _MultiDropdownField removed in favor of shared AppMultiSelect widget.

// Map picker widget moved to map_pick_field.dart
