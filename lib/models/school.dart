import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Represents a school with its ID, name and geographic location.
/// 
/// Data comes from Appwrite `schools` table.
/// Use SchoolsLoader to fetch schools.
class School {
  /// Appwrite document ID (schools.$id)
  final String id;
  final String name;
  final double lat;
  final double lng;
  /// City where school is located
  final String? city;
  /// Whether school is active (visible in app)
  final bool isActive;

  const School({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    this.city,
    this.isActive = true,
  });

  /// Create from Appwrite row data
  factory School.fromJson(Map<String, dynamic> json) {
    // Get ID from Appwrite document
    final id = json['\$id']?.toString() ?? json['id']?.toString() ?? '';
    
    // Check for Appwrite point format [lng, lat]
    final location = json['location'];
    if (location is List && location.length >= 2) {
      return School(
        id: id,
        name: json['name'] as String? ?? '',
        lng: (location[0] as num).toDouble(),
        lat: (location[1] as num).toDouble(),
        city: json['city']?.toString(),
        isActive: json['isActive'] ?? true,
      );
    }
    // Legacy format with separate lat/lng fields
    return School(
      id: id,
      name: json['name'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      city: json['city']?.toString(),
      isActive: json['isActive'] ?? true,
    );
  }

  /// Convert to JSON map (Appwrite point format: [lng, lat])
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': [lng, lat], // [lng, lat] for Appwrite point type
        if (city != null) 'city': city,
        'isActive': isActive,
      };

  /// Get as LatLng for Google Maps
  LatLng get latLng => LatLng(lat, lng);

  /// Get location as [lng, lat] array (Appwrite point format)
  List<double> get locationPoint => [lng, lat];

  /// Check if coordinates are valid (not 0,0)
  bool get hasValidCoordinates => lat != 0.0 && lng != 0.0;

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is School &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
