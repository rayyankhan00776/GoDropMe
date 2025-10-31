enum DriverOrderStatus { pendingPickup, picked, dropped }

class DriverOrder {
  final String id;
  final String parentName;
  final String? avatarUrl;
  final String schoolName;
  final String pickPoint;
  final String dropPoint;
  DriverOrderStatus status;

  DriverOrder({
    required this.id,
    required this.parentName,
    this.avatarUrl,
    required this.schoolName,
    required this.pickPoint,
    required this.dropPoint,
    this.status = DriverOrderStatus.pendingPickup,
  });

  static DriverOrder fromRequest({
    required String id,
    required String parentName,
    String? avatarUrl,
    required String schoolName,
    required String pickPoint,
    required String dropPoint,
  }) => DriverOrder(
    id: id,
    parentName: parentName,
    avatarUrl: avatarUrl,
    schoolName: schoolName,
    pickPoint: pickPoint,
    dropPoint: dropPoint,
  );

  static List<DriverOrder> demo() => [
    DriverOrder(
      id: 'ord_1',
      parentName: 'Sara Ahmed',
      schoolName: 'Allied School',
      pickPoint: 'Block A-3, Gulberg',
      dropPoint: 'Allied School Gate 1',
    ),
  ];
}
