import 'dart:async';
import 'package:geocoding/geocoding.dart' as gc;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

/// Utility services extracted from the monolithic location picker bottom sheet.
/// Pure logic only; no UI concerns here.
class LocationServices {
  LocationServices._();

  /// Request location permission (when in use). Returns true if granted.
  static Future<bool> ensurePermission() async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isDenied || status.isRestricted) {
      status = await Permission.locationWhenInUse.request();
    }
    if (status.isPermanentlyDenied) return false;
    return status.isGranted;
  }

  /// Returns current high-accuracy position or throws.
  static Future<LatLng> currentPosition() async {
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return LatLng(pos.latitude, pos.longitude);
  }

  /// Reverse geocode into a human readable address string with fallbacks.
  static Future<String> reverseAddress(LatLng p) async {
    try {
      final placemarks = await gc.placemarkFromCoordinates(
        p.latitude,
        p.longitude,
      );
      if (placemarks.isEmpty) {
        return '${p.latitude.toStringAsFixed(6)}, ${p.longitude.toStringAsFixed(6)}';
      }
      final pm = placemarks.first;
      return _formatPlacemark(pm, p);
    } catch (_) {
      return '${p.latitude.toStringAsFixed(6)}, ${p.longitude.toStringAsFixed(6)}';
    }
  }

  static String _formatPlacemark(gc.Placemark pm, LatLng p) {
    final rawParts = <String>[
      (pm.name ?? '').trim(),
      (pm.street ?? '').trim(),
      (pm.subLocality ?? '').trim(),
      (pm.locality ?? '').trim(),
      (pm.administrativeArea ?? '').trim(),
      (pm.postalCode ?? '').trim(),
      (pm.country ?? '').trim(),
    ];
    final seen = <String>{};
    final cleaned = <String>[];
    for (final part in rawParts) {
      final n = part.trim();
      if (n.isEmpty) continue;
      final key = n.toLowerCase();
      if (seen.add(key)) cleaned.add(n);
    }
    if (cleaned.isEmpty) {
      return '${p.latitude.toStringAsFixed(6)}, ${p.longitude.toStringAsFixed(6)}';
    }
    return cleaned.join(', ');
  }
}
