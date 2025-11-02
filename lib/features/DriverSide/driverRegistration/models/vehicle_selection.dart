enum VehicleType { car, rikshaw }

extension VehicleTypeCodec on VehicleType {
  String get label => this == VehicleType.car ? 'Car' : 'Rikshaw';
  static VehicleType parse(String s) {
    final v = s.toLowerCase();
    if (v.contains('car')) return VehicleType.car;
    return VehicleType.rikshaw;
  }
}

class VehicleSelection {
  final VehicleType type;
  const VehicleSelection({required this.type});

  Map<String, dynamic> toJson() => {'type': type.name};
  factory VehicleSelection.fromJson(Map<String, dynamic> json) =>
      VehicleSelection(
        type: VehicleTypeCodec.parse((json['type'] ?? '').toString()),
      );
}
