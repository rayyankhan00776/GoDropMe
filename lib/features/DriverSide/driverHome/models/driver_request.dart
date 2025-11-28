/// Service request model matching Appwrite `service_requests` collection.
/// Used to display incoming ride requests on Driver's side.
class DriverRequest {
  final String id;
  final String parentId; // Reference to parents.$id
  final String childId; // Reference to children.$id
  final String parentName; // Denormalized for display
  final String childName; // Denormalized for display
  final String? avatarUrl; // optional: use initials if null
  final String schoolName;
  final String pickPoint;
  final String dropPoint;
  /// Request status: pending, accepted, rejected, cancelled
  final String status;
  /// Request type: pickup, dropoff, or both
  final String requestType;
  /// Optional message from parent
  final String? message;
  /// Proposed monthly fee in PKR (optional)
  final int? proposedPrice;
  /// Request creation timestamp
  final DateTime? createdAt;

  DriverRequest({
    required this.id,
    required this.parentId,
    required this.childId,
    required this.parentName,
    this.childName = '',
    this.avatarUrl,
    required this.schoolName,
    required this.pickPoint,
    required this.dropPoint,
    this.status = 'pending',
    this.requestType = 'both',
    this.message,
    this.proposedPrice,
    this.createdAt,
  });

  /// Convert to JSON for backend storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'parentId': parentId,
    'childId': childId,
    'parentName': parentName,
    'childName': childName,
    'avatarUrl': avatarUrl,
    'schoolName': schoolName,
    'pickPoint': pickPoint,
    'dropPoint': dropPoint,
    'status': status,
    'requestType': requestType,
    'message': message,
    'proposedPrice': proposedPrice,
    'createdAt': createdAt?.toIso8601String(),
  };

  /// Create from backend JSON
  factory DriverRequest.fromJson(Map<String, dynamic> json) => DriverRequest(
    id: json['\$id']?.toString() ?? json['id']?.toString() ?? '',
    parentId: json['parentId']?.toString() ?? '',
    childId: json['childId']?.toString() ?? '',
    parentName: json['parentName']?.toString() ?? '',
    childName: json['childName']?.toString() ?? '',
    avatarUrl: json['avatarUrl']?.toString(),
    schoolName: json['schoolName']?.toString() ?? '',
    pickPoint: json['pickPoint']?.toString() ?? '',
    dropPoint: json['dropPoint']?.toString() ?? '',
    status: json['status']?.toString() ?? 'pending',
    requestType: json['requestType']?.toString() ?? 'both',
    message: json['message']?.toString(),
    proposedPrice: (json['proposedPrice'] as num?)?.toInt(),
    createdAt: json['\$createdAt'] != null || json['createdAt'] != null
        ? DateTime.tryParse(json['\$createdAt']?.toString() ?? json['createdAt']?.toString() ?? '')
        : null,
  );

  static List<DriverRequest> demo() => [
    DriverRequest(
      id: 'req_1',
      parentId: 'parent_1',
      childId: 'child_1',
      parentName: 'Ayesha Khan',
      childName: 'Sara',
      schoolName: 'Bloomfield School',
      pickPoint: 'Street 12, Sector F-8',
      dropPoint: 'Bloomfield Main Gate',
      status: 'pending',
      requestType: 'both',
      proposedPrice: 8000,
    ),
    DriverRequest(
      id: 'req_2',
      parentId: 'parent_2',
      childId: 'child_2',
      parentName: 'Muhammad Ali',
      childName: 'Hassan',
      schoolName: 'City Grammar',
      pickPoint: 'House 22, Phase 4',
      dropPoint: 'City Grammar Gate 2',
      status: 'pending',
      requestType: 'both',
      proposedPrice: 7500,
    ),
  ];
}
