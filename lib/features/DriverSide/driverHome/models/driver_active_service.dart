/// Driver's active service model for "My Services" screen.
/// Represents an ongoing service contract from the driver's perspective.
class DriverActiveService {
  final String id;
  final String parentId;
  final String parentName;
  final String childId;
  final String childName;
  final int? childAge;
  final String? childGender;
  final String? parentPhone; // Visible for active services
  final String? parentPhotoUrl;
  final String schoolName;
  final String pickPoint;
  final String dropPoint;
  final int monthlyFeePkr;
  final DateTime? startDate;
  final String status; // active, paused, ended

  const DriverActiveService({
    required this.id,
    required this.parentId,
    required this.parentName,
    required this.childId,
    required this.childName,
    this.childAge,
    this.childGender,
    this.parentPhone,
    this.parentPhotoUrl,
    required this.schoolName,
    required this.pickPoint,
    required this.dropPoint,
    required this.monthlyFeePkr,
    this.startDate,
    this.status = 'active',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'parentId': parentId,
    'parentName': parentName,
    'childId': childId,
    'childName': childName,
    'childAge': childAge,
    'childGender': childGender,
    'parentPhone': parentPhone,
    'parentPhotoUrl': parentPhotoUrl,
    'schoolName': schoolName,
    'pickPoint': pickPoint,
    'dropPoint': dropPoint,
    'monthlyFeePkr': monthlyFeePkr,
    'startDate': startDate?.toIso8601String(),
    'status': status,
  };

  factory DriverActiveService.fromJson(Map<String, dynamic> json) => DriverActiveService(
    id: json['\$id']?.toString() ?? json['id']?.toString() ?? '',
    parentId: json['parentId']?.toString() ?? '',
    parentName: json['parentName']?.toString() ?? '',
    childId: json['childId']?.toString() ?? '',
    childName: json['childName']?.toString() ?? '',
    childAge: (json['childAge'] as num?)?.toInt(),
    childGender: json['childGender']?.toString(),
    parentPhone: json['parentPhone']?.toString(),
    parentPhotoUrl: json['parentPhotoUrl']?.toString(),
    schoolName: json['schoolName']?.toString() ?? '',
    pickPoint: json['pickPoint']?.toString() ?? '',
    dropPoint: json['dropPoint']?.toString() ?? '',
    monthlyFeePkr: (json['monthlyFeePkr'] as num?)?.toInt() ?? 0,
    startDate: json['startDate'] != null
        ? DateTime.tryParse(json['startDate'].toString())
        : null,
    status: json['status']?.toString() ?? 'active',
  );

  /// Demo data for UI development
  static List<DriverActiveService> demo() => [
    DriverActiveService(
      id: 'service_1',
      parentId: 'parent_1',
      parentName: 'Ayesha Khan',
      childId: 'child_1',
      childName: 'Sara',
      childAge: 8,
      childGender: 'Female',
      parentPhone: '+92 300 1234567',
      schoolName: 'Bloomfield School',
      pickPoint: 'Street 12, Sector F-8',
      dropPoint: 'Bloomfield Main Gate',
      monthlyFeePkr: 8000,
      startDate: DateTime.now().subtract(const Duration(days: 20)),
      status: 'active',
    ),
    DriverActiveService(
      id: 'service_2',
      parentId: 'parent_2',
      parentName: 'Muhammad Ali',
      childId: 'child_2',
      childName: 'Hassan',
      childAge: 10,
      childGender: 'Male',
      parentPhone: '+92 321 9876543',
      schoolName: 'City Grammar',
      pickPoint: 'House 22, Phase 4',
      dropPoint: 'City Grammar Gate 2',
      monthlyFeePkr: 7500,
      startDate: DateTime.now().subtract(const Duration(days: 45)),
      status: 'active',
    ),
  ];
}
