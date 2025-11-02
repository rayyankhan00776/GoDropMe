class DriverName {
  final String fullName;
  const DriverName({required this.fullName});

  Map<String, dynamic> toJson() => {'fullName': fullName};
  factory DriverName.fromJson(Map<String, dynamic> json) =>
      DriverName(fullName: (json['fullName'] ?? '').toString());
}
