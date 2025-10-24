import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:godropme/utils/app_assets.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/common%20widgets/custom_text_field.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/utils/validators.dart';
import 'package:godropme/common%20widgets/app_dropdown.dart';
import 'package:godropme/common%20widgets/form_error_line.dart';

/// Forces any alphabetic input to uppercase for fields like number plates.
/// Keeps cursor at the end of the transformed text for a natural typing feel.
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upper = newValue.text.toUpperCase();
    return TextEditingValue(
      text: upper,
      selection: TextSelection.collapsed(offset: upper.length),
    );
  }
}

/// Helper to persist vehicle registration data when the parent screen proceeds.
Future<void> saveVehicleRegistrationSection({
  required String brand,
  required String model,
  required String color,
  required String year,
  required String plate,
  required int seatCapacity,
  required String? vehiclePhotoPath,
  required String? certFrontPath,
  required String? certBackPath,
}) async {
  await LocalStorage.setJson(StorageKeys.vehicleRegistration, {
    'brand': brand,
    'model': model,
    'color': color,
    'year': year,
    'plate': plate,
    'seatCapacity': seatCapacity,
    'vehiclePhotoPath': vehiclePhotoPath,
    'certFrontPath': certFrontPath,
    'certBackPath': certBackPath,
  });
}

class VehicleRegistrationForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController colorController;
  final TextEditingController yearController;
  final TextEditingController plateController;
  final TextEditingController seatCapacityController;
  final bool showSubmittedErrors;
  final bool showGlobalError;

  const VehicleRegistrationForm({
    super.key,
    required this.formKey,
    required this.brandController,
    required this.modelController,
    required this.colorController,
    required this.yearController,
    required this.plateController,
    required this.seatCapacityController,
    required this.showSubmittedErrors,
    this.showGlobalError = false,
  });

  @override
  State<VehicleRegistrationForm> createState() =>
      _VehicleRegistrationFormState();
}

class _VehicleRegistrationFormState extends State<VehicleRegistrationForm> {
  List<String> _brands = [];
  Map<String, List<String>> _modelsByBrand = {};
  List<String> _colors = [];

  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedColor;

