import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:godropme/theme/colors.dart';

class PickupRangeResult {
  final LatLng center;
  final double radiusKm;
  final String? address;
  final List<LatLng> polygon; // Closed ring preferred downstream
  const PickupRangeResult({
    required this.center,
    required this.radiusKm,
    required this.polygon,
    this.address,
  });
}

Future<PickupRangeResult?> showPickupRangeBottomSheet(
  BuildContext context, {
  LatLng? initial,
  double initialRadiusKm = 0.5,
}) async {
  return showModalBottomSheet<PickupRangeResult>(
    context: context,
    isScrollControlled: true,
    enableDrag: false,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => _PickupRangeSheet(
      initial: initial,
      initialRadiusKm: initialRadiusKm,
    ),
  );
}

class _PickupRangeSheet extends StatefulWidget {
  final LatLng? initial;
  final double initialRadiusKm;
  const _PickupRangeSheet({this.initial, this.initialRadiusKm = 0.5});

  @override
  State<_PickupRangeSheet> createState() => _PickupRangeSheetState();
}

class _PickupRangeSheetState extends State<_PickupRangeSheet> {
  late double _radiusKm;
  LatLng? _center;
  String? _address;
  bool _loadingLocation = true;
  // Map controller intentionally omitted to avoid unused field warning

  @override
  void initState() {
    super.initState();
    _radiusKm = widget.initialRadiusKm;
    _center = widget.initial; // if null, we will try current location
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      // If initial is provided, just use it; else fetch current.
      if (_center == null) {
        final ok = await _ensureLocationPermission();
        if (ok) {
          final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
          );
          _center = LatLng(pos.latitude, pos.longitude);
        }
      }
      // Fallback if still null - Peshawar coordinates
      _center ??= const LatLng(34.0151, 71.5249);
      // Reverse geocode for display
      _address = await _reverseGeocode(_center!);
    } catch (_) {
      _center ??= const LatLng(34.0151, 71.5249);
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  Future<bool> _ensureLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  Future<String?> _reverseGeocode(LatLng p) async {
    try {
      final list = await geocoding.placemarkFromCoordinates(p.latitude, p.longitude);
      if (list.isEmpty) return null;
      final place = list.first;
      final parts = <String>[
        if ((place.subLocality ?? '').trim().isNotEmpty) place.subLocality!.trim(),
        if ((place.locality ?? '').trim().isNotEmpty) place.locality!.trim(),
        if ((place.administrativeArea ?? '').trim().isNotEmpty) place.administrativeArea!.trim(),
      ];
      if (parts.isEmpty && (place.street ?? '').trim().isNotEmpty) parts.add(place.street!.trim());
      return parts.join(', ');
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final sheetHeight = height * 0.75;

    return SizedBox(
      height: sheetHeight,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Pickup Range',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  tooltip: 'Use current location',
                  icon: const Icon(Icons.my_location),
                  onPressed: () async {
                    setState(() => _loadingLocation = true);
                    await _initLocation();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                if (_center != null)
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _center!,
                      zoom: 15,
                    ),
                    myLocationButtonEnabled: false,
                    myLocationEnabled: true,
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: true,
                    scrollGesturesEnabled: true,
                    rotateGesturesEnabled: true,
                    tiltGesturesEnabled: false,
                    onCameraMove: (pos) {
                      // Keep polygon fixed to center of the viewport
                      setState(() => _center = pos.target);
                    },
                    onCameraIdle: () async {
                      // Update address after dragging/zooming ends
                      if (_center != null) {
                        _address = await _reverseGeocode(_center!);
                      }
                    },
                    polygons: {
                      Polygon(
                        polygonId: const PolygonId('pickup_range_poly'),
                        points: _makeCirclePolygon(_center!, _radiusKm, 64),
                        strokeColor: AppColors.primary,
                        strokeWidth: 2,
                        fillColor: AppColors.primary.withValues(alpha: 0.15),
                      ),
                    },
                  ),
                if (_loadingLocation)
                  const Center(child: CircularProgressIndicator()),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: _RadiusControl(
                    valueKm: _radiusKm,
                    onChanged: (v) {
                      setState(() => _radiusKm = v);
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final poly = _makeCirclePolygon(_center!, _radiusKm, 64);
                  Navigator.of(context).pop(
                    PickupRangeResult(
                      center: _center!,
                      radiusKm: _radiusKm,
                      polygon: poly,
                      address: _address,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Use this range'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Create a polygon approximating a circle around center with given radius.
  List<LatLng> _makeCirclePolygon(LatLng center, double radiusKm, int points) {
    const double earthRadiusKm = 6371.0;
    final double lat = _degToRad(center.latitude);
    final double lon = _degToRad(center.longitude);
    final double dByR = radiusKm / earthRadiusKm;
    final result = <LatLng>[];
    for (int i = 0; i < points; i++) {
      final double bearing = 2 * math.pi * (i / points);
      final double lat2 = math.asin(
        math.sin(lat) * math.cos(dByR) +
            math.cos(lat) * math.sin(dByR) * math.cos(bearing),
      );
      final double lon2 = lon + math.atan2(
        math.sin(bearing) * math.sin(dByR) * math.cos(lat),
        math.cos(dByR) - math.sin(lat) * math.sin(lat2),
      );
      result.add(LatLng(_radToDeg(lat2), _radToDeg(lon2)));
    }
    // Close the ring
    if (result.isNotEmpty) result.add(result.first);
    return result;
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);
  double _radToDeg(double rad) => rad * (180.0 / math.pi);
}

class _RadiusControl extends StatelessWidget {
  final double valueKm;
  final ValueChanged<double> onChanged;
  const _RadiusControl({required this.valueKm, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    // Convert km to meters for display when < 1 km
    final displayText = valueKm < 1
        ? '${(valueKm * 1000).toInt()} m radius'
        : '${valueKm.toStringAsFixed(1)} km radius';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.social_distance, size: 20),
              const SizedBox(width: 8),
              Text(displayText,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          Slider(
            min: 0.2,
            max: 2.0,
            divisions: 18, // 0.1 km (100m) steps
            label: valueKm < 1
                ? '${(valueKm * 1000).toInt()} m'
                : '${valueKm.toStringAsFixed(1)} km',
            value: valueKm,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.grayLight,
          ),
        ],
      ),
    );
  }
}
