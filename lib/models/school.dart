import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Represents a school with its name and geographic location.
/// 
/// This is a pure data class - actual school data comes from:
/// - assets/json/schools.json (centralized, used by both parent and driver sides)
class School {
  final String name;
  final double lat;
  final double lng;

  const School({
    required this.name,
    required this.lat,
    required this.lng,
  });

  /// Create from JSON map (supports both asset format and Appwrite format)
  factory School.fromJson(Map<String, dynamic> json) {
    // Check for Appwrite point format [lng, lat]
    final location = json['location'];
    if (location is List && location.length >= 2) {
      return School(
        name: json['name'] as String? ?? '',
        lng: (location[0] as num).toDouble(),
        lat: (location[1] as num).toDouble(),
      );
    }
    // Legacy format with separate lat/lng fields
    return School(
      name: json['name'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert to JSON map (Appwrite point format: [lng, lat])
  Map<String, dynamic> toJson() => {
        'name': name,
        'location': [lng, lat], // [lng, lat] for Appwrite point type
      };

  /// Convert to legacy JSON format (for local asset compatibility)
  Map<String, dynamic> toLegacyJson() => {
        'name': name,
        'lat': lat,
        'lng': lng,
      };

  /// Get as LatLng for Google Maps
  LatLng get latLng => LatLng(lat, lng);

  /// Check if coordinates are valid (not 0,0)
  bool get hasValidCoordinates => lat != 0.0 && lng != 0.0;

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is School &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}