  bool _loading = true;
  String? _loadError;
  int? _seatMax;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    try {
      // Decide data source based on previously selected vehicle type
      final selection = (await LocalStorage.getString(
        StorageKeys.vehicleSelection,
      ))?.trim().toLowerCase();
      final assetPath = (selection == 'rikshaw' || selection == 'rickshaw')
          ? AppAssets.rikshawcarJsonData
          : AppAssets.carcarJsonData;
      final jsonStr = await rootBundle.loadString(assetPath);
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final brands = (data['vehicleBrands'] as List<dynamic>).cast<String>();
      final models = (data['vehicleModels'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, (v as List<dynamic>).cast<String>()),
      );
      final colors = (data['vehicleColors'] as List<dynamic>).cast<String>();

      // Initialize from existing controllers if they already have values
      String? initialBrand = widget.brandController.text.trim().isEmpty
          ? null
          : widget.brandController.text.trim();
      String? initialModel = widget.modelController.text.trim().isEmpty
          ? null
          : widget.modelController.text.trim();
      String? initialColor = widget.colorController.text.trim().isEmpty
          ? null
          : widget.colorController.text.trim();

      setState(() {
        _brands = brands;
        _modelsByBrand = models;
        _colors = colors;
        _selectedBrand = initialBrand;
        _selectedModel = initialModel;
        _selectedColor = initialColor;
        _loading = false;
      });
      // Determine seat capacity cap from saved vehicle selection (Car/Rikshaw)
      // Defaults: Car<=9, Rikshaw<=4, else <=12
      final sel = await LocalStorage.getString(StorageKeys.vehicleSelection);
      final v = sel?.trim().toLowerCase();
      int cap;
      if (v == 'car') {
        cap = 9;
      } else if (v == 'rikshaw' || v == 'rickshaw') {
        cap = 4;
      } else {
        cap = 12;
      }
      if (mounted) setState(() => _seatMax = cap);
    } catch (e) {
      setState(() {
        _loadError = 'Failed to load car catalog';
        _loading = false;
      });
    }
  }

  List<String> _modelsForSelectedBrand() {
    final sel = _selectedBrand;
    if (sel == null || sel.trim().isEmpty) return const [];
    // Try exact key first
    if (_modelsByBrand.containsKey(sel)) return _modelsByBrand[sel] ?? const [];
    // Fallback: case/whitespace-insensitive match
    final normSel = sel.trim().toLowerCase();
    for (final k in _modelsByBrand.keys) {
      if (k.trim().toLowerCase() == normSel) {
        return _modelsByBrand[k] ?? const [];
      }
    }
    return const [];
  }

  Widget _gap(BuildContext context) =>
      SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18));

  // Border builder no longer used after migrating to AppDropdown

  // Removed local selection sheet and dropdown builder; use shared widgets instead.

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(AppStrings.loadingCatalog, style: AppTypography.optionTerms),
          ],
        ),
      );
    }
    if (_loadError != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(_loadError!, style: AppTypography.errorSmall),
      );
    }

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand dropdown (full width)
          AppDropdown(
            hint: AppStrings.vehicleBrandHint,
            value: _selectedBrand,
            items: _brands,
            onSelect: (val) {
              setState(() {
                _selectedBrand = val.trim();
                widget.brandController.text = val;
                // Reset model when brand changes
                _selectedModel = null;
                widget.modelController.clear();
              });
            },
          ),
          _gap(context),

          // Model dropdown filtered by brand
          AppDropdown(
            hint: AppStrings.vehicleModelHint,
            value: _selectedModel,
            items: _modelsForSelectedBrand(),
            enabled:
                (_selectedBrand?.trim().isNotEmpty == true) &&
                _modelsForSelectedBrand().isNotEmpty,
            onSelect: (val) {
              setState(() {
                _selectedModel = val;
                widget.modelController.text = val;
              });
            },
          ),

          _gap(context),

          // Color dropdown (global list)
          AppDropdown(
            hint: AppStrings.vehicleColorHint,
            value: _selectedColor,
            items: _colors,
            onSelect: (val) {
              setState(() {
                _selectedColor = val;
                widget.colorController.text = val;
              });
            },
          ),

          _gap(context),

          // Seat capacity text field (placed beneath Color)
          CustomTextField(
            controller: widget.seatCapacityController,
            hintText: AppStrings.vehicleSeatCapacityHint,
            borderColor: AppColors.gray,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            validator: (v) => Validators.seatCapacity(v, max: _seatMax ?? 12),
          ),

          SizedBox(height: Responsive.scaleClamped(context, 6, 4, 10)),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              '${AppStrings.seatCapacityMaxLabelPrefix} ${_seatMax ?? 12}',
              style: AppTypography.optionTerms.copyWith(
                color: AppColors.darkGray,
              ),
            ),
          ),

          _gap(context),

          // Keep year and number plate as text fields
          CustomTextField(
            controller: widget.yearController,
            hintText: AppStrings.vehicleProductionYearHint,
            borderColor: AppColors.gray,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            validator: Validators.productionYear,
          ),

          _gap(context),

          CustomTextField(
            controller: widget.plateController,
            hintText: AppStrings.vehicleNumberPlateHint,
            borderColor: AppColors.gray,
            inputFormatters: [_UpperCaseTextFormatter()],
            validator: Validators.plateNotEmpty,
          ),

          SizedBox(height: Responsive.scaleClamped(context, 6, 4, 12)),

          FormErrorLine(
            message: AppStrings.formGlobalError,
            visible: widget.showGlobalError,
          ),
        ],
      ),
    );
  }
}
