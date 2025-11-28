import 'package:godropme/features/DriverSide/driverRegistration/models/vehicle_registration.dart';

/// Re-export VehicleType for backwards compatibility
export 'package:godropme/features/DriverSide/driverRegistration/models/vehicle_registration.dart' show VehicleType, VehicleTypeExt;

/// Simple wrapper for vehicle type selection step.
/// Uses VehicleType from vehicle_registration.dart.
class VehicleSelection {
  final VehicleType type;
  const VehicleSelection({required this.type});

  Map<String, dynamic> toJson() => {'type': type.name};
  
  factory VehicleSelection.fromJson(Map<String, dynamic> json) =>
      VehicleSelection(
        type: VehicleTypeExt.fromString((json['type'] ?? '').toString()),
      );
}
