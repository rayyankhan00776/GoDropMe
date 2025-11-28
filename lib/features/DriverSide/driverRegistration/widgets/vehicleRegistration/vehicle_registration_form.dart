import 'package:flutter/material.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/common_widgets/forms/dynamic_form_builder.dart';
import 'package:godropme/utils/app_typography.dart';
import 'vehicle_catalog_loader.dart';
import 'vehicle_form_items.dart';
// Removed direct dropdown/error imports in favor of DynamicFormBuilder items

// Uppercase plate formatting now provided via ExtraInputFormatters.toUpperCase

/// Helper to persist vehicle registration data when the parent screen proceeds.
// Duplicate save helper removed; controller persists the section.

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
      final catalog = await loadVehicleCatalog();

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
        _brands = catalog.brands;
        _modelsByBrand = catalog.modelsByBrand;
        _colors = catalog.colors;
        _selectedBrand = initialBrand;
        _selectedModel = initialModel;
        _selectedColor = initialColor;
        _seatMax = catalog.seatMax;
        _loading = false;
      });
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

  // spacing helper was used before; DynamicFormBuilder now handles spacing with GapItem

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
      child: DynamicFormBuilder(
        padding: EdgeInsets.zero,
        items: buildVehicleFormItems(
          context: context,
          selectedBrand: _selectedBrand,
          selectedModel: _selectedModel,
          selectedColor: _selectedColor,
          brands: _brands,
          modelsForSelectedBrand: _modelsForSelectedBrand(),
          colors: _colors,
          seatCapacityController: widget.seatCapacityController,
          yearController: widget.yearController,
          plateController: widget.plateController,
          showGlobalError: widget.showGlobalError,
          seatMax: _seatMax ?? 12,
          onBrandSelect: (val) {
            setState(() {
              _selectedBrand = val.trim();
              widget.brandController.text = val;
              _selectedModel = null;
              widget.modelController.clear();
            });
          },
          onModelSelect: (val) {
            setState(() {
              _selectedModel = val;
              widget.modelController.text = val;
            });
          },
          onColorSelect: (val) {
            setState(() {
              _selectedColor = val;
              widget.colorController.text = val;
            });
          },
        ),
      ),
    );
  }
}
