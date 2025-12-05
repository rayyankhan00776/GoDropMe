/// Child model using Appwrite-compatible flat data types.
/// School is stored as schoolId (foreign key to schools table)
class ChildModel {
  /// Document ID from Appwrite (children.$id)
  final String? id;
  /// Reference to parent document (parents.$id) - set when saving to Appwrite
  final String? parentId;
  final String name;
  final int age;
  final String gender;
  /// School ID - foreign key to schools table (Appwrite: string)
  /// Use SchoolsLoader.getById() to get school details including name and location
  final String schoolId;
  final String pickPoint;
  final String dropPoint;
  final String relationshipToChild;
  /// School opening time as display string (e.g., "7:30 AM")
  final String? schoolOpenTime;
  /// School off/closing time as display string (e.g., "1:30 PM")
  final String? schoolOffTime;
  /// Pickup location as [lng, lat] (Appwrite: point)
  final List<double>? pickLocation;
  /// Drop location as [lng, lat] (Appwrite: point)
  final List<double>? dropLocation;
  /// Child photo URL from Appwrite storage (optional)
  final String? photoUrl;
  /// Special notes/instructions for the driver (optional)
  final String? specialNotes;
  /// Whether child is currently active and needs service
  final bool isActive;
  /// Assigned driver's document ID (null if not assigned)
  final String? assignedDriverId;

  const ChildModel({
    this.id,
    this.parentId,
    required this.name,
    required this.age,
    required this.gender,
    required this.schoolId,
    required this.pickPoint,
    required this.dropPoint,
    required this.relationshipToChild,
    this.schoolOpenTime,
    this.schoolOffTime,
    this.pickLocation,
    this.dropLocation,
    this.photoUrl,
    this.specialNotes,
    this.isActive = true,
    this.assignedDriverId,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (parentId != null) 'parentId': parentId,
    'name': name,
    'age': age,
    'gender': gender,
    'schoolId': schoolId, // Foreign key to schools table
    'pickPoint': pickPoint,
    'dropPoint': dropPoint,
    'relationshipToChild': relationshipToChild,
    'schoolOpenTime': schoolOpenTime,
    'schoolOffTime': schoolOffTime,
    'pickLocation': pickLocation, // [lng, lat] for Appwrite point type
    'dropLocation': dropLocation, // [lng, lat] for Appwrite point type
    'photoUrl': photoUrl,
    'specialNotes': specialNotes,
    'isActive': isActive,
    'assignedDriverId': assignedDriverId,
  };

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    // Parse pick/drop locations
    List<double>? pickLoc = _parsePoint(json['pickLocation']);
    List<double>? dropLoc = _parsePoint(json['dropLocation']);
    
    // Legacy support for separate lat/lng fields
    if (pickLoc == null && json['pickLat'] != null && json['pickLng'] != null) {
      pickLoc = [
        (json['pickLng'] as num).toDouble(),
        (json['pickLat'] as num).toDouble(),
      ];
    }
    if (dropLoc == null && json['dropLat'] != null && json['dropLng'] != null) {
      dropLoc = [
        (json['dropLng'] as num).toDouble(),
        (json['dropLat'] as num).toDouble(),
      ];
    }
    
    // Get schoolId (foreign key to schools table)
    String schoolId = json['schoolId']?.toString() ?? '';
    
    // Parse age as integer (handle both int and string like "5" or "5 years")
    int parsedAge = 0;
    if (json['age'] is num) {
      parsedAge = (json['age'] as num).toInt();
    } else if (json['age'] is String) {
      // Extract digits from strings like "5 years" or "5"
      final ageStr = json['age'] as String;
      final digits = ageStr.replaceAll(RegExp(r'[^0-9]'), '');
      parsedAge = int.tryParse(digits) ?? 0;
    }

    return ChildModel(
      id: json['\$id']?.toString() ?? json['id']?.toString(),
      parentId: json['parentId']?.toString(),
      name: (json['name'] ?? '').toString(),
      age: parsedAge,
      gender: (json['gender'] ?? '').toString(),
      schoolId: schoolId,
      pickPoint: (json['pickPoint'] ?? json['pick_point'] ?? '').toString(),
      dropPoint: (json['dropPoint'] ?? json['drop_point'] ?? '').toString(),
      relationshipToChild: (json['relationshipToChild'] ?? json['relationship'] ?? '').toString(),
      // Support both new field names and legacy pickupTime
      schoolOpenTime: json['schoolOpenTime']?.toString() ?? json['pickupTime']?.toString() ?? json['pickup_time']?.toString(),
      schoolOffTime: json['schoolOffTime']?.toString(),
      pickLocation: pickLoc,
      dropLocation: dropLoc,
      photoUrl: json['photoUrl']?.toString(),
      specialNotes: json['specialNotes']?.toString(),
      isActive: json['isActive'] == true || json['isActive'] == null, // default true
      assignedDriverId: json['assignedDriverId']?.toString(),
    );
  }
  
  /// Helper to parse [lng, lat] point from various formats
  static List<double>? _parsePoint(dynamic data) {
    if (data is List && data.length >= 2) {
      return [(data[0] as num).toDouble(), (data[1] as num).toDouble()];
    }
    return null;
  }
  
  /// Create a copy with updated fields
  ChildModel copyWith({
    String? id,
    String? parentId,
    String? name,
    int? age,
    String? gender,
    String? schoolId,
    String? pickPoint,
    String? dropPoint,
    String? relationshipToChild,
    String? schoolOpenTime,
    String? schoolOffTime,
    List<double>? pickLocation,
    List<double>? dropLocation,
    String? photoUrl,
    String? specialNotes,
    bool? isActive,
    String? assignedDriverId,
  }) => ChildModel(
    id: id ?? this.id,
    parentId: parentId ?? this.parentId,
    name: name ?? this.name,
    age: age ?? this.age,
    gender: gender ?? this.gender,
    schoolId: schoolId ?? this.schoolId,
    pickPoint: pickPoint ?? this.pickPoint,
    dropPoint: dropPoint ?? this.dropPoint,
    relationshipToChild: relationshipToChild ?? this.relationshipToChild,
    schoolOpenTime: schoolOpenTime ?? this.schoolOpenTime,
    schoolOffTime: schoolOffTime ?? this.schoolOffTime,
    pickLocation: pickLocation ?? this.pickLocation,
    dropLocation: dropLocation ?? this.dropLocation,
    photoUrl: photoUrl ?? this.photoUrl,
    specialNotes: specialNotes ?? this.specialNotes,
    isActive: isActive ?? this.isActive,
    assignedDriverId: assignedDriverId ?? this.assignedDriverId,
  );
}
