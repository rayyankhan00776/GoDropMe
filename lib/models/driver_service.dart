/// Driver service model matching Appwrite `driver_services` table schema.
/// Used for reading driver service area data from Appwrite.
class DriverService {
  /// Appwrite document ID
  final String id;
  
  /// Reference to drivers table
  final String driverId;
  
  /// Schools this driver services - IDs referencing schools table
  /// Use SchoolsLoader.getByIds() to get full school details
  final List<String> schoolIds;
  
  /// Service category: 'Male', 'Female', or 'Both'
  final String serviceCategory;
  
  /// Service area center as [lng, lat]
  final List<double> serviceAreaCenter;
  
  /// Service area radius in km
  final double serviceAreaRadiusKm;
  
  /// Service area polygon in Appwrite format: [[[lng, lat], ...]]
  final List<List<List<double>>> serviceAreaPolygon;
  
  /// Human-readable address
  final String? serviceAreaAddress;
  
  /// Monthly service price in PKR
  final int monthlyPricePkr;
  
  /// Extra notes/description
  final String? extraNotes;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const DriverService({
    required this.id,
    required this.driverId,
    required this.schoolIds,
    required this.serviceCategory,
    required this.serviceAreaCenter,
    required this.serviceAreaRadiusKm,
    required this.serviceAreaPolygon,
    this.serviceAreaAddress,
    required this.monthlyPricePkr,
    this.extraNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Parse from Appwrite document/row
  factory DriverService.fromJson(Map<String, dynamic> json) {
    // Parse school IDs (foreign keys to schools table)
    List<String> schoolIds = [];
    final idsData = json['schoolIds'];
    if (idsData is List) {
      schoolIds = idsData.map((e) => e.toString()).toList();
    }
    
    // Parse center point [lng, lat]
    List<double> center = [0, 0];
    final centerData = json['serviceAreaCenter'];
    if (centerData is List && centerData.length >= 2) {
      center = [(centerData[0] as num).toDouble(), (centerData[1] as num).toDouble()];
    }
    
    // Parse polygon [[[lng, lat], ...]]
    List<List<List<double>>> polygon = [];
    final polyData = json['serviceAreaPolygon'];
    if (polyData is List && polyData.isNotEmpty) {
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
    }
    
    return DriverService(
      id: json['\$id']?.toString() ?? json['id']?.toString() ?? '',
      driverId: json['driverId']?.toString() ?? '',
      schoolIds: schoolIds,
      serviceCategory: json['serviceCategory']?.toString() ?? 'Both',
      serviceAreaCenter: center,
      serviceAreaRadiusKm: (json['serviceAreaRadiusKm'] as num?)?.toDouble() ?? 1.0,
      serviceAreaPolygon: polygon,
      serviceAreaAddress: json['serviceAreaAddress']?.toString(),
      monthlyPricePkr: (json['monthlyPricePkr'] as num?)?.toInt() ?? 0,
      extraNotes: json['extraNotes']?.toString(),
      createdAt: _parseDateTime(json['\$createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['\$updatedAt']) ?? DateTime.now(),
    );
  }
  
  /// Convert to JSON (for local storage)
  Map<String, dynamic> toJson() => {
    '\$id': id,
    'driverId': driverId,
    'schoolIds': schoolIds,
    'serviceCategory': serviceCategory,
    'serviceAreaCenter': serviceAreaCenter,
    'serviceAreaRadiusKm': serviceAreaRadiusKm,
    'serviceAreaPolygon': serviceAreaPolygon,
    'serviceAreaAddress': serviceAreaAddress,
    'monthlyPricePkr': monthlyPricePkr,
    'extraNotes': extraNotes,
    '\$createdAt': createdAt.toIso8601String(),
    '\$updatedAt': updatedAt.toIso8601String(),
  };
  
  /// Create a copy with updated fields
  DriverService copyWith({
    String? id,
    String? driverId,
    List<String>? schoolIds,
    String? serviceCategory,
    List<double>? serviceAreaCenter,
    double? serviceAreaRadiusKm,
    List<List<List<double>>>? serviceAreaPolygon,
    String? serviceAreaAddress,
    int? monthlyPricePkr,
    String? extraNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DriverService(
    id: id ?? this.id,
    driverId: driverId ?? this.driverId,
    schoolIds: schoolIds ?? this.schoolIds,
    serviceCategory: serviceCategory ?? this.serviceCategory,
    serviceAreaCenter: serviceAreaCenter ?? this.serviceAreaCenter,
    serviceAreaRadiusKm: serviceAreaRadiusKm ?? this.serviceAreaRadiusKm,
    serviceAreaPolygon: serviceAreaPolygon ?? this.serviceAreaPolygon,
    serviceAreaAddress: serviceAreaAddress ?? this.serviceAreaAddress,
    monthlyPricePkr: monthlyPricePkr ?? this.monthlyPricePkr,
    extraNotes: extraNotes ?? this.extraNotes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
  
  /// Get center as LatLng-like object
  ({double lat, double lng}) get centerLatLng => (
    lat: serviceAreaCenter.length >= 2 ? serviceAreaCenter[1] : 0,
    lng: serviceAreaCenter.length >= 2 ? serviceAreaCenter[0] : 0,
  );
  
  /// Check if a point is within the service area (basic check using radius)
  bool containsPoint(double lat, double lng) {
    final center = centerLatLng;
    // Simple distance check (not accounting for Earth curvature - fine for small areas)
    final latDiff = (lat - center.lat).abs();
    final lngDiff = (lng - center.lng).abs();
    // Rough conversion: 1 degree ≈ 111km
    final distKm = _sqrt(latDiff * latDiff + lngDiff * lngDiff) * 111;
    return distKm <= serviceAreaRadiusKm;
  }
  
  // Simple sqrt without importing dart:math
  static double _sqrt(double value) {
    if (value <= 0) return 0;
    double guess = value / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + value / guess) / 2;
    }
    return guess;
  }
}
