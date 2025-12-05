import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Model for child pickup data - will be replaced with backend model
class ChildPickup {
  final String id;
  final String name;
  final LatLng homeLocation;
  final LatLng schoolLocation;
  final String schoolName;

  const ChildPickup({
    required this.id,
    required this.name,
    required this.homeLocation,
    required this.schoolLocation,
    required this.schoolName,
  });

  /// Convert to JSON for backend storage (Appwrite format)
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'pickLocation': [homeLocation.longitude, homeLocation.latitude], // [lng, lat] for Appwrite point
    'schoolLocation': [schoolLocation.longitude, schoolLocation.latitude], // [lng, lat] for Appwrite point
    'schoolName': schoolName,
  };

  /// Factory to create from backend JSON (Appwrite format)
  factory ChildPickup.fromJson(Map<String, dynamic> json) {
    // Parse home location from [lng, lat] point
    final homeLoc = json['pickLocation'] as List?;
    final homeLatLng = homeLoc != null && homeLoc.length >= 2
        ? LatLng((homeLoc[1] as num).toDouble(), (homeLoc[0] as num).toDouble())
        : const LatLng(0, 0);

    // Parse school location from [lng, lat] point
    final schoolLoc = json['schoolLocation'] as List?;
    final schoolLatLng = schoolLoc != null && schoolLoc.length >= 2
        ? LatLng((schoolLoc[1] as num).toDouble(), (schoolLoc[0] as num).toDouble())
        : const LatLng(0, 0);

    return ChildPickup(
      id: json['\$id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      homeLocation: homeLatLng,
      schoolLocation: schoolLatLng,
      schoolName: json['schoolName']?.toString() ?? '',
    );
  }
}