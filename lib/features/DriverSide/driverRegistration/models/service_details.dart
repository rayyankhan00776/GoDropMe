import 'package:godropme/models/value_objects.dart';

class ServiceDetails {
  final List<String> schoolNames;
  final String
  dutyType; // as provided by options (e.g., Morning, Evening, Both)
  final String pickupRangeKm; // e.g., "1–3"
  final List<String> operatingDays; // stored as labels to match UI for now
  final LatLngLite? routeStartPoint; // optional picked point
  final String? extraNotes;
  final bool isActive;

  const ServiceDetails({
    required this.schoolNames,
    required this.dutyType,
    required this.pickupRangeKm,
    required this.operatingDays,
    this.routeStartPoint,
    this.extraNotes,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'schoolNames': schoolNames,
    'dutyType': dutyType,
    'pickupRangeKm': pickupRangeKm,
    'operatingDays': operatingDays,
    'routeStartPoint': routeStartPoint?.toJson(),
    'extraNotes': extraNotes,
    'isActive': isActive,
  };

  factory ServiceDetails.fromJson(Map<String, dynamic> json) => ServiceDetails(
    schoolNames:
        (json['schoolNames'] as List?)?.map((e) => e.toString()).toList() ??
        const <String>[],
    dutyType: (json['dutyType'] ?? '').toString(),
    pickupRangeKm: (json['pickupRangeKm'] ?? '').toString(),
    operatingDays:
        (json['operatingDays'] as List?)?.map((e) => e.toString()).toList() ??
        const <String>[],
    routeStartPoint: json['routeStartPoint'] is Map<String, dynamic>
        ? LatLngLite.fromJson(json['routeStartPoint'] as Map<String, dynamic>)
        : null,
    extraNotes: json['extraNotes']?.toString(),
    isActive: json['isActive'] == true,
  );
}
