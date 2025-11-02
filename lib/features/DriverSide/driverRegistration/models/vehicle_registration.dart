class VehicleRegistration {
  final String brand;
  final String model;
  final String color;
  final String productionYear; // keep as string to align with input validator
  final String numberPlate;
  final int seatCapacity;

  final String? vehiclePhotoPath;
  final String? certificateFrontPath;
  final String? certificateBackPath;

  const VehicleRegistration({
    required this.brand,
    required this.model,
    required this.color,
    required this.productionYear,
    required this.numberPlate,
    required this.seatCapacity,
    this.vehiclePhotoPath,
    this.certificateFrontPath,
    this.certificateBackPath,
  });

  Map<String, dynamic> toJson() => {
    'brand': brand,
    'model': model,
    'color': color,
    'productionYear': productionYear,
    'numberPlate': numberPlate,
    'seatCapacity': seatCapacity,
    'vehiclePhotoPath': vehiclePhotoPath,
    'certificateFrontPath': certificateFrontPath,
    'certificateBackPath': certificateBackPath,
  };

  factory VehicleRegistration.fromJson(Map<String, dynamic> json) =>
      VehicleRegistration(
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
      );
}
