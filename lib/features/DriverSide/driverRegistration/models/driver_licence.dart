class DriverLicence {
  final String licenceNumber;

  /// Expiry in ISO or display string (DD-MM-YYYY as used in UI); keep as string to avoid parsing concerns here.
  final String licenseExpiry;
  
  /// Local file paths (for form capture, before upload)
  final String? licencePhotoPath;
  final String? selfieWithLicencePath;
  
  /// Appwrite Storage URLs (after upload)
  final String? licensePhotoUrl;
  final String? selfieWithLicenseUrl;

  const DriverLicence({
    required this.licenceNumber,
    required this.licenseExpiry,
    this.licencePhotoPath,
    this.selfieWithLicencePath,
    this.licensePhotoUrl,
    this.selfieWithLicenseUrl,
  });

  Map<String, dynamic> toJson() => {
    'licenceNumber': licenceNumber,
    'licenseExpiry': licenseExpiry,
    'licencePhotoPath': licencePhotoPath,
    'selfieWithLicencePath': selfieWithLicencePath,
    'licensePhotoUrl': licensePhotoUrl,
    'selfieWithLicenseUrl': selfieWithLicenseUrl,
  };
  
  /// Convert to Appwrite document format (excludes local paths, uses Appwrite column names)
  Map<String, dynamic> toAppwriteJson() => {
    'licenseNumber': licenceNumber, // Appwrite uses American spelling 'license'
    'licenseExpiry': _toIsoDate(licenseExpiry),
    if (licensePhotoUrl != null) 'licensePhotoUrl': licensePhotoUrl,
    if (selfieWithLicenseUrl != null) 'selfieWithLicenseUrl': selfieWithLicenseUrl,
  };
  
  /// Convert DD-MM-YYYY to ISO 8601 datetime string for Appwrite
  static String? _toIsoDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day).toIso8601String();
      }
    } catch (_) {}
    return dateStr; // Return as-is if already in correct format
  }

  factory DriverLicence.fromJson(Map<String, dynamic> json) => DriverLicence(
    // Support both local 'licenceNumber' and Appwrite 'licenseNumber'
    licenceNumber: (json['licenceNumber'] ?? json['licenseNumber'] ?? '').toString(),
    // Support both local 'expiry'/'licenseExpiry' and Appwrite 'licenseExpiry'
    licenseExpiry: (json['licenseExpiry'] ?? json['expiry'] ?? '').toString(),
    licencePhotoPath: json['licencePhotoPath']?.toString(),
    selfieWithLicencePath: json['selfieWithLicencePath']?.toString(),
    licensePhotoUrl: json['licensePhotoUrl']?.toString(),
    selfieWithLicenseUrl: json['selfieWithLicenseUrl']?.toString(),
  );
  
  /// Create a copy with updated fields
  DriverLicence copyWith({
    String? licenceNumber,
    String? licenseExpiry,
    String? licencePhotoPath,
    String? selfieWithLicencePath,
    String? licensePhotoUrl,
    String? selfieWithLicenseUrl,
  }) => DriverLicence(
    licenceNumber: licenceNumber ?? this.licenceNumber,
    licenseExpiry: licenseExpiry ?? this.licenseExpiry,
    licencePhotoPath: licencePhotoPath ?? this.licencePhotoPath,
    selfieWithLicencePath: selfieWithLicencePath ?? this.selfieWithLicencePath,
    licensePhotoUrl: licensePhotoUrl ?? this.licensePhotoUrl,
    selfieWithLicenseUrl: selfieWithLicenseUrl ?? this.selfieWithLicenseUrl,
  );
}
