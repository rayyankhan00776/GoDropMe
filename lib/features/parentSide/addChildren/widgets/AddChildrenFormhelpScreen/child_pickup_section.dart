import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godropme/shared/widgets/map_pick_field.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/utils/responsive.dart';

class ChildPickupSection extends StatelessWidget {
  final TextEditingController controller;
  final LatLng? value;
  final VoidCallback onPickLocation;
  const ChildPickupSection({
    super.key,
    required this.controller,
    this.value,
    required this.onPickLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MapPickField(
          label: AppStrings.childPickPointHint,
          value: value,
          displayText: controller.text,
          onTap: onPickLocation,
          required: true,
        ),
        SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),
      ],
    );
  }
}
