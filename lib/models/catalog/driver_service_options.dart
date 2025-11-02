/// Options used by the Driver Service Details form (assets/json/driver_details.json).
class DriverServiceOptions {
  final List<String> schoolNames;
  final List<String> dutyTypes; // e.g., Morning, Evening, Both
  final List<String> operatingDays; // e.g., Mon–Fri, Mon–Sat
  final List<String> pickupRangeKmOptions; // e.g., 1–3, 3–5

  const DriverServiceOptions({
    required this.schoolNames,
    required this.dutyTypes,
    required this.operatingDays,
    required this.pickupRangeKmOptions,
  });

  factory DriverServiceOptions.fromJson(Map<String, dynamic> json) {
    final root = json['serviceOptions'] as Map? ?? const {};
    return DriverServiceOptions(
      schoolNames:
          (root['schoolNames'] as List?)?.map((e) => e.toString()).toList() ??
          const <String>[],
      dutyTypes:
          (root['dutyTypes'] as List?)?.map((e) => e.toString()).toList() ??
          const <String>[],
      operatingDays:
          (root['operatingDays'] as List?)?.map((e) => e.toString()).toList() ??
          const <String>[],
      pickupRangeKmOptions:
          (root['pickupRangeKmOptions'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[],
    );
  }

  Map<String, dynamic> toJson() => {
    'serviceOptions': {
      'schoolNames': schoolNames,
      'dutyTypes': dutyTypes,
      'operatingDays': operatingDays,
      'pickupRangeKmOptions': pickupRangeKmOptions,
    },
  };
}
