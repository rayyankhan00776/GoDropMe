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
  
  /// Appwrite Storage URLs (after upload)
  final String? vehiclePhotoUrl;
  final String? registrationFrontUrl;
  final String? registrationBackUrl;
  
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
    this.vehiclePhotoUrl,
    this.registrationFrontUrl,
    this.registrationBackUrl,
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
    'vehiclePhotoUrl': vehiclePhotoUrl,
    'registrationFrontUrl': registrationFrontUrl,
    'registrationBackUrl': registrationBackUrl,
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
    if (vehiclePhotoUrl != null) 'vehiclePhotoUrl': vehiclePhotoUrl,
    if (registrationFrontUrl != null) 'registrationFrontUrl': registrationFrontUrl,
    if (registrationBackUrl != null) 'registrationBackUrl': registrationBackUrl,
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
        // Support both new Url fields and legacy FileId fields
        vehiclePhotoUrl: json['vehiclePhotoUrl']?.toString() ?? json['vehiclePhotoFileId']?.toString(),
        registrationFrontUrl: json['registrationFrontUrl']?.toString() ?? json['registrationFrontFileId']?.toString(),
        registrationBackUrl: json['registrationBackUrl']?.toString() ?? json['registrationBackFileId']?.toString(),
        isActive: json['isActive'] == true || json['isActive'] == null,
      );
  
  /// Create a copy with updated fields
  VehicleRegistration copyWith({
    VehicleType? vehicleType,
    String? brand,
    String? model,
    String? color,
    String? productionYear,
    String? numberPlate,
    int? seatCapacity,
    String? vehiclePhotoPath,
    String? certificateFrontPath,
    String? certificateBackPath,
    String? vehiclePhotoUrl,
    String? registrationFrontUrl,
    String? registrationBackUrl,
    bool? isActive,
  }) => VehicleRegistration(
    vehicleType: vehicleType ?? this.vehicleType,
    brand: brand ?? this.brand,
    model: model ?? this.model,
    color: color ?? this.color,
    productionYear: productionYear ?? this.productionYear,
    numberPlate: numberPlate ?? this.numberPlate,
    seatCapacity: seatCapacity ?? this.seatCapacity,
    vehiclePhotoPath: vehiclePhotoPath ?? this.vehiclePhotoPath,
    certificateFrontPath: certificateFrontPath ?? this.certificateFrontPath,
    certificateBackPath: certificateBackPath ?? this.certificateBackPath,
    vehiclePhotoUrl: vehiclePhotoUrl ?? this.vehiclePhotoUrl,
    registrationFrontUrl: registrationFrontUrl ?? this.registrationFrontUrl,
    registrationBackUrl: registrationBackUrl ?? this.registrationBackUrl,
    isActive: isActive ?? this.isActive,
  );
}
