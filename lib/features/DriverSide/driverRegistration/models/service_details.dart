import 'package:godropme/models/school.dart';

/// Service details using Appwrite-compatible flat data types.
/// 
/// Schools are stored as `schoolIds` (string[]) - foreign keys to schools table.
/// Use SchoolsLoader.getByIds() to get school details including names and locations.
class ServiceDetails {
  /// School IDs - foreign keys to schools table (Appwrite: string[])
  /// Use SchoolsLoader.getByIds() to get full school objects
  final List<String> schoolIds;
  
  /// Service category: 'Male', 'Female', or 'Both' - indicates gender of students driver serves
  final String? serviceCategory;
  /// Service area center as [lng, lat] (Appwrite: point)
  final List<double>? serviceAreaCenter;
  final double? serviceAreaRadiusKm; // radius in km (1-10)
  /// Service area polygon in Appwrite format: [[[lng, lat], [lng, lat], ...]]
  /// - 3D array: outer array holds linear rings
  /// - First ring is exterior boundary, additional rings are holes
  /// - Each ring must be closed (first point = last point)
  final List<List<List<double>>>? serviceAreaPolygon;
  final String? serviceAreaAddress; // human-readable address
  /// Monthly service price in PKR
  final int? monthlyPricePkr;
  final String? extraNotes;

  const ServiceDetails({
    required this.schoolIds,
    this.serviceCategory,
    this.serviceAreaCenter,
    this.serviceAreaRadiusKm,
    this.serviceAreaPolygon,
    this.serviceAreaAddress,
    this.monthlyPricePkr,
    this.extraNotes,
  });

  Map<String, dynamic> toJson() => {
    'schoolIds': schoolIds,
    'serviceCategory': serviceCategory,
    'serviceAreaCenter': serviceAreaCenter, // [lng, lat] for Appwrite point
    'serviceAreaRadiusKm': serviceAreaRadiusKm,
    'serviceAreaPolygon': serviceAreaPolygon, // [[[lng, lat], ...]] for Appwrite polygon
    'serviceAreaAddress': serviceAreaAddress,
    'monthlyPricePkr': monthlyPricePkr,
    'extraNotes': extraNotes,
  };

  factory ServiceDetails.fromJson(Map<String, dynamic> json) {
    // Parse school IDs (foreign keys to schools table)
    List<String> ids = [];
    final idsData = json['schoolIds'];
    if (idsData is List) {
      ids = idsData.map((e) => e.toString()).toList();
    }
    
    // Parse center point
    List<double>? center;
    final centerData = json['serviceAreaCenter'];
    if (centerData is List && centerData.length >= 2) {
      center = [(centerData[0] as num).toDouble(), (centerData[1] as num).toDouble()];
    } else if (centerData is Map<String, dynamic>) {
      // Legacy LatLngLite format
      final lat = (centerData['lat'] as num?)?.toDouble() ?? 0.0;
      final lng = (centerData['lng'] as num?)?.toDouble() ?? 0.0;
      center = [lng, lat];
    }
    
    // Parse polygon - Appwrite format: [[[lng, lat], ...]]
    List<List<List<double>>>? polygon;
    final polyData = json['serviceAreaPolygon'];
    if (polyData is List && polyData.isNotEmpty) {
      // Check if it's already 3D array format
      if (polyData.first is List && (polyData.first as List).isNotEmpty && (polyData.first as List).first is List) {
        // Already 3D format: [[[lng, lat], ...]]
        polygon = [];
        for (final ring in polyData) {
          if (ring is List) {
            final parsedRing = <List<double>>[];
            for (final p in ring) {
              if (p is List && p.length >= 2) {
                parsedRing.add([(p[0] as num).toDouble(), (p[1] as num).toDouble()]);
              }
            }
            if (parsedRing.isNotEmpty) polygon.add(parsedRing);
          }
        }
      } else {
        // Legacy 2D format: [[lng, lat], ...] - convert to 3D
        final ring = <List<double>>[];
        for (final p in polyData) {
          if (p is List && p.length >= 2) {
            ring.add([(p[0] as num).toDouble(), (p[1] as num).toDouble()]);
          } else if (p is Map<String, dynamic>) {
            // Legacy LatLngLite format
            final lat = (p['lat'] as num?)?.toDouble() ?? 0.0;
            final lng = (p['lng'] as num?)?.toDouble() ?? 0.0;
            ring.add([lng, lat]);
          }
        }
        if (ring.isNotEmpty) polygon = [ring];
      }
    }
    
    return ServiceDetails(
      schoolIds: ids,
      serviceCategory: json['serviceCategory']?.toString(),
      serviceAreaCenter: center,
      serviceAreaRadiusKm: json['serviceAreaRadiusKm'] != null 
          ? (json['serviceAreaRadiusKm'] as num).toDouble() 
          : null,
      serviceAreaPolygon: polygon,
      serviceAreaAddress: json['serviceAreaAddress']?.toString(),
      monthlyPricePkr: (json['monthlyPricePkr'] as num?)?.toInt(),
      extraNotes: json['extraNotes']?.toString(),
    );
  }
  
