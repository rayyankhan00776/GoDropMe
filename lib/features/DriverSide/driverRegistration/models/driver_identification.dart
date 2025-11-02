class DriverIdentification {
  /// 13-digit CNIC number (digits only) as string.
  final String cnicNumber;
  final String? idFrontPhotoPath;
  final String? idBackPhotoPath;

  const DriverIdentification({
    required this.cnicNumber,
    this.expiryDate,
    this.idFrontPhotoPath,
    this.idBackPhotoPath,
  });

  /// Expiry date string as entered (DD-MM-YYYY) to match current UI.
  final String? expiryDate;

  Map<String, dynamic> toJson() => {
    'cnicNumber': cnicNumber,
    'expiryDate': expiryDate,
    'idFrontPhotoPath': idFrontPhotoPath,
    'idBackPhotoPath': idBackPhotoPath,
  };

  factory DriverIdentification.fromJson(Map<String, dynamic> json) =>
      DriverIdentification(
        cnicNumber: (json['cnicNumber'] ?? '').toString(),
        expiryDate: json['expiryDate']?.toString(),
        idFrontPhotoPath: json['idFrontPhotoPath']?.toString(),
        idBackPhotoPath: json['idBackPhotoPath']?.toString(),
      );
}
