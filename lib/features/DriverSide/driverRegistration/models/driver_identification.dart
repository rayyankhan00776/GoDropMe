class DriverIdentification {
  /// 13-digit CNIC number (digits only) as string.
  final String cnicNumber;
  
  /// Local file paths (for form capture, before upload)
  final String? idFrontPhotoPath;
  final String? idBackPhotoPath;
  
  /// Appwrite Storage URLs (after upload)
  final String? cnicFrontUrl;
  final String? cnicBackUrl;

  const DriverIdentification({
    required this.cnicNumber,
    this.cnicExpiry,
    this.idFrontPhotoPath,
    this.idBackPhotoPath,
    this.cnicFrontUrl,
    this.cnicBackUrl,
  });

  /// Expiry date string as entered (DD-MM-YYYY) to match current UI.
  /// For Appwrite, this should be converted to ISO 8601 datetime.
  final String? cnicExpiry;

  Map<String, dynamic> toJson() => {
    'cnicNumber': cnicNumber,
    'cnicExpiry': cnicExpiry,
    'idFrontPhotoPath': idFrontPhotoPath,
    'idBackPhotoPath': idBackPhotoPath,
    'cnicFrontUrl': cnicFrontUrl,
    'cnicBackUrl': cnicBackUrl,
  };
  
  /// Convert to Appwrite document format (excludes local paths)
  Map<String, dynamic> toAppwriteJson() => {
    'cnicNumber': cnicNumber,
    if (cnicExpiry != null) 'cnicExpiry': _toIsoDate(cnicExpiry!),
    if (cnicFrontUrl != null) 'cnicFrontUrl': cnicFrontUrl,
    if (cnicBackUrl != null) 'cnicBackUrl': cnicBackUrl,
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
    return null;
  }

  factory DriverIdentification.fromJson(Map<String, dynamic> json) =>
      DriverIdentification(
        cnicNumber: (json['cnicNumber'] ?? '').toString(),
        // Support both local 'expiryDate' (legacy) and Appwrite 'cnicExpiry'
        cnicExpiry: json['cnicExpiry']?.toString() ?? json['expiryDate']?.toString(),
        idFrontPhotoPath: json['idFrontPhotoPath']?.toString(),
        idBackPhotoPath: json['idBackPhotoPath']?.toString(),
        cnicFrontUrl: json['cnicFrontUrl']?.toString(),
        cnicBackUrl: json['cnicBackUrl']?.toString(),
      );
  
  /// Create a copy with updated fields
  DriverIdentification copyWith({
    String? cnicNumber,
    String? cnicExpiry,
    String? idFrontPhotoPath,
    String? idBackPhotoPath,
    String? cnicFrontUrl,
    String? cnicBackUrl,
  }) => DriverIdentification(
    cnicNumber: cnicNumber ?? this.cnicNumber,
    cnicExpiry: cnicExpiry ?? this.cnicExpiry,
    idFrontPhotoPath: idFrontPhotoPath ?? this.idFrontPhotoPath,
    idBackPhotoPath: idBackPhotoPath ?? this.idBackPhotoPath,
    cnicFrontUrl: cnicFrontUrl ?? this.cnicFrontUrl,
    cnicBackUrl: cnicBackUrl ?? this.cnicBackUrl,
  );
}
