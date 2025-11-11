import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';

/// Shared read-only form field that displays a map-picked value (address or
/// coordinates) with consistent styling across app modules.
class MapPickField extends StatelessWidget {
  final String label;
  final LatLng? value;
  final VoidCallback onTap;
  final bool required;
  final String? displayText; // optional, e.g., resolved address

  const MapPickField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    required this.required,
    this.displayText,
  });

  @override
  Widget build(BuildContext context) {
    final display = (value == null)
        ? (required ? 'Tap to select' : 'Optional')
        : (displayText == null || displayText!.trim().isEmpty
              ? '${value!.latitude.toStringAsFixed(5)}, ${value!.longitude.toStringAsFixed(5)}'
              : displayText!);
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
