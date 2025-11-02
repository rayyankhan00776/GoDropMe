class DriverLicence {
  final String licenceNumber;

  /// Expiry in ISO or display string (DD-MM-YYYY as used in UI); keep as string to avoid parsing concerns here.
  final String expiry;
  final String? licencePhotoPath;
  final String? selfieWithLicencePath;

  const DriverLicence({
    required this.licenceNumber,
    required this.expiry,
    this.licencePhotoPath,
    this.selfieWithLicencePath,
  });

  Map<String, dynamic> toJson() => {
    'licenceNumber': licenceNumber,
    'expiry': expiry,
    'licencePhotoPath': licencePhotoPath,
    'selfieWithLicencePath': selfieWithLicencePath,
  };

  factory DriverLicence.fromJson(Map<String, dynamic> json) => DriverLicence(
    licenceNumber: (json['licenceNumber'] ?? '').toString(),
    expiry: (json['expiry'] ?? '').toString(),
    licencePhotoPath: json['licencePhotoPath']?.toString(),
    selfieWithLicencePath: json['selfieWithLicencePath']?.toString(),
  );
}
