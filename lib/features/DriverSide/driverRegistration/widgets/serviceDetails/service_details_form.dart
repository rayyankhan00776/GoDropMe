import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Removed unused UI imports after extracting form items.
// CustomTextField used via TextFieldItem in DynamicFormBuilder
import 'package:godropme/common_widgets/forms/dynamic_form_builder.dart';
import 'package:godropme/features/DriverSide/driverRegistration/utils/driver_service_options_loader.dart';
import 'package:godropme/features/DriverSide/driverRegistration/models/driver_service_options.dart';
import 'package:godropme/features/DriverSide/driverRegistration/widgets/serviceDetails/pickup_range_bottom_sheet.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/models/school.dart';
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
  List<String> _selectedSchoolNames = []; // For UI display
  List<School> _selectedSchools = []; // Full school objects with lat/lng
  String? _selectedCategory; // 'Male', 'Female', or 'Both'

  // coords
  LatLng? _routeStart;
  String? _routeStartAddress; // human-readable address for display/storage
  double _pickupRadiusKm = 0.5;
  List<LatLng> _pickupPolygon = const [];

  // fields
  final _notesCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
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
    _priceCtrl.dispose();
    super.dispose();
  }

  // Spacing handled by GapItem; legacy helper removed
  Future<void> _pickStart() async {
    final res = await showPickupRangeBottomSheet(
      context,
      initial: _routeStart,
      initialRadiusKm: _pickupRadiusKm,
    );
    if (res != null && mounted) {
      setState(() {
        _routeStart = res.center;
        _pickupRadiusKm = res.radiusKm;
        _pickupPolygon = res.polygon;
        _routeStartAddress = res.address; // may be null
      });
    }
  }

  /// When school names are selected, find the full School objects
  void _onSchoolsChanged(List<String> selectedNames) {
    final options = _options;
    if (options == null) return;
    
    setState(() {
      _selectedSchoolNames = selectedNames;
      // Map selected names to full School objects with lat/lng
      _selectedSchools = selectedNames
          .map((name) => options.getSchoolByName(name))
          .whereType<School>()
          .toList();
    });
  }

  void _onCategoryChanged(String? category) {
    setState(() => _selectedCategory = category);
  }

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
          selectedSchools: _selectedSchoolNames,
          selectedCategory: _selectedCategory,
          notesController: _notesCtrl,
          priceController: _priceCtrl,
          showGlobalError: _showGlobalError,
          onPickStart: _pickStart,
                routeStartAddress: (_routeStartAddress != null &&
                    _routeStartAddress!.trim().isNotEmpty)
                  ? '$_routeStartAddress, ${_pickupRadiusKm.toStringAsFixed(1)} km radius'
                  : '${_pickupRadiusKm.toStringAsFixed(1)} km radius',
          routeStartValue: _routeStart,
          onSchoolsChanged: _onSchoolsChanged,
          onCategoryChanged: _onCategoryChanged,
        ),
      ),
    );
  }

  bool _validate() {
    final valid = widget.formKey.currentState?.validate() ?? false;
    final requiredOk =
        _selectedSchools.isNotEmpty &&
        _selectedCategory != null &&
        _routeStart != null;
    setState(() => _showGlobalError = !(valid && requiredOk));
    return valid && requiredOk;
  }

  void submit() {
    if (!_validate()) return;
    widget.onSubmit({
      // Send full school objects with lat/lng for backend storage
      'schools': _selectedSchools.map((s) => s.toJson()).toList(),
      'serviceCategory': _selectedCategory,
      'serviceAreaCenter': _routeStart,
      'serviceAreaAddress': _routeStartAddress,
      'serviceAreaRadiusKm': _pickupRadiusKm,
      'serviceAreaPolygon': _pickupPolygon
          .map((p) => {'lat': p.latitude, 'lng': p.longitude})
          .toList(),
      // Monthly service price in PKR
      'monthlyPricePkr': int.tryParse(_priceCtrl.text.trim()) ?? 0,
      // Treat extra notes as optional; send null when empty so it never
      // participates in validation logic upstream.
      'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    });
  }
}

