import 'package:godropme/models/enums/vehicle_type.dart';

// Re-export VehicleType for backwards compatibility
export 'package:godropme/models/enums/vehicle_type.dart';

/// Vehicle registration model matching Appwrite `vehicles` collection.
class VehicleRegistration {
  /// Vehicle type: car or rikshaw
  final VehicleType vehicleType;
  final String brand;
  final String model;
  final String color;
  final String productionYear; // keep as string to align with input validator
  final String numberPlate;
  final int seatCapacity;

  /// Local file paths (for form capture, before upload)
  final String? vehiclePhotoPath;
  final String? certificateFrontPath;
  final String? certificateBackPath;
  
  /// Appwrite Storage file IDs (after upload)
  final String? vehiclePhotoFileId;
  final String? registrationFrontFileId;
  final String? registrationBackFileId;
  
  /// Whether this vehicle is currently active
  final bool isActive;

  const VehicleRegistration({
    this.vehicleType = VehicleType.car,
    required this.brand,
    required this.model,
    required this.color,
    required this.productionYear,
    required this.numberPlate,
    required this.seatCapacity,
    this.vehiclePhotoPath,
    this.certificateFrontPath,
    this.certificateBackPath,
    this.vehiclePhotoFileId,
    this.registrationFrontFileId,
    this.registrationBackFileId,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'vehicleType': vehicleType.name,
    'brand': brand,
    'model': model,
    'color': color,
    'productionYear': productionYear,
    'numberPlate': numberPlate,
    'seatCapacity': seatCapacity,
    'vehiclePhotoPath': vehiclePhotoPath,
    'certificateFrontPath': certificateFrontPath,
    'certificateBackPath': certificateBackPath,
    'vehiclePhotoFileId': vehiclePhotoFileId,
    'registrationFrontFileId': registrationFrontFileId,
    'registrationBackFileId': registrationBackFileId,
    'isActive': isActive,
  };
  
  /// Convert to Appwrite document format (excludes local paths)
  Map<String, dynamic> toAppwriteJson() => {
    'vehicleType': vehicleType.name,
    'brand': brand,
    'model': model,
    'color': color,
    'productionYear': productionYear,
    'numberPlate': numberPlate,
    'seatCapacity': seatCapacity,
    'vehiclePhotoFileId': vehiclePhotoFileId,
    'registrationFrontFileId': registrationFrontFileId,
    'registrationBackFileId': registrationBackFileId,
    'isActive': isActive,
  };

  factory VehicleRegistration.fromJson(Map<String, dynamic> json) =>
      VehicleRegistration(
        vehicleType: VehicleTypeExt.fromString(json['vehicleType']?.toString()),
        brand: (json['brand'] ?? '').toString(),
        model: (json['model'] ?? '').toString(),
        color: (json['color'] ?? '').toString(),
        productionYear: (json['productionYear'] ?? '').toString(),
        numberPlate: (json['numberPlate'] ?? '').toString(),
        seatCapacity: (json['seatCapacity'] is num)
            ? (json['seatCapacity'] as num).toInt()
            : int.tryParse('${json['seatCapacity']}') ?? 0,
        vehiclePhotoPath: json['vehiclePhotoPath']?.toString(),
        certificateFrontPath: json['certificateFrontPath']?.toString(),
        certificateBackPath: json['certificateBackPath']?.toString(),
        vehiclePhotoFileId: json['vehiclePhotoFileId']?.toString(),
        registrationFrontFileId: json['registrationFrontFileId']?.toString(),
        registrationBackFileId: json['registrationBackFileId']?.toString(),
        isActive: json['isActive'] == true || json['isActive'] == null,
      );
}
