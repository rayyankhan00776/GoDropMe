/// Active service model for parent's "Find Drivers" screen - Active tab.
/// Represents an ongoing service contract between parent and driver.
class ActiveService {
  final String id;
  final String driverId;
  final String driverName;
  final String childId;
  final String childName;
  final String schoolName;
  final String pickPoint;
  final String dropPoint;
  final int monthlyFeePkr;
  final String vehicleType;
  final String vehicleInfo; // e.g., "White Suzuki Alto"
  final String? driverPhone; // Visible only for active services
  final String? driverPhotoUrl;
  final double? driverRating;
  final DateTime? startDate;
  final String status; // active, paused, ended

  const ActiveService({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.childId,
    required this.childName,
    required this.schoolName,
    required this.pickPoint,
    required this.dropPoint,
    required this.monthlyFeePkr,
    required this.vehicleType,
    required this.vehicleInfo,
    this.driverPhone,
    this.driverPhotoUrl,
    this.driverRating,
    this.startDate,
    this.status = 'active',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'driverId': driverId,
    'driverName': driverName,
    'childId': childId,
    'childName': childName,
    'schoolName': schoolName,
    'pickPoint': pickPoint,
    'dropPoint': dropPoint,
    'monthlyFeePkr': monthlyFeePkr,
    'vehicleType': vehicleType,
    'vehicleInfo': vehicleInfo,
    'driverPhone': driverPhone,
    'driverPhotoUrl': driverPhotoUrl,
    'driverRating': driverRating,
    'startDate': startDate?.toIso8601String(),
    'status': status,
  };

  factory ActiveService.fromJson(Map<String, dynamic> json) => ActiveService(
    id: json['\$id']?.toString() ?? json['id']?.toString() ?? '',
    driverId: json['driverId']?.toString() ?? '',
    driverName: json['driverName']?.toString() ?? '',
    childId: json['childId']?.toString() ?? '',
    childName: json['childName']?.toString() ?? '',
    schoolName: json['schoolName']?.toString() ?? '',
    pickPoint: json['pickPoint']?.toString() ?? '',
    dropPoint: json['dropPoint']?.toString() ?? '',
    monthlyFeePkr: (json['monthlyFeePkr'] as num?)?.toInt() ?? 0,
    vehicleType: json['vehicleType']?.toString() ?? '',
    vehicleInfo: json['vehicleInfo']?.toString() ?? '',
    driverPhone: json['driverPhone']?.toString(),
    driverPhotoUrl: json['driverPhotoUrl']?.toString(),
    driverRating: (json['driverRating'] as num?)?.toDouble(),
    startDate: json['startDate'] != null
        ? DateTime.tryParse(json['startDate'].toString())
        : null,
    status: json['status']?.toString() ?? 'active',
  );

  /// Demo data for UI development
  static ActiveService demo() => ActiveService(
    id: 'service_1',
    driverId: 'driver_1',
    driverName: 'Muhammad Ali',
    childId: 'child_1',
    childName: 'Sara',
    schoolName: 'Allied School (Town Campus)',
    pickPoint: 'House 42, Street 5, Hayatabad Phase 6',
    dropPoint: 'Allied School Main Gate',
    monthlyFeePkr: 8000,
    vehicleType: 'Car',
    vehicleInfo: 'White Suzuki Alto',
    driverPhone: '+92 300 1234567',
    driverRating: 4.5,
    startDate: DateTime.now().subtract(const Duration(days: 15)),
    status: 'active',
  );
}
