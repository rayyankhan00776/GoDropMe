import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as gc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/constants/app_strings.dart';

/// Shared location picker bottom sheet with GoogleMap.
/// Returns the selected LatLng when confirmed, or null if cancelled.
Future<LatLng?> showLocationPickerBottomSheet(
  BuildContext context, {
  LatLng? initial,
}) async {
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
        _LocationPickerSheet(initial: initial, returnAddress: false),
  );
}

/// Address + coordinates selection result.
class LocationSelection {
  final LatLng position;
  final String address;
  const LocationSelection({required this.position, required this.address});
}

/// Variant that returns both address string and LatLng. Use this when you want
/// to store/show the human-readable address instead of raw coordinates.
Future<LocationSelection?> showAddressLocationPickerBottomSheet(
  BuildContext context, {
  LatLng? initial,
}) async {
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
        _LocationPickerSheet(initial: initial, returnAddress: true),
  );
}

class _LocationPickerSheet extends StatefulWidget {
  final LatLng? initial;
  final bool returnAddress;
  const _LocationPickerSheet({this.initial, required this.returnAddress});

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  final Completer<GoogleMapController> _mapController = Completer();
  late LatLng _selected;
  bool _locating = false;
  bool _hasPermission = false;
  bool _userChangedSelection =
      false; // prevent auto-recenter after user interaction
  String? _address; // resolved address for the selected coordinate
  bool _resolving = false; // throttle reverse geocoding

  // Fallback only if GPS is unavailable/denied — set to Peshawar
  static const LatLng _fallback = LatLng(34.0151, 71.5249); // Peshawar

  @override
  void initState() {
    super.initState();
    _selected = widget.initial ?? _fallback;
    // Only auto-locate if caller didn't provide an initial position.
    // This avoids surprising jumps when an initial location is already meaningful.
    if (widget.initial == null) {
      _initLocation();
    }
    // Resolve initial address
    _resolveAddress(_selected);
  }

