class DriverChatMessage {
  final String id;
  final String contactId;
  final String text;
  final bool fromMe;
  final DateTime time;

  const DriverChatMessage({
    required this.id,
    required this.contactId,
    required this.text,
    required this.fromMe,
    required this.time,
  });

  static List<DriverChatMessage> demoFor(String contactId) => [
    DriverChatMessage(
      id: 'dm1',
      contactId: contactId,
      text: 'Pickup confirmed at 7:15 AM.',
      fromMe: true,
      time: DateTime.now().subtract(const Duration(minutes: 17)),
    ),
    DriverChatMessage(
      id: 'dm2',
      contactId: contactId,
      text: 'Thanks!',
      fromMe: false,
      time: DateTime.now().subtract(const Duration(minutes: 16)),
    ),
  ];
}
