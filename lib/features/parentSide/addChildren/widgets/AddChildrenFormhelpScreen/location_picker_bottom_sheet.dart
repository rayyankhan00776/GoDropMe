// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godropme/theme/colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

/// Shows a modal bottom sheet with a GoogleMap for selecting a single location.
/// Returns the selected LatLng when the user confirms, or null if cancelled.
Future<LatLng?> showLocationPickerBottomSheet(
  BuildContext context, {
  LatLng? initial,
}) async {
  return showModalBottomSheet<LatLng?>(
    context: context,
    isScrollControlled: true,
    // Prevent the sheet's drag from stealing vertical gestures from the map.
    // The sheet can be closed via the Cancel/Use buttons (and by tapping the barrier).
    enableDrag: false,
    isDismissible: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => _LocationPickerSheet(initial: initial),
  );
}

class _LocationPickerSheet extends StatefulWidget {
  final LatLng? initial;
  const _LocationPickerSheet({this.initial});

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  final Completer<GoogleMapController> _mapController = Completer();
  late LatLng _selected;
  bool _locating = false;
  bool _hasPermission = false;

  // Fallback only if GPS is unavailable/denied — set to Peshawar
  static const LatLng _fallback = LatLng(34.0151, 71.5249); // Peshawar

  @override
  void initState() {
    super.initState();
    _selected = widget.initial ?? _fallback;
    // Try to get current GPS location when the sheet opens
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      // Request permission if needed
      final status = await Permission.locationWhenInUse.request();
      if (!status.isGranted) return;
      if (mounted) setState(() => _hasPermission = true);

      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return; // keep fallback, do not block

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() => _selected = latLng);
      // Center camera to current location
      if (_mapController.isCompleted) {
        final c = await _mapController.future;
        c.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: 16),
          ),
        );
      }
    } catch (_) {
      // Silently ignore and keep fallback
    }
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
          actionLabel: 'Settings',
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
          actionLabel: 'Enable',
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
    } catch (e) {
      _showSnack('Unable to fetch current location.');
    } finally {
      if (mounted) setState(() => _locating = false);
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
          // Grab handle
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
                          '${_selected.latitude.toStringAsFixed(6)}, ${_selected.longitude.toStringAsFixed(6)}',
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
                          final coords =
                              '${_selected.latitude.toStringAsFixed(6)}, ${_selected.longitude.toStringAsFixed(6)}';
                          await Clipboard.setData(ClipboardData(text: coords));
                          if (mounted) {
                            _showSnack('Copied: $coords');
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
                  // Rebuild the GoogleMap when permission state changes so the
                  // native myLocation layer re-initializes; without this, the
                  // default "Locate Me" button may do nothing after granting
                  // permission because the map instance was created earlier.
                  key: ValueKey(_hasPermission),
                  initialCameraPosition: _initialCamera,
                  onMapCreated: (c) => _mapController.complete(c),
                  myLocationButtonEnabled: true,
                  myLocationEnabled: _hasPermission,
                  // Ensure the map eagerly claims gestures to avoid
                  // competition with the bottom sheet drag/scroll.
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
                  onTap: (pos) => setState(() => _selected = pos),
                  markers: {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: _selected,
                      draggable: true,
                      onDragEnd: (pos) => setState(() => _selected = pos),
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
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_selected),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Use this location'),
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
