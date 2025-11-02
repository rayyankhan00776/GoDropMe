class DriverChatContact {
  final String id;
  final String name;
  final String? avatarUrl;

  const DriverChatContact({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  // For demo, only accepted request user is visible
  static List<DriverChatContact> demoAccepted() => const [
    DriverChatContact(id: 'p1', name: 'Ayesha’s Parent', avatarUrl: null),
  ];
}
