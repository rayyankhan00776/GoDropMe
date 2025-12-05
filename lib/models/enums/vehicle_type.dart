/// Vehicle types matching Appwrite `vehicles.vehicleType` enum
enum VehicleType {
  car,
  rikshaw,
}

extension VehicleTypeExt on VehicleType {
  String get name => switch (this) {
    VehicleType.car => 'car',
    VehicleType.rikshaw => 'rikshaw',
  };
  
  String get displayName => switch (this) {
    VehicleType.car => 'Car',
    VehicleType.rikshaw => 'Rikshaw',
  };
  
  static VehicleType fromString(String? s) {
    if (s == null) return VehicleType.car;
    switch (s.toLowerCase()) {
      case 'rikshaw': return VehicleType.rikshaw;
      default: return VehicleType.car;
    }
  }
}
