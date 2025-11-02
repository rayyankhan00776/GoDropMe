class ParentChatMessage {
  final String id;
  final String contactId;
  final String text;
  final bool fromMe;
  final DateTime time;

  const ParentChatMessage({
    required this.id,
    required this.contactId,
    required this.text,
    required this.fromMe,
    required this.time,
  });

  static List<ParentChatMessage> demoFor(String contactId) => [
    ParentChatMessage(
      id: 'm1',
      contactId: contactId,
      text: 'Hello! Can you confirm pickup time?',
      fromMe: true,
      time: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    ParentChatMessage(
      id: 'm2',
      contactId: contactId,
      text: 'Sure, 7:15 AM sharp.',
      fromMe: false,
      time: DateTime.now().subtract(const Duration(minutes: 23)),
    ),
  ];
}
