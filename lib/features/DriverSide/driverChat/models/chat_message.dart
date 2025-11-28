/// Chat message model matching Appwrite `messages` collection (from driver's view).
class DriverChatMessage {
  final String id; // messages.$id
  final String chatRoomId; // Reference to chat_rooms.$id
  final String senderId; // Sender's user/parent/driver ID
  final String senderRole; // 'parent' or 'driver'
  final String messageType; // 'text', 'image', or 'location'
  final String text;
  final String? imageFileId; // Storage file ID for image messages
  final List<double>? location; // [lng, lat] for location messages
  final bool isRead;
  final DateTime time; // $createdAt

  const DriverChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    this.senderRole = 'driver',
    this.messageType = 'text',
    required this.text,
    this.imageFileId,
    this.location,
    this.isRead = false,
    required this.time,
  });
  
  /// Convenience getter: true if this message was sent by the driver
  bool get fromMe => senderRole == 'driver';

  /// Convert to JSON for backend storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'chatRoomId': chatRoomId,
    'senderId': senderId,
    'senderRole': senderRole,
    'messageType': messageType,
    'text': text,
    'imageFileId': imageFileId,
    'location': location,
    'isRead': isRead,
    'time': time.toIso8601String(), // ISO 8601 for Appwrite datetime
  };

  /// Create from backend JSON
  factory DriverChatMessage.fromJson(Map<String, dynamic> json) => DriverChatMessage(
    id: json['\$id']?.toString() ?? json['id']?.toString() ?? '',
    chatRoomId: json['chatRoomId']?.toString() ?? json['contactId']?.toString() ?? '',
    senderId: json['senderId']?.toString() ?? '',
    senderRole: json['senderRole']?.toString() ?? 'driver',
    messageType: json['messageType']?.toString() ?? 'text',
    text: json['text']?.toString() ?? '',
    imageFileId: json['imageFileId']?.toString(),
    location: json['location'] is List && (json['location'] as List).length >= 2
        ? [(json['location'][0] as num).toDouble(), (json['location'][1] as num).toDouble()]
        : null,
    isRead: json['isRead'] == true,
    time: DateTime.tryParse(json['\$createdAt']?.toString() ?? json['time']?.toString() ?? '') ?? DateTime.now(),
  );

  static List<DriverChatMessage> demoFor(String chatRoomId) => [
    DriverChatMessage(
      id: 'dm1',
      chatRoomId: chatRoomId,
      senderId: 'driver_1',
      senderRole: 'driver',
      text: 'Pickup confirmed at 7:15 AM.',
      time: DateTime.now().subtract(const Duration(minutes: 17)),
    ),
    DriverChatMessage(
      id: 'dm2',
      chatRoomId: chatRoomId,
      senderId: 'parent_1',
      senderRole: 'parent',
      text: 'Thanks!',
      time: DateTime.now().subtract(const Duration(minutes: 16)),
    ),
  ];
}
