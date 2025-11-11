import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_picker/location_picker_sheet.dart';
export 'location_picker/location_picker_sheet.dart' show LocationSelection;

/// Shared location picker bottom sheet (coordinates only).
Future<LatLng?> showLocationPickerBottomSheet(
  BuildContext context, {
  LatLng? initial,
}) {
  return showModalBottomSheet<LatLng?>(
    context: context,
    isScrollControlled: true,
    enableDrag: false,
    isDismissible: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) =>
        LocationPickerSheet(initial: initial, returnAddress: false),
  );
}

// (Export moved above per Dart directive ordering rules.)

/// Variant that returns both address string and LatLng. Use this when you want
/// to store/show the human-readable address instead of raw coordinates.
Future<LocationSelection?> showAddressLocationPickerBottomSheet(
  BuildContext context, {
  LatLng? initial,
}) {
  return showModalBottomSheet<LocationSelection?>(
    context: context,
    isScrollControlled: true,
    enableDrag: false,
    isDismissible: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) =>
        LocationPickerSheet(initial: initial, returnAddress: true),
  );
}

// Implementation moved to location_picker/location_picker_sheet.dart
