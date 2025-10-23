import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/common%20widgets/custom_text_field.dart';
import 'package:godropme/features/driverSide/driverRegistration/utils/driver_service_options_loader.dart';
import 'package:godropme/features/driverSide/driverRegistration/models/driver_service_options.dart';
import 'package:godropme/features/driverSide/driverRegistration/widgets/serviceDetails/multi_select_bottom_sheet.dart';
import 'package:godropme/shared/bottom_sheets/location_picker_bottom_sheet.dart';
import 'package:godropme/shared/bottom_sheets/selection_bottom_sheet.dart';

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
  String? _pickupRange;
  List<String> _selectedSchools = [];

  // coords
  LatLng? _routeStart;

  // fields
  final _fareCtrl = TextEditingController();
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
    _fareCtrl.dispose();
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
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Loading options...'),
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
          _MultiDropdownField(
            hint: 'School Name(s)',
            items: options.schools,
            selected: _selectedSchools,
            onChanged: (v) => setState(() => _selectedSchools = v),
          ),

          _gap(context),

          // Duty type dropdown
          _DropdownField(
            hint: 'Duty Type',
            value: _dutyType,
            items: options.dutyTypes,
            onSelect: (v) => setState(() => _dutyType = v),
          ),

          _gap(context),

          // Pickup range dropdown
          _DropdownField(
            hint: 'Pickup Range (km)',
            value: _pickupRange,
            items: options.pickupRangeKmOptions,
            onSelect: (v) => setState(() => _pickupRange = v),
          ),

          _gap(context),

          // Route start / end pickers
          _MapPickField(
            label: 'Route Start Point',
            value: _routeStart,
            onTap: _pickStart,
            required: true,
          ),

          _gap(context),

          // Fare
          CustomTextField(
            controller: _fareCtrl,
            hintText: 'Per Child Monthly Fare (PKR)',
            borderColor: AppColors.gray,
            validator: (v) {
              if ((v ?? '').trim().isEmpty) return 'Please enter fare or range';
              return null;
            },
          ),

          _gap(context),

          // Operating days dropdown
          _DropdownField(
            hint: 'Operating Days',
            value: _operatingDays,
            items: options.operatingDays,
            onSelect: (v) => setState(() => _operatingDays = v),
          ),

          _gap(context),

          // Notes
          CustomTextField(
            controller: _notesCtrl,
            hintText: 'Extra Notes (optional)',
            borderColor: AppColors.gray,
          ),

          _gap(context),

          // Active toggle
          SwitchListTile(
            value: _active,
            onChanged: (v) => setState(() => _active = v),
            title: const Text('Active Status'),
            subtitle: const Text('Mark as available/unavailable'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 0),
          ),

          SizedBox(height: Responsive.scaleClamped(context, 6, 4, 12)),

          SizedBox(
            height: 18,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                _showGlobalError ? 'Please complete required fields' : '',
                style: TextStyle(
                  color: _showGlobalError
                      ? const Color(0xFFFF6B6B)
                      : Colors.transparent,
                  fontSize: 12,
                ),
              ),
            ),
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
        _pickupRange != null &&
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
      'pickupRangeKm': _pickupRange,
      'routeStart': _routeStart,
      'fare': _fareCtrl.text.trim(),
      'operatingDays': _operatingDays,
      // Treat extra notes as optional; send null when empty so it never
      // participates in validation logic upstream.
      'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      'active': _active,
    });
  }
}

class _DropdownField extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String> onSelect;

  const _DropdownField({
    required this.hint,
    required this.value,
    required this.items,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await showSelectionBottomSheet(
            context: context,
            title: hint,
            items: items,
            selected: value,
            onSelect: onSelect,
          );
        },
        child: InputDecorator(
          decoration: InputDecoration(
            hintText: hint,
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
            filled: true,
            fillColor: AppColors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value ?? hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: (value == null)
                      ? AppTypography.optionTerms
                      : AppTypography.optionLineSecondary.copyWith(
                          color: AppColors.black,
                        ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.darkGray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MultiDropdownField extends StatelessWidget {
  final String hint;
  final List<String> items;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const _MultiDropdownField({
    required this.hint,
    required this.items,
    required this.selected,
    required this.onChanged,
  });

  String _summary() {
    if (selected.isEmpty) return 'Tap to select';
    if (selected.length <= 2) return selected.join(', ');
    return selected.take(2).join(', ') + '  +${selected.length - 2} more';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final res = await showMultiSelectBottomSheet(
            context: context,
            title: hint,
            items: items,
            initiallySelected: selected,
          );
          if (res != null) onChanged(res);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: AppColors.gray, width: 2),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            isDense: true,
            filled: true,
            fillColor: AppColors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _summary(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: selected.isEmpty
                      ? AppTypography.optionTerms
                      : AppTypography.optionLineSecondary.copyWith(
                          color: AppColors.black,
                        ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.darkGray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
