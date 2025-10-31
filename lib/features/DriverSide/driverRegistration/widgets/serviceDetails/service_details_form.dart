import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/common%20widgets/custom_text_field.dart';
import 'package:godropme/features/driverSide/driverRegistration/utils/driver_service_options_loader.dart';
import 'package:godropme/features/driverSide/driverRegistration/models/driver_service_options.dart';
import 'package:godropme/shared/bottom_sheets/location_picker_bottom_sheet.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/common%20widgets/app_dropdown.dart';
import 'package:godropme/common%20widgets/form_error_line.dart';
import 'package:godropme/common%20widgets/app_multi_select.dart';

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

  Widget _gap(BuildContext context) =>
      SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18));

  Future<void> _pickStart() async {
    final res = await showLocationPickerBottomSheet(
      context,
      initial: _routeStart,
    );
    if (res != null && mounted) setState(() => _routeStart = res);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Schools multi-select (dropdown-style with bottom sheet)
          AppMultiSelect(
            hint: AppStrings.schoolNamesHint,
            items: options.schools,
            selected: _selectedSchools,
            onChanged: (v) => setState(() => _selectedSchools = v),
          ),

          _gap(context),

          // Duty type dropdown
          AppDropdown(
            hint: AppStrings.dutyTypeHint,
            value: _dutyType,
            items: options.dutyTypes,
            onSelect: (v) => setState(() => _dutyType = v),
          ),

          _gap(context),

          // Pickup range dropdown
          // Pickup range removed

          // Route start / end pickers
          _MapPickField(
            label: AppStrings.routeStartPointLabel,
            value: _routeStart,
            onTap: _pickStart,
            required: true,
          ),

          _gap(context),

          // Fare field removed as per requirement

          // Operating days dropdown
          AppDropdown(
            hint: AppStrings.operatingDaysHint,
            value: _operatingDays,
            items: options.operatingDays,
            onSelect: (v) => setState(() => _operatingDays = v),
          ),

          _gap(context),

          // Notes
          CustomTextField(
            controller: _notesCtrl,
            hintText: AppStrings.extraNotesHint,
            borderColor: AppColors.gray,
          ),

          _gap(context),

          // Active toggle
          SwitchListTile(
            value: _active,
            onChanged: (v) => setState(() => _active = v),
            title: Text(AppStrings.activeStatus),
            subtitle: Text(AppStrings.activeStatusSubtitle),
            contentPadding: const EdgeInsets.symmetric(horizontal: 0),
          ),

          SizedBox(height: Responsive.scaleClamped(context, 6, 4, 12)),

          FormErrorLine(
            message: AppStrings.requiredFieldsMissing,
            visible: _showGlobalError,
          ),
        ],
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

class _MapPickField extends StatelessWidget {
  final String label;
  final LatLng? value;
  final VoidCallback onTap;
  final bool required;

  const _MapPickField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.required,
  });

  @override
  Widget build(BuildContext context) {
    final display = (value == null)
        ? (required ? 'Tap to select' : 'Optional')
        : '${value!.latitude.toStringAsFixed(5)}, ${value!.longitude.toStringAsFixed(5)}';
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.gray, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          isDense: true,
        ),
        child: Text(
          display,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: (value == null)
              ? AppTypography.optionTerms
              : AppTypography.optionLineSecondary.copyWith(
                  color: AppColors.black,
                ),
        ),
      ),
    );
  }
}
