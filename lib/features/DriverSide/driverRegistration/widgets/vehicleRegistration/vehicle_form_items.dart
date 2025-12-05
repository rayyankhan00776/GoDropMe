import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:godropme/common_widgets/forms/form_items.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/utils/validators.dart';
import 'package:godropme/utils/validators_extra.dart';

/// Builds the list of DynamicFormBuilder items for the vehicle registration form,
/// preserving spacing, labels, and validators exactly as before.
List<FormItem> buildVehicleFormItems({
  required BuildContext context,
  required String? selectedBrand,
  required String? selectedModel,
  required String? selectedColor,
  required List<String> brands,
  required List<String> modelsForSelectedBrand,
  required List<String> colors,
  required TextEditingController seatCapacityController,
  required TextEditingController yearController,
  required TextEditingController plateController,
  required bool showGlobalError,
  required int seatMax,
  required void Function(String) onBrandSelect,
  required void Function(String) onModelSelect,
  required void Function(String) onColorSelect,
}) {
  return [
    // Brand dropdown (full width)
    DropdownItem(
      hint: AppStrings.vehicleBrandHint,
      value: selectedBrand,
      items: brands,
      onSelect: onBrandSelect,
    ),
    GapItem(Responsive.scaleClamped(context, 12, 8, 18)),

    // Model dropdown filtered by brand
    DropdownItem(
      hint: AppStrings.vehicleModelHint,
      value: selectedModel,
      items: modelsForSelectedBrand,
      enabled:
          (selectedBrand?.trim().isNotEmpty == true) &&
          modelsForSelectedBrand.isNotEmpty,
      onSelect: onModelSelect,
    ),

    GapItem(Responsive.scaleClamped(context, 12, 8, 18)),

    // Color dropdown (global list)
    DropdownItem(
      hint: AppStrings.vehicleColorHint,
      value: selectedColor,
      items: colors,
      onSelect: onColorSelect,
    ),

    GapItem(Responsive.scaleClamped(context, 12, 8, 18)),

    // Seat capacity text field (placed beneath Color)
    TextFieldItem(
      controller: seatCapacityController,
      hintText: AppStrings.vehicleSeatCapacityHint,
      borderColor: AppColors.gray,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
      ],
      validator: (v) => Validators.seatCapacity(v, max: seatMax),
    ),

    GapItem(Responsive.scaleClamped(context, 6, 4, 10)),
    LabelItem(
      child: Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: Text(
          '${AppStrings.seatCapacityMaxLabelPrefix} $seatMax',
          // Styles are applied by the LabelItem's child usage upstream.
        ),
      ),
    ),

    GapItem(Responsive.scaleClamped(context, 12, 8, 18)),

    // Keep year and number plate as text fields
    TextFieldItem(
      controller: yearController,
      hintText: AppStrings.vehicleProductionYearHint,
      borderColor: AppColors.gray,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      validator: Validators.productionYear,
    ),

    GapItem(Responsive.scaleClamped(context, 12, 8, 18)),

    TextFieldItem(
      controller: plateController,
      hintText: AppStrings.vehicleNumberPlateHint,
      borderColor: AppColors.gray,
      inputFormatters: [ExtraInputFormatters.toUpperCase],
      validator: Validators.plateNotEmpty,
    ),

    GapItem(Responsive.scaleClamped(context, 6, 4, 12)),

    ErrorLineItem(
      message: AppStrings.formGlobalError,
      visible: showGlobalError,
    ),
  ];
}
