import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Utility class for creating custom map markers from asset images.
class MapMarkerUtils {
  static final Map<String, BitmapDescriptor> _cache = {};

  /// Asset paths for map marker icons
  static const String homeMarker = 'assets/icons/mapMarkers/home-location-pin.png';
  static const String schoolMarker = 'assets/icons/mapMarkers/school-location-pin.png';
  static const String carMarker = 'assets/icons/mapMarkers/car-location-pin.png';
  static const String rickshawMarker = 'assets/icons/mapMarkers/auto-rickshaw-location-pin.png';

  /// Load a custom marker from an asset image with optional size.
  /// [assetPath] - Path to the asset image
  /// [width] - Desired width of the marker (height scales proportionally)
  static Future<BitmapDescriptor> loadMarker(String assetPath, {int width = 80}) async {
    final cacheKey = '$assetPath-$width';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? byteData = await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      return BitmapDescriptor.defaultMarker;
    }

    final descriptor = BitmapDescriptor.bytes(byteData.buffer.asUint8List());
    _cache[cacheKey] = descriptor;
    return descriptor;
  }

  /// Preload all markers for faster access
  static Future<void> preloadAllMarkers({int width = 80}) async {
    await Future.wait([
      loadMarker(homeMarker, width: width),
      loadMarker(schoolMarker, width: width),
      loadMarker(carMarker, width: width),
      loadMarker(rickshawMarker, width: width),
    ]);
  }

  /// Get home marker
  static Future<BitmapDescriptor> getHomeMarker({int width = 80}) => 
      loadMarker(homeMarker, width: width);

  /// Get school marker
  static Future<BitmapDescriptor> getSchoolMarker({int width = 80}) => 
      loadMarker(schoolMarker, width: width);

  /// Get car marker (for car drivers)
  static Future<BitmapDescriptor> getCarMarker({int width = 80}) => 
      loadMarker(carMarker, width: width);

  /// Get rickshaw marker (for rickshaw drivers)
  static Future<BitmapDescriptor> getRickshawMarker({int width = 80}) => 
      loadMarker(rickshawMarker, width: width);

  /// Get driver marker based on vehicle type
  static Future<BitmapDescriptor> getDriverMarker(String vehicleType, {int width = 80}) {
    if (vehicleType.toLowerCase().contains('rickshaw') || 
        vehicleType.toLowerCase().contains('rikshaw')) {
      return getRickshawMarker(width: width);
    }
    return getCarMarker(width: width);
  }

  /// Clear the marker cache
  static void clearCache() => _cache.clear();
}
