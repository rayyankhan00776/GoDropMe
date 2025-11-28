/// Trip status enum matching Appwrite `trips` collection status field
enum DriverOrderStatus { 
  scheduled, 
  driverEnroute, 
  arrived, 
  picked, 
  inTransit, 
  dropped, 
  cancelled, 
  absent 
}

extension DriverOrderStatusExt on DriverOrderStatus {
  String get name => switch (this) {
    DriverOrderStatus.scheduled => 'scheduled',
    DriverOrderStatus.driverEnroute => 'driver_enroute',
    DriverOrderStatus.arrived => 'arrived',
    DriverOrderStatus.picked => 'picked',
    DriverOrderStatus.inTransit => 'in_transit',
    DriverOrderStatus.dropped => 'dropped',
    DriverOrderStatus.cancelled => 'cancelled',
    DriverOrderStatus.absent => 'absent',
  };
  
  static DriverOrderStatus fromString(String? s) {
    if (s == null) return DriverOrderStatus.scheduled;
    switch (s.toLowerCase()) {
      case 'driver_enroute': return DriverOrderStatus.driverEnroute;
      case 'arrived': return DriverOrderStatus.arrived;
      case 'picked': return DriverOrderStatus.picked;
      case 'in_transit': return DriverOrderStatus.inTransit;
      case 'dropped': return DriverOrderStatus.dropped;
      case 'cancelled': return DriverOrderStatus.cancelled;
      case 'absent': return DriverOrderStatus.absent;
      default: return DriverOrderStatus.scheduled;
    }
  }
}

/// Trip/Order model matching Appwrite `trips` collection.
/// Used for Driver's daily trip list.
class DriverOrder {
  final String id;
  final String activeServiceId; // Reference to active_services.$id
  final String parentId; // Reference to parents.$id
  final String childId; // Reference to children.$id
  final String parentName; // Denormalized for display
  final String childName; // Denormalized for display
  final String? avatarUrl;
  final String schoolName;
  final String pickPoint; // Address text
  final String dropPoint; // Address text
  /// [lng, lat] for Appwrite point type
  final List<double>? pickLocation;
  /// [lng, lat] for Appwrite point type
  final List<double>? dropLocation;
  /// Trip direction: home_to_school or school_to_home
  final String tripDirection;
  /// Trip type: morning or afternoon
  final String tripType;
  DriverOrderStatus status;
  /// Scheduled date for this trip
  final DateTime? scheduledDate;
  /// Window times (HH:MM)
  final String? windowStartTime;
  final String? windowEndTime;

  DriverOrder({
    required this.id,
    this.activeServiceId = '',
    this.parentId = '',
    this.childId = '',
    required this.parentName,
    this.childName = '',
    this.avatarUrl,
    required this.schoolName,
    required this.pickPoint,
    required this.dropPoint,
    this.pickLocation,
    this.dropLocation,
    this.tripDirection = 'home_to_school',
    this.tripType = 'morning',
    this.status = DriverOrderStatus.scheduled,
    this.scheduledDate,
    this.windowStartTime,
    this.windowEndTime,
  });

  /// Convert to JSON for backend storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'activeServiceId': activeServiceId,
    'parentId': parentId,
    'childId': childId,
    'parentName': parentName,
    'childName': childName,
    'avatarUrl': avatarUrl,
    'schoolName': schoolName,
    'pickPoint': pickPoint,
    'dropPoint': dropPoint,
    'pickLocation': pickLocation,
    'dropLocation': dropLocation,
    'tripDirection': tripDirection,
    'tripType': tripType,
    'status': status.name,
    'scheduledDate': scheduledDate?.toIso8601String(),
    'windowStartTime': windowStartTime,
    'windowEndTime': windowEndTime,
  };

  /// Create from backend JSON
  factory DriverOrder.fromJson(Map<String, dynamic> json) => DriverOrder(
    id: json['\$id']?.toString() ?? json['id']?.toString() ?? '',
    activeServiceId: json['activeServiceId']?.toString() ?? '',
    parentId: json['parentId']?.toString() ?? '',
    childId: json['childId']?.toString() ?? '',
    parentName: json['parentName']?.toString() ?? '',
    childName: json['childName']?.toString() ?? '',
    avatarUrl: json['avatarUrl']?.toString(),
    schoolName: json['schoolName']?.toString() ?? '',
    pickPoint: json['pickPoint']?.toString() ?? '',
    dropPoint: json['dropPoint']?.toString() ?? '',
    pickLocation: _parsePoint(json['pickLocation'] ?? json['pickupLocation']),
    dropLocation: _parsePoint(json['dropLocation']),
    tripDirection: json['tripDirection']?.toString() ?? 'home_to_school',
    tripType: json['tripType']?.toString() ?? 'morning',
    status: DriverOrderStatusExt.fromString(json['status']?.toString()),
    scheduledDate: json['scheduledDate'] != null 
        ? DateTime.tryParse(json['scheduledDate'].toString()) 
        : null,
    windowStartTime: json['windowStartTime']?.toString(),
    windowEndTime: json['windowEndTime']?.toString(),
  );
  
  static List<double>? _parsePoint(dynamic data) {
    if (data is List && data.length >= 2) {
      return [(data[0] as num).toDouble(), (data[1] as num).toDouble()];
    }
    return null;
  }

  static DriverOrder fromRequest({
    required String id,
    required String parentId,
    required String childId,
    required String parentName,
    String childName = '',
    String? avatarUrl,
    required String schoolName,
    required String pickPoint,
    required String dropPoint,
  }) => DriverOrder(
    id: id,
    parentId: parentId,
    childId: childId,
    parentName: parentName,
    childName: childName,
    avatarUrl: avatarUrl,
    schoolName: schoolName,
    pickPoint: pickPoint,
    dropPoint: dropPoint,
  );

  static List<DriverOrder> demo() => [
    DriverOrder(
      id: 'ord_1',
      activeServiceId: 'svc_1',
      parentId: 'parent_1',
      childId: 'child_1',
      parentName: 'Sara Ahmed',
      childName: 'Ali',
      schoolName: 'Allied School',
      pickPoint: 'Block A-3, Gulberg',
      dropPoint: 'Allied School Gate 1',
      tripDirection: 'home_to_school',
      tripType: 'morning',
      status: DriverOrderStatus.scheduled,
      windowStartTime: '05:00',
      windowEndTime: '09:00',
    ),
  ];
}
