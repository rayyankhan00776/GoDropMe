/// Chat contact model representing a chat room from parent's perspective.
/// Maps to Appwrite `chat_rooms` collection.
class ParentChatContact {
  final String id; // chat_rooms.$id
  final String driverId; // Reference to drivers.$id
  final String name; // Driver's name (denormalized)
  final String? avatarUrl; // Driver's profile photo URL
  final String? lastMessage; // Last message preview
  final DateTime? lastMessageAt; // Last message timestamp
  final int unreadCount; // parentUnreadCount from chat_rooms

  const ParentChatContact({
    required this.id,
    required this.driverId,
    required this.name,
    this.avatarUrl,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  /// Convert to JSON for backend storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'driverId': driverId,
    'name': name,
    'avatarUrl': avatarUrl,
    'lastMessage': lastMessage,
    'lastMessageAt': lastMessageAt?.toIso8601String(),
    'unreadCount': unreadCount,
  };

  /// Create from backend JSON
  factory ParentChatContact.fromJson(Map<String, dynamic> json) => ParentChatContact(
    id: json['\$id']?.toString() ?? json['id']?.toString() ?? '',
    driverId: json['driverId']?.toString() ?? '',
    name: json['name']?.toString() ?? json['driverName']?.toString() ?? '',
    avatarUrl: json['avatarUrl']?.toString(),
    lastMessage: json['lastMessage']?.toString(),
    lastMessageAt: json['lastMessageAt'] != null 
        ? DateTime.tryParse(json['lastMessageAt'].toString()) 
        : null,
    unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 
                 (json['parentUnreadCount'] as num?)?.toInt() ?? 0,
  );

  static List<ParentChatContact> demo() => const [
    ParentChatContact(
      id: 'room_1', 
      driverId: 'd1',
      name: 'Ali Raza', 
      avatarUrl: null,
      lastMessage: 'Sure, 7:15 AM sharp.',
      unreadCount: 1,
    ),
  ];
}
