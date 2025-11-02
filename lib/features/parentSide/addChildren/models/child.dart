class ChildModel {
  final String name;
  final int age;
  final String gender;
  final String schoolName;
  final String pickPoint;
  final String dropPoint;
  final String relationshipToChild;
  final String? pickupTime; // keep as display string for now

  const ChildModel({
    required this.name,
    required this.age,
    required this.gender,
    required this.schoolName,
    required this.pickPoint,
    required this.dropPoint,
    required this.relationshipToChild,
    this.pickupTime,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
    'gender': gender,
    'schoolName': schoolName,
    'pickPoint': pickPoint,
    'dropPoint': dropPoint,
    'relationshipToChild': relationshipToChild,
    'pickupTime': pickupTime,
  };

  factory ChildModel.fromJson(Map<String, dynamic> json) => ChildModel(
    name: (json['name'] ?? '').toString(),
    age: (json['age'] is num)
        ? (json['age'] as num).toInt()
        : int.tryParse('${json['age']}') ?? 0,
    gender: (json['gender'] ?? '').toString(),
    schoolName: (json['schoolName'] ?? '').toString(),
    pickPoint: (json['pickPoint'] ?? '').toString(),
    dropPoint: (json['dropPoint'] ?? '').toString(),
    relationshipToChild: (json['relationshipToChild'] ?? '').toString(),
    pickupTime: json['pickupTime']?.toString(),
  );
}
