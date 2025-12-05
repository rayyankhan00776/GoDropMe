import 'package:godropme/models/enums/vehicle_type.dart';

/// Vehicle model matching Appwrite `vehicles` table schema.
/// Used for reading vehicle data from Appwrite.
class Vehicle {
  /// Appwrite document ID
  final String id;
  
  /// Reference to drivers table
  final String driverId;
  
  /// Vehicle type: car or rikshaw
  final VehicleType vehicleType;
  final String brand;
  final String model;
  final String color;
  final String productionYear;
  final String numberPlate;
  final int seatCapacity;
  
  // Photo URLs
  final String vehiclePhotoUrl;
  final String registrationFrontUrl;
  final String registrationBackUrl;
  
  /// Whether this vehicle is currently active
  final bool isActive;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const Vehicle({
    required this.id,
    required this.driverId,
    this.vehicleType = VehicleType.car,
    required this.brand,
    required this.model,
    required this.color,
    required this.productionYear,
    required this.numberPlate,
    required this.seatCapacity,
    required this.vehiclePhotoUrl,
    required this.registrationFrontUrl,
    required this.registrationBackUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Parse from Appwrite document/row
  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    id: json['\$id']?.toString() ?? json['id']?.toString() ?? '',
    driverId: json['driverId']?.toString() ?? '',
    vehicleType: VehicleTypeExt.fromString(json['vehicleType']?.toString()),
    brand: json['brand']?.toString() ?? '',
    model: json['model']?.toString() ?? '',
    color: json['color']?.toString() ?? '',
    productionYear: json['productionYear']?.toString() ?? '',
    numberPlate: json['numberPlate']?.toString() ?? '',
    seatCapacity: (json['seatCapacity'] as num?)?.toInt() ?? 0,
    vehiclePhotoUrl: json['vehiclePhotoUrl']?.toString() ?? '',
    registrationFrontUrl: json['registrationFrontUrl']?.toString() ?? '',
    registrationBackUrl: json['registrationBackUrl']?.toString() ?? '',
    isActive: json['isActive'] == true,
    createdAt: _parseDateTime(json['\$createdAt']) ?? DateTime.now(),
    updatedAt: _parseDateTime(json['\$updatedAt']) ?? DateTime.now(),
  );
  
  /// Convert to JSON (for local storage)
  Map<String, dynamic> toJson() => {
    '\$id': id,
    'driverId': driverId,
    'vehicleType': vehicleType.name,
    'brand': brand,
    'model': model,
    'color': color,
    'productionYear': productionYear,
    'numberPlate': numberPlate,
    'seatCapacity': seatCapacity,
    'vehiclePhotoUrl': vehiclePhotoUrl,
    'registrationFrontUrl': registrationFrontUrl,
    'registrationBackUrl': registrationBackUrl,
    'isActive': isActive,
    '\$createdAt': createdAt.toIso8601String(),
    '\$updatedAt': updatedAt.toIso8601String(),
  };
  
  /// Create a copy with updated fields
  Vehicle copyWith({
    String? id,
    String? driverId,
    VehicleType? vehicleType,
    String? brand,
    String? model,
    String? color,
    String? productionYear,
    String? numberPlate,
    int? seatCapacity,
    String? vehiclePhotoUrl,
    String? registrationFrontUrl,
    String? registrationBackUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Vehicle(
    id: id ?? this.id,
    driverId: driverId ?? this.driverId,
    vehicleType: vehicleType ?? this.vehicleType,
    brand: brand ?? this.brand,
    model: model ?? this.model,
    color: color ?? this.color,
    productionYear: productionYear ?? this.productionYear,
    numberPlate: numberPlate ?? this.numberPlate,
    seatCapacity: seatCapacity ?? this.seatCapacity,
    vehiclePhotoUrl: vehiclePhotoUrl ?? this.vehiclePhotoUrl,
    registrationFrontUrl: registrationFrontUrl ?? this.registrationFrontUrl,
    registrationBackUrl: registrationBackUrl ?? this.registrationBackUrl,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
  
  /// Display string for vehicle
  String get displayName => '$brand $model ($color)';
}
