/// Chat contact model representing a chat room from driver's perspective.
/// Maps to Appwrite `chat_rooms` collection.
class DriverChatContact {
  final String id; // chat_rooms.$id
  final String parentId; // Reference to parents.$id
  final String name; // Parent's name (denormalized)
  final String? avatarUrl; // Parent's profile photo URL
  final String? lastMessage; // Last message preview
  final DateTime? lastMessageAt; // Last message timestamp
  final int unreadCount; // driverUnreadCount from chat_rooms

  const DriverChatContact({
    required this.id,
    required this.parentId,
    required this.name,
    this.avatarUrl,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  /// Convert to JSON for backend storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'parentId': parentId,
    'name': name,
    'avatarUrl': avatarUrl,
    'lastMessage': lastMessage,
    'lastMessageAt': lastMessageAt?.toIso8601String(),
    'unreadCount': unreadCount,
  };

  /// Create from backend JSON
  factory DriverChatContact.fromJson(Map<String, dynamic> json) => DriverChatContact(
    id: json['\$id']?.toString() ?? json['id']?.toString() ?? '',
    parentId: json['parentId']?.toString() ?? '',
    name: json['name']?.toString() ?? json['parentName']?.toString() ?? '',
    avatarUrl: json['avatarUrl']?.toString(),
    lastMessage: json['lastMessage']?.toString(),
    lastMessageAt: json['lastMessageAt'] != null 
        ? DateTime.tryParse(json['lastMessageAt'].toString()) 
        : null,
    unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 
                 (json['driverUnreadCount'] as num?)?.toInt() ?? 0,
  );

  // For demo, only accepted request user is visible
  static List<DriverChatContact> demoAccepted() => const [
    DriverChatContact(
      id: 'room_1',
      parentId: 'p1',
      name: "Ayesha's Parent",
      avatarUrl: null,
      lastMessage: 'Sure, 7:15 AM sharp.',
      unreadCount: 1,
    ),
  ];
}
