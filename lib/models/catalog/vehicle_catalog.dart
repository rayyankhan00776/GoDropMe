/// Catalog for vehicles (cars or rikshaws): brands, models by brand, and colors.
/// Matches the schema of assets/json/car_details.json and rikshaw_details.json.
class VehicleCatalog {
  final List<String> vehicleBrands;
  final Map<String, List<String>> vehicleModels; // brand -> models
  final List<String> vehicleColors;

  const VehicleCatalog({
    required this.vehicleBrands,
    required this.vehicleModels,
    required this.vehicleColors,
  });

  factory VehicleCatalog.fromJson(Map<String, dynamic> json) {
    final brands =
        (json['vehicleBrands'] as List?)?.map((e) => e.toString()).toList() ??
        const <String>[];
    final colors =
        (json['vehicleColors'] as List?)?.map((e) => e.toString()).toList() ??
        const <String>[];
    final Map<String, List<String>> models = {};
    final rawModels = json['vehicleModels'];
    if (rawModels is Map) {
      rawModels.forEach((key, value) {
        if (value is List) {
          models[key.toString()] = value.map((e) => e.toString()).toList();
        }
      });
    }
    return VehicleCatalog(
      vehicleBrands: brands,
      vehicleModels: models,
      vehicleColors: colors,
    );
  }

  Map<String, dynamic> toJson() => {
    'vehicleBrands': vehicleBrands,
    'vehicleModels': vehicleModels,
    'vehicleColors': vehicleColors,
  };
}