  Future<void> _initLocation() async {
    try {
      final status = await Permission.locationWhenInUse.request();
      if (!status.isGranted) return;
      if (mounted) setState(() => _hasPermission = true);

      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      // If the user already interacted, don't override their selection.
      if (!_userChangedSelection) {
        setState(() => _selected = latLng);
        if (_mapController.isCompleted) {
          final c = await _mapController.future;
          await c.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: latLng, zoom: 16),
            ),
          );
        }
        // Update address when we programmatically move to current location
        _resolveAddress(latLng);
      }
    } catch (_) {}
  }

  void _showSnack(String msg, {String? actionLabel, VoidCallback? onAction}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        action: (actionLabel != null && onAction != null)
            ? SnackBarAction(label: actionLabel, onPressed: onAction)
            : null,
      ),
    );
  }

  Future<void> _locateMe() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      var status = await Permission.locationWhenInUse.status;
      if (status.isDenied || status.isRestricted) {
        status = await Permission.locationWhenInUse.request();
      }
      if (status.isPermanentlyDenied) {
        _showSnack(
          'Location permission permanently denied. Open app settings to enable.',
          actionLabel: AppStrings.settings,
          onAction: openAppSettings,
        );
        return;
      }
      if (!status.isGranted) {
        _showSnack('Location permission denied.');
        return;
      }
      if (mounted) setState(() => _hasPermission = true);

      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _showSnack(
          'Location services are disabled.',
          actionLabel: AppStrings.enable,
          onAction: Geolocator.openLocationSettings,
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() => _selected = latLng);
      if (_mapController.isCompleted) {
        final c = await _mapController.future;
        await c.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: 16),
          ),
        );
      }
      _resolveAddress(latLng);
    } catch (_) {
      _showSnack('Unable to fetch current location.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  /// Reverse geocode current selection into a human-readable address.
  Future<void> _resolveAddress(LatLng p) async {
    if (_resolving) return;
    setState(() => _resolving = true);
    try {
      final placemarks = await gc.placemarkFromCoordinates(
        p.latitude,
        p.longitude,
      );
      if (!mounted) return;
      if (placemarks.isNotEmpty) {
        final pm = placemarks.first;
        final parts = <String>[
          if ((pm.name ?? '').trim().isNotEmpty) pm.name!.trim(),
          if ((pm.street ?? '').trim().isNotEmpty) pm.street!.trim(),
          if ((pm.subLocality ?? '').trim().isNotEmpty) pm.subLocality!.trim(),
          if ((pm.locality ?? '').trim().isNotEmpty) pm.locality!.trim(),
          if ((pm.administrativeArea ?? '').trim().isNotEmpty)
            pm.administrativeArea!.trim(),
          if ((pm.country ?? '').trim().isNotEmpty) pm.country!.trim(),
        ];
        final addr = parts.where((e) => e.isNotEmpty).toList().join(', ');
        setState(
          () => _address = addr.isNotEmpty
              ? addr
              : '${p.latitude.toStringAsFixed(6)}, ${p.longitude.toStringAsFixed(6)}',
        );
      } else {
        setState(
          () => _address =
              '${p.latitude.toStringAsFixed(6)}, ${p.longitude.toStringAsFixed(6)}',
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _address =
              '${p.latitude.toStringAsFixed(6)}, ${p.longitude.toStringAsFixed(6)}',
        );
      }
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  CameraPosition get _initialCamera =>
      CameraPosition(target: _selected, zoom: 14);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return SizedBox(
      height: height * 0.8,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text(
                  'Select Location',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          _address == null
                              ? '${_selected.latitude.toStringAsFixed(6)}, ${_selected.longitude.toStringAsFixed(6)}'
                              : _address!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () async {
                          final textToCopy = _address == null
                              ? '${_selected.latitude.toStringAsFixed(6)}, ${_selected.longitude.toStringAsFixed(6)}'
                              : _address!;
                          await Clipboard.setData(
                            ClipboardData(text: textToCopy),
                          );
                          if (mounted) {
                            _showSnack('Copied: $textToCopy');
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.copy,
                            size: 16,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _initialCamera,
                  onMapCreated: (c) => _mapController.complete(c),
                  myLocationButtonEnabled: true,
                  myLocationEnabled: _hasPermission,
                  onCameraMoveStarted: () {
                    if (!_userChangedSelection) {
                      setState(() => _userChangedSelection = true);
                    }
                  },
                  onCameraMove: (pos) {
                    // Move marker with camera while dragging
                    setState(() => _selected = pos.target);
                  },
                  onCameraIdle: () {
                    // Resolve address once user finishes dragging
                    _resolveAddress(_selected);
                  },
                  gestureRecognizers: {
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                  scrollGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  padding: const EdgeInsets.only(bottom: 72, right: 12),
                  zoomControlsEnabled: false,
                  onTap: (pos) => setState(() {
                    _selected = pos;
                    _userChangedSelection = true;
                    _resolveAddress(pos);
                  }),
                  markers: {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: _selected,
                      draggable: true,
                      onDragEnd: (pos) => setState(() {
                        _selected = pos;
                        _userChangedSelection = true;
                        _resolveAddress(pos);
                      }),
                    ),
                  },
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Material(
                      color: Colors.white,
                      elevation: 3,
                      child: InkWell(
                        onTap: _locateMe,
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(
                            child: _locating
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.my_location, size: 22),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkGray,
                      side: const BorderSide(color: AppColors.grayLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(AppStrings.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (widget.returnAddress) {
                        final addr =
                            _address ??
                            '${_selected.latitude.toStringAsFixed(6)}, ${_selected.longitude.toStringAsFixed(6)}';
                        Navigator.of(context).pop(
                          LocationSelection(position: _selected, address: addr),
                        );
                      } else {
                        Navigator.of(context).pop(_selected);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(AppStrings.useThisLocation),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
