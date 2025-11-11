import 'package:flutter/material.dart';
import 'package:godropme/common%20widgets/forms/form_items.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/features/driverSide/driverRegistration/models/driver_service_options.dart';
import 'package:godropme/common%20widgets/app_multi_select.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/shared/widgets/map_pick_field.dart';

/// Builds the DynamicFormBuilder items for the Service Details form,
/// keeping spacing, labels, and validators identical to the original.
List<FormItem> buildServiceFormItems({
  required BuildContext context,
  required DriverServiceOptions options,
  required List<String> selectedSchools,
  required String? dutyType,
  required String? operatingDays,
  required TextEditingController notesController,
  required bool active,
  required bool showGlobalError,
  required VoidCallback onPickStart,
  required String? routeStartAddress,
  required Object?
  routeStartValue, // LatLng?, but keep loose to avoid import leaks
  required void Function(List<String>) onSchoolsChanged,
  required void Function(String) onDutyTypeChanged,
  required void Function(String) onOperatingDaysChanged,
  required void Function(bool) onActiveChanged,
}) {
  return [
    // Schools multi-select
    LabelItem(
      child: AppMultiSelect(
        hint: AppStrings.schoolNamesHint,
        items: options.schools,
        selected: selectedSchools,
        onChanged: onSchoolsChanged,
      ),
    ),

    GapItem(Responsive.scaleClamped(context, 12, 8, 18)),

    // Duty type dropdown
    DropdownItem(
      hint: AppStrings.dutyTypeHint,
      value: dutyType,
      items: options.dutyTypes,
      onSelect: onDutyTypeChanged,
    ),

    GapItem(Responsive.scaleClamped(context, 12, 8, 18)),

    // Route start picker
    LabelItem(
      child: MapPickField(
        label: AppStrings.routeStartPointLabel,
        value:
            routeStartValue
                as dynamic, // cast at callsite; MapPickField expects LatLng?
        displayText: routeStartAddress,
        onTap: onPickStart,
        required: true,
      ),
    ),

    GapItem(Responsive.scaleClamped(context, 12, 8, 18)),

    // Operating days dropdown
    DropdownItem(
      hint: AppStrings.operatingDaysHint,
      value: operatingDays,
      items: options.operatingDays,
      onSelect: onOperatingDaysChanged,
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

    // Active toggle
    LabelItem(
      child: SwitchListTile(
        value: active,
        onChanged: onActiveChanged,
        title: Text(AppStrings.activeStatus),
        subtitle: Text(AppStrings.activeStatusSubtitle),
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      ),
    ),

    GapItem(Responsive.scaleClamped(context, 6, 4, 12)),

    ErrorLineItem(
      message: AppStrings.requiredFieldsMissing,
      visible: showGlobalError,
    ),
  ];
}
