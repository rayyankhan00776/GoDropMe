import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:godropme/core/utils/app_assets.dart';
import 'package:godropme/core/utils/app_strings.dart';
import 'package:godropme/core/theme/colors.dart';
import 'package:godropme/core/utils/responsive.dart';
import 'package:godropme/core/widgets/custom_text_field.dart';
import 'package:godropme/core/utils/app_typography.dart';
import 'package:godropme/core/utils/local_storage.dart';

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

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    try {
      final jsonStr = await rootBundle.loadString(AppAssets.jsonData);
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

  InputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color, width: 2),
  );

  Future<void> _showSelectionSheet({
    required String title,
    required List<String> items,
    required String? selected,
    required ValueChanged<String> onSelect,
  }) async {
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      builder: (ctx) {
        final height = MediaQuery.of(ctx).size.height * 0.75;
        return SafeArea(
          top: false,
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.optionHeading,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.darkGray,
                        ),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final item = items[i];
                      final isSelected = item == selected;
                      return ListTile(
                        title: Text(
                          item,
                          style: AppTypography.optionLineSecondary.copyWith(
                            color: AppColors.black,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: AppColors.primary)
                            : null,
                        onTap: () {
                          onSelect(item);
                          Navigator.of(ctx).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdown({
    required BuildContext context,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
  }) {
    final display = value?.isNotEmpty == true ? value! : hint;
    final isHint = value == null || value.isEmpty;
    return SizedBox(
      width: double.infinity,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled
            ? () => _showSelectionSheet(
                title: hint,
                items: items,
                selected: value,
                onSelect: (sel) => onChanged(sel),
              )
            : null,
        child: InputDecorator(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.optionTerms,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            enabledBorder: _border(AppColors.gray),
            focusedBorder: _border(AppColors.primary),
            disabledBorder: _border(AppColors.grayLight),
            isDense: true,
            filled: true,
            fillColor: AppColors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  display,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isHint
                      ? AppTypography.optionTerms
                      : AppTypography.optionLineSecondary.copyWith(
                          color: AppColors.black,
                        ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: enabled ? AppColors.darkGray : AppColors.grayLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: const [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Loading catalog...'),
          ],
        ),
      );
    }
    if (_loadError != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(_loadError!, style: const TextStyle(color: Colors.red)),
      );
    }

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand dropdown (full width)
          _buildDropdown(
            context: context,
            hint: AppStrings.vehicleBrandHint,
            value: _selectedBrand,
            items: _brands,
            onChanged: (val) {
              setState(() {
                _selectedBrand = val?.trim();
                widget.brandController.text = val ?? '';
                // Reset model when brand changes
                _selectedModel = null;
                widget.modelController.clear();
              });
            },
          ),

          _gap(context),

          // Model dropdown filtered by brand
          _buildDropdown(
            context: context,
            hint: AppStrings.vehicleModelHint,
            value: _selectedModel,
            items: _modelsForSelectedBrand(),
            enabled:
                (_selectedBrand?.trim().isNotEmpty == true) &&
                _modelsForSelectedBrand().isNotEmpty,
            onChanged: (val) {
              setState(() {
                _selectedModel = val;
                widget.modelController.text = val ?? '';
              });
            },
          ),

          _gap(context),

          // Color dropdown (global list)
          _buildDropdown(
            context: context,
            hint: AppStrings.vehicleColorHint,
            value: _selectedColor,
            items: _colors,
            onChanged: (val) {
              setState(() {
                _selectedColor = val;
                widget.colorController.text = val ?? '';
              });
            },
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
            validator: (v) {
              final val = v?.trim() ?? '';
              if (val.isEmpty) return 'Please enter production year';
              if (val.length != 4) return 'Year must be 4 digits';
              final year = int.tryParse(val);
              if (year == null || year < 1960 || year > DateTime.now().year) {
                return 'Enter a valid year';
              }
              return null;
            },
          ),

          _gap(context),

          CustomTextField(
            controller: widget.plateController,
            hintText: AppStrings.vehicleNumberPlateHint,
            borderColor: AppColors.gray,
            inputFormatters: [_UpperCaseTextFormatter()],
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please enter number plate'
                : null,
          ),

          SizedBox(height: Responsive.scaleClamped(context, 6, 4, 12)),

          SizedBox(
            height: 18,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                widget.showGlobalError
                    ? 'Please complete all fields and add images'
                    : '',
                style: TextStyle(
                  color: widget.showGlobalError
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
}