  /// Convert to Appwrite document format for driver_services collection.
  Map<String, dynamic> toAppwriteJson() => {
    'schoolIds': schoolIds,
    'serviceCategory': serviceCategory,
    'serviceAreaCenter': serviceAreaCenter, // [lng, lat] for Appwrite point
    'serviceAreaRadiusKm': serviceAreaRadiusKm,
    'serviceAreaPolygon': serviceAreaPolygon, // [[[lng, lat], ...]] for Appwrite polygon
    if (serviceAreaAddress != null) 'serviceAreaAddress': serviceAreaAddress,
    'monthlyPricePkr': monthlyPricePkr,
    if (extraNotes != null) 'extraNotes': extraNotes,
  };
  
  /// Create a copy with updated fields
  ServiceDetails copyWith({
    List<String>? schoolIds,
    String? serviceCategory,
    List<double>? serviceAreaCenter,
    double? serviceAreaRadiusKm,
    List<List<List<double>>>? serviceAreaPolygon,
    String? serviceAreaAddress,
    int? monthlyPricePkr,
    String? extraNotes,
  }) => ServiceDetails(
    schoolIds: schoolIds ?? this.schoolIds,
    serviceCategory: serviceCategory ?? this.serviceCategory,
    serviceAreaCenter: serviceAreaCenter ?? this.serviceAreaCenter,
    serviceAreaRadiusKm: serviceAreaRadiusKm ?? this.serviceAreaRadiusKm,
    serviceAreaPolygon: serviceAreaPolygon ?? this.serviceAreaPolygon,
    serviceAreaAddress: serviceAreaAddress ?? this.serviceAreaAddress,
    monthlyPricePkr: monthlyPricePkr ?? this.monthlyPricePkr,
    extraNotes: extraNotes ?? this.extraNotes,
  );
  
  /// Create from School objects (convenience factory for form submission)
  factory ServiceDetails.fromSchools({
    required List<School> schools,
    String? serviceCategory,
    LatLng? serviceAreaCenter,
    double? serviceAreaRadiusKm,
    List<LatLng>? serviceAreaPolygon,
    String? serviceAreaAddress,
    int? monthlyPricePkr,
    String? extraNotes,
  }) {
    // Convert polygon to Appwrite 3D format and close the ring
    List<List<List<double>>>? polygon;
    if (serviceAreaPolygon != null && serviceAreaPolygon.isNotEmpty) {
      final ring = serviceAreaPolygon.map((p) => [p.longitude, p.latitude]).toList();
      // Close the ring if not already closed
      if (ring.first[0] != ring.last[0] || ring.first[1] != ring.last[1]) {
        ring.add(List<double>.from(ring.first));
      }
      polygon = [ring];
    }
    
    return ServiceDetails(
      schoolIds: schools.map((s) => s.id).toList(), // Store IDs only
      serviceCategory: serviceCategory,
      serviceAreaCenter: serviceAreaCenter != null 
          ? [serviceAreaCenter.longitude, serviceAreaCenter.latitude] 
          : null,
      serviceAreaRadiusKm: serviceAreaRadiusKm,
      serviceAreaPolygon: polygon,
      serviceAreaAddress: serviceAreaAddress,
      monthlyPricePkr: monthlyPricePkr,
      extraNotes: extraNotes,
    );
  }
}

/// Alias for google_maps LatLng to avoid import in model
class LatLng {
  final double latitude;
  final double longitude;
  const LatLng(this.latitude, this.longitude);
}
