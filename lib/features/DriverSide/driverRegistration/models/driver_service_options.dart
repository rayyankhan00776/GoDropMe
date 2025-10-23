class DriverServiceOptions {
  final List<String> schools;
  final List<String> dutyTypes;
  final List<String> operatingDays;
  final List<String> pickupRangeKmOptions;

  const DriverServiceOptions({
    required this.schools,
    required this.dutyTypes,
    required this.operatingDays,
    required this.pickupRangeKmOptions,
  });

  factory DriverServiceOptions.fallback() => const DriverServiceOptions(
    schools: [],
    dutyTypes: ['Morning', 'Evening', 'Both'],
    operatingDays: ['Mon–Fri', 'Mon–Sat'],
    pickupRangeKmOptions: ['1–3', '3–5', '5–8', '8–10'],
  );
}
