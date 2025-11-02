class PersonalInfo {
  final String firstName;
  final String surName;
  final String lastName;

  /// Optional local path or URI to the captured personal photo.
  final String? photoPath;

  const PersonalInfo({
    required this.firstName,
    required this.surName,
    required this.lastName,
    this.photoPath,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'surName': surName,
    'lastName': lastName,
    'photoPath': photoPath,
  };

  factory PersonalInfo.fromJson(Map<String, dynamic> json) => PersonalInfo(
    firstName: (json['firstName'] ?? '').toString(),
    surName: (json['surName'] ?? '').toString(),
    lastName: (json['lastName'] ?? '').toString(),
    photoPath: json['photoPath']?.toString(),
  );
}
