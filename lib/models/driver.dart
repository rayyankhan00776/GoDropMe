/// Unified Driver model matching Appwrite `drivers` table schema.
/// This model is used for reading driver data from Appwrite.
/// For registration forms, use the individual models in driverRegistration/models.
class Driver {
  /// Appwrite document ID
  final String id;
  
  /// Reference to users table
  final String userId;
  
  // Name fields
  final String fullName;
  final String firstName;
  final String? surname;
  final String lastName;
  
  // Contact fields
  final String phone;
  final String email;
  
  // Profile photo
  final String profilePhotoUrl;
  
  // CNIC/ID fields
  final String cnicNumber;
  final DateTime? cnicExpiry;
  final String cnicFrontUrl;
  final String cnicBackUrl;
  
  // License fields
  final String licenseNumber;
  final DateTime licenseExpiry;
  final String licensePhotoUrl;
  final String selfieWithLicenseUrl;
  
  // Ratings (status is now in users table, not drivers)
  final double rating;
  final int totalTrips;
  final int totalRatings;
  
  // Online status and location
  final bool isOnline;
  final List<double>? currentLocation; // [lng, lat]
  final DateTime? lastLocationUpdate;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const Driver({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.firstName,
    this.surname,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.profilePhotoUrl,
    required this.cnicNumber,
    this.cnicExpiry,
    required this.cnicFrontUrl,
    required this.cnicBackUrl,
    required this.licenseNumber,
    required this.licenseExpiry,
    required this.licensePhotoUrl,
    required this.selfieWithLicenseUrl,
    this.rating = 0.0,
    this.totalTrips = 0,
    this.totalRatings = 0,
    this.isOnline = false,
    this.currentLocation,
    this.lastLocationUpdate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Parse from Appwrite document/row
  factory Driver.fromJson(Map<String, dynamic> json) {
    // Parse current location point [lng, lat]
    List<double>? location;
    final locData = json['currentLocation'];
    if (locData is List && locData.length >= 2) {
      location = [(locData[0] as num).toDouble(), (locData[1] as num).toDouble()];
    }
    
    return Driver(
      id: json['\$id']?.toString() ?? json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      surname: json['surname']?.toString(),
      lastName: json['lastName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profilePhotoUrl: json['profilePhotoUrl']?.toString() ?? '',
      cnicNumber: json['cnicNumber']?.toString() ?? '',
      cnicExpiry: _parseDateTime(json['cnicExpiry']),
      cnicFrontUrl: json['cnicFrontUrl']?.toString() ?? '',
      cnicBackUrl: json['cnicBackUrl']?.toString() ?? '',
      licenseNumber: json['licenseNumber']?.toString() ?? '',
      licenseExpiry: _parseDateTime(json['licenseExpiry']) ?? DateTime.now(),
      licensePhotoUrl: json['licensePhotoUrl']?.toString() ?? '',
      selfieWithLicenseUrl: json['selfieWithLicenseUrl']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalTrips: (json['totalTrips'] as num?)?.toInt() ?? 0,
      totalRatings: (json['totalRatings'] as num?)?.toInt() ?? 0,
      isOnline: json['isOnline'] == true,
      currentLocation: location,
      lastLocationUpdate: _parseDateTime(json['lastLocationUpdate']),
      createdAt: _parseDateTime(json['\$createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['\$updatedAt']) ?? DateTime.now(),
    );
  }
  
  /// Convert to JSON (for local storage)
  Map<String, dynamic> toJson() => {
    '\$id': id,
    'userId': userId,
    'fullName': fullName,
    'firstName': firstName,
    'surname': surname,
    'lastName': lastName,
    'phone': phone,
    'email': email,
    'profilePhotoUrl': profilePhotoUrl,
    'cnicNumber': cnicNumber,
    'cnicExpiry': cnicExpiry?.toIso8601String(),
    'cnicFrontUrl': cnicFrontUrl,
    'cnicBackUrl': cnicBackUrl,
    'licenseNumber': licenseNumber,
    'licenseExpiry': licenseExpiry.toIso8601String(),
    'licensePhotoUrl': licensePhotoUrl,
    'selfieWithLicenseUrl': selfieWithLicenseUrl,
    'rating': rating,
    'totalTrips': totalTrips,
    'totalRatings': totalRatings,
    'isOnline': isOnline,
    'currentLocation': currentLocation,
    'lastLocationUpdate': lastLocationUpdate?.toIso8601String(),
    '\$createdAt': createdAt.toIso8601String(),
    '\$updatedAt': updatedAt.toIso8601String(),
  };
  
  /// Create a copy with updated fields
  Driver copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? firstName,
    String? surname,
    String? lastName,
    String? phone,
    String? email,
    String? profilePhotoUrl,
    String? cnicNumber,
    DateTime? cnicExpiry,
    String? cnicFrontUrl,
    String? cnicBackUrl,
    String? licenseNumber,
    DateTime? licenseExpiry,
    String? licensePhotoUrl,
    String? selfieWithLicenseUrl,
    double? rating,
    int? totalTrips,
    int? totalRatings,
    bool? isOnline,
    List<double>? currentLocation,
    DateTime? lastLocationUpdate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Driver(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    fullName: fullName ?? this.fullName,
    firstName: firstName ?? this.firstName,
    surname: surname ?? this.surname,
    lastName: lastName ?? this.lastName,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    cnicNumber: cnicNumber ?? this.cnicNumber,
    cnicExpiry: cnicExpiry ?? this.cnicExpiry,
    cnicFrontUrl: cnicFrontUrl ?? this.cnicFrontUrl,
    cnicBackUrl: cnicBackUrl ?? this.cnicBackUrl,
    licenseNumber: licenseNumber ?? this.licenseNumber,
    licenseExpiry: licenseExpiry ?? this.licenseExpiry,
    licensePhotoUrl: licensePhotoUrl ?? this.licensePhotoUrl,
    selfieWithLicenseUrl: selfieWithLicenseUrl ?? this.selfieWithLicenseUrl,
    rating: rating ?? this.rating,
    totalTrips: totalTrips ?? this.totalTrips,
    totalRatings: totalRatings ?? this.totalRatings,
    isOnline: isOnline ?? this.isOnline,
    currentLocation: currentLocation ?? this.currentLocation,
    lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  
  // Helper to parse datetime
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
  
  /// Display name (full name or first + last)
  String get displayName => fullName.isNotEmpty 
      ? fullName 
      : '$firstName $lastName'.trim();
}

// Note: DriverVerificationStatus enum removed - status is now managed in users table
