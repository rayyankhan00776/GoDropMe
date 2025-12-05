import 'package:flutter/material.dart';
import 'package:godropme/common_widgets/forms/form_items.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/features/DriverSide/driverRegistration/models/driver_service_options.dart';
import 'package:godropme/common_widgets/app_multi_select.dart';
import 'package:godropme/common_widgets/app_dropdown.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/shared/widgets/map_pick_field.dart';

/// Builds the DynamicFormBuilder items for the Service Details form,
/// keeping spacing, labels, and validators identical to the original.
List<FormItem> buildServiceFormItems({
  required BuildContext context,
  required DriverServiceOptions options,
  required List<String> selectedSchools,
  required String? selectedCategory,
  required TextEditingController notesController,
  required TextEditingController priceController,
  required bool showGlobalError,
  required VoidCallback onPickStart,
  required String? routeStartAddress,
  required Object?
  routeStartValue, // LatLng?, but keep loose to avoid import leaks
  required void Function(List<String>) onSchoolsChanged,
  required void Function(String?) onCategoryChanged,
}) {
  return [
    // Schools multi-select
    LabelItem(
      child: AppMultiSelect(
        hint: AppStrings.schoolNamesHint,
        items: options.schoolNames, // Use getter for string names
        selected: selectedSchools,
        onChanged: onSchoolsChanged,
      ),
    ),

    GapItem(Responsive.scaleClamped(context, 12, 8, 18)),

    // Service category dropdown (Male/Female/Both)
    LabelItem(
      child: AppDropdown(
        hint: 'Service Category (Gender)',
        items: options.serviceCategories,
        value: selectedCategory,
        onSelect: (val) => onCategoryChanged(val),
      ),
    ),

    GapItem(Responsive.scaleClamped(context, 12, 8, 18)),

    // Pickup range picker (center + radius)
    LabelItem(
      child: MapPickField(
        label: AppStrings.pickupRangeKmHint,
        value:
            routeStartValue
                as dynamic, // cast at callsite; MapPickField expects LatLng?
        displayText: routeStartAddress,
        onTap: onPickStart,
        required: true,
      ),
    ),

    GapItem(Responsive.scaleClamped(context, 12, 8, 18)),

    // Monthly service price (PKR)
    TextFieldItem(
      controller: priceController,
      hintText: 'Monthly Service Price (PKR)',
      borderColor: AppColors.gray,
      keyboardType: TextInputType.number,
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Please enter monthly price';
        }
        final price = int.tryParse(v.trim());
        if (price == null || price <= 0) {
          return 'Please enter a valid price';
        }
        return null;
      },
    ),

    GapItem(Responsive.scaleClamped(context, 12, 8, 18)),

    // Notes (optional)
    TextFieldItem(
      controller: notesController,
      hintText: AppStrings.extraNotesHint,
      borderColor: AppColors.gray,
      validator: (_) => null,
    ),

    GapItem(Responsive.scaleClamped(context, 12, 8, 18)),

    // Spacer before error line
    GapItem(Responsive.scaleClamped(context, 6, 4, 12)),

    ErrorLineItem(
      message: AppStrings.requiredFieldsMissing,
      visible: showGlobalError,
    ),
  ];
}
