import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godropme/shared/widgets/map_pick_field.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/shared/widgets/section_header.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';

class ChildDropSection extends StatelessWidget {
  final TextEditingController controller;
  final bool sameAsPick;
  final ValueChanged<bool> onSameAsPickChanged;
  final VoidCallback onPickDropLocation;
  final LatLng? value;
  const ChildDropSection({
    super.key,
    required this.controller,
    required this.sameAsPick,
    required this.onSameAsPickChanged,
    required this.onPickDropLocation,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(
          title: AppStrings.childDropPointHint,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppStrings.sameAsPick, style: AppTypography.helperSmall),
              const SizedBox(width: 8),
              Switch(
                value: sameAsPick,
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                onChanged: onSameAsPickChanged,
              ),
            ],
          ),
        ),
        MapPickField(
          label: AppStrings.tapToSelectOnMap,
          value: value,
          displayText: controller.text,
          onTap: onPickDropLocation,
          required: true,
        ),
        SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),
      ],
    );
  }
}
