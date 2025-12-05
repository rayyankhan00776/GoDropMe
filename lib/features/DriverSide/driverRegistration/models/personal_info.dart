class PersonalInfo {
  final String firstName;
  final String surName;
  final String lastName;
  /// Phone number (raw format from form input)
  final String? phone;

  /// Optional local path or URI to the captured personal photo (for form capture).
  final String? photoPath;
  
  /// Appwrite Storage URL for profile photo (after upload).
  final String? profilePhotoUrl;

  const PersonalInfo({
    required this.firstName,
    required this.surName,
    required this.lastName,
    this.phone,
    this.photoPath,
    this.profilePhotoUrl,
  });

  /// Full name computed from name parts
  String get fullName => '$firstName $surName $lastName'.trim().replaceAll(RegExp(r'\s+'), ' ');

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'surName': surName,
    'lastName': lastName,
    'phone': phone,
    'photoPath': photoPath,
    'profilePhotoUrl': profilePhotoUrl,
  };
  
  /// Convert to Appwrite document format (excludes local paths, uses Appwrite column names)
  Map<String, dynamic> toAppwriteJson() => {
    'firstName': firstName,
    'surname': surName, // Appwrite uses lowercase 'surname'
    'lastName': lastName,
    if (phone != null) 'phone': phone,
    if (profilePhotoUrl != null) 'profilePhotoUrl': profilePhotoUrl,
  };

  factory PersonalInfo.fromJson(Map<String, dynamic> json) => PersonalInfo(
    firstName: (json['firstName'] ?? '').toString(),
    // Support both local 'surName' and Appwrite 'surname'
    surName: (json['surName'] ?? json['surname'] ?? '').toString(),
    lastName: (json['lastName'] ?? '').toString(),
    phone: json['phone']?.toString(),
    photoPath: json['photoPath']?.toString(),
    profilePhotoUrl: json['profilePhotoUrl']?.toString(),
  );
  
  /// Create a copy with updated fields
  PersonalInfo copyWith({
    String? firstName,
    String? surName,
    String? lastName,
    String? phone,
    String? photoPath,
    String? profilePhotoUrl,
  }) => PersonalInfo(
    firstName: firstName ?? this.firstName,
    surName: surName ?? this.surName,
    lastName: lastName ?? this.lastName,
    phone: phone ?? this.phone,
    photoPath: photoPath ?? this.photoPath,
    profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
  );
}
