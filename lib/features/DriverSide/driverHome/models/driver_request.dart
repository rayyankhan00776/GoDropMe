class DriverRequest {
  final String id;
  final String parentName;
  final String? avatarUrl; // optional: use initials if null
  final String schoolName;
  final String pickPoint;
  final String dropPoint;

  DriverRequest({
    required this.id,
    required this.parentName,
    this.avatarUrl,
    required this.schoolName,
    required this.pickPoint,
    required this.dropPoint,
  });

  static List<DriverRequest> demo() => [
    DriverRequest(
      id: 'req_1',
      parentName: 'Ayesha Khan',
      schoolName: 'Bloomfield School',
      pickPoint: 'Street 12, Sector F-8',
      dropPoint: 'Bloomfield Main Gate',
    ),
    DriverRequest(
      id: 'req_2',
      parentName: 'Muhammad Ali',
      schoolName: 'City Grammar',
      pickPoint: 'House 22, Phase 4',
      dropPoint: 'City Grammar Gate 2',
    ),
  ];
}
