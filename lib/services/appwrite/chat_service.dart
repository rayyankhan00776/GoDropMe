import 'dart:async';
import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/auth_service.dart';
import 'package:godropme/services/appwrite/database_constants.dart';
import 'package:godropme/services/appwrite/storage_service.dart';

/// Chat Service for GoDropMe
///
/// Handles all chat operations:
/// - Get or create chat rooms between parent and driver
/// - Send messages (text, image, location)
/// - Fetch messages with pagination
/// - Mark messages as read
/// - Real-time message subscriptions
class ChatService {
  static ChatService? _instance;
  static ChatService get instance => _instance ??= ChatService._();

  final TablesDB _tablesDB = AppwriteClient.tablesDBService();
  final Realtime _realtime = AppwriteClient.realtimeService();

  /// Active subscriptions for cleanup
  RealtimeSubscription? _messagesSubscription;
  RealtimeSubscription? _chatRoomsSubscription;

  ChatService._();

  // ═══════════════════════════════════════════════════════════════════════════
  // CHAT ROOM OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get or create a chat room between parent and driver
  ///
  /// If a chat room already exists for this parent-driver pair, returns it.
  /// Otherwise creates a new chat room.
  ///
  /// ```dart
  /// final result = await ChatService.instance.getOrCreateChatRoom(
  ///   parentId: 'parent_123',
  ///   driverId: 'driver_456',
  /// );
  /// if (result.success) {
  ///   print('Chat room: ${result.chatRoomId}');
  /// }
  /// ```
  Future<ChatRoomResult> getOrCreateChatRoom({
    required String parentId,
    required String driverId,
  }) async {
    try {
      final authUser = AuthService.instance.currentUser;
      if (authUser == null) {
        return ChatRoomResult.failure('Please login first');
      }

      // Check if chat room already exists
      final existingRooms = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.chatRooms,
        queries: [
          Query.equal('parentId', parentId),
          Query.equal('driverId', driverId),
          Query.limit(1),
        ],
      );

      if (existingRooms.total > 0) {
        final room = existingRooms.rows.first;
        debugPrint('✅ Found existing chat room: ${room.$id}');
        return ChatRoomResult.success(
          message: 'Chat room found',
          chatRoomId: room.$id,
          data: room.data,
        );
      }

      // Create new chat room
      final newRoom = await _tablesDB.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.chatRooms,
        rowId: ID.unique(),
        data: {
          'parentId': parentId,
          'driverId': driverId,
          'lastMessage': null,
          'lastMessageAt': null,
          'parentUnreadCount': 0,
          'driverUnreadCount': 0,
        },
        // Both parent and driver can read and update
        permissions: [
          Permission.read(Role.any()),
          Permission.update(Role.any()),
        ],
      );

      debugPrint('✅ Created new chat room: ${newRoom.$id}');

      return ChatRoomResult.success(
        message: 'Chat room created',
        chatRoomId: newRoom.$id,
        data: newRoom.data,
        isNew: true,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get/Create chat room error: ${e.message}');
      return ChatRoomResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Get/Create chat room error: $e');
      return ChatRoomResult.failure('Failed to get chat room. Please try again.');
    }
  }

  /// Get all chat rooms for a parent
  ///
  /// Returns list of chat rooms with driver details.
  Future<ChatRoomListResult> getParentChatRooms({
    required String parentId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final result = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.chatRooms,
        queries: [
          Query.equal('parentId', parentId),
          Query.limit(limit),
          Query.offset(offset),
          Query.orderDesc('lastMessageAt'),
        ],
      );

      return ChatRoomListResult.success(
        chatRooms: result.rows.map((row) => {'id': row.$id, ...row.data}).toList(),
        total: result.total,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get parent chat rooms error: ${e.message}');
      return ChatRoomListResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Get parent chat rooms error: $e');
      return ChatRoomListResult.failure('Failed to get chat rooms');
    }
  }

  /// Get all chat rooms for a driver
  ///
  /// Returns list of chat rooms with parent details.
  Future<ChatRoomListResult> getDriverChatRooms({
    required String driverId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final result = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.chatRooms,
        queries: [
          Query.equal('driverId', driverId),
          Query.limit(limit),
          Query.offset(offset),
          Query.orderDesc('lastMessageAt'),
        ],
      );

      return ChatRoomListResult.success(
        chatRooms: result.rows.map((row) => {'id': row.$id, ...row.data}).toList(),
        total: result.total,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get driver chat rooms error: ${e.message}');
      return ChatRoomListResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Get driver chat rooms error: $e');
      return ChatRoomListResult.failure('Failed to get chat rooms');
    }
  }

  /// Get a single chat room by ID
  Future<ChatRoomResult> getChatRoom(String chatRoomId) async {
    try {
      final row = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.chatRooms,
        rowId: chatRoomId,
      );

      return ChatRoomResult.success(
        message: 'Chat room fetched',
        chatRoomId: row.$id,
        data: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get chat room error: ${e.message}');
      return ChatRoomResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Get chat room error: $e');
      return ChatRoomResult.failure('Failed to get chat room');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MESSAGE OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Send a text message
  ///
  /// ```dart
  /// final result = await ChatService.instance.sendTextMessage(
  ///   chatRoomId: 'room_123',
  ///   senderId: 'parent_456',
  ///   senderRole: 'parent',
  ///   text: 'Hello!',
  /// );
  /// ```
  Future<MessageResult> sendTextMessage({
    required String chatRoomId,
    required String senderId,
    required String senderRole, // 'parent' or 'driver'
    required String text,
  }) async {
    try {
      if (text.trim().isEmpty) {
        return MessageResult.failure('Message cannot be empty');
      }

      final authUser = AuthService.instance.currentUser;
      if (authUser == null) {
        return MessageResult.failure('Please login first');
      }

      // Create the message
      final message = await _tablesDB.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.messages,
        rowId: ID.unique(),
        data: {
          'chatRoomId': chatRoomId,
          'senderId': senderId,
          'senderRole': senderRole,
          'messageType': CollectionEnums.messageText,
          'text': text.trim(),
          'isRead': false,
        },
        permissions: [
          Permission.read(Role.any()),
          Permission.update(Role.any()),
        ],
      );

      // Update chat room with last message info and increment unread count
      await _updateChatRoomLastMessage(
        chatRoomId: chatRoomId,
        lastMessage: text.trim(),
        senderRole: senderRole,
      );

      debugPrint('✅ Text message sent: ${message.$id}');

      return MessageResult.success(
        message: 'Message sent',
        messageId: message.$id,
        data: message.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Send text message error: ${e.message}');
      return MessageResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Send text message error: $e');
      return MessageResult.failure('Failed to send message. Please try again.');
    }
  }

  /// Send an image message
  ///
  /// Uploads the image to chat_attachments bucket, then creates message.
  Future<MessageResult> sendImageMessage({
    required String chatRoomId,
    required String senderId,
    required String senderRole,
    required File imageFile,
  }) async {
    try {
      final authUser = AuthService.instance.currentUser;
      if (authUser == null) {
        return MessageResult.failure('Please login first');
      }

      // Upload image to storage
      final uploadResult = await StorageService.instance.uploadImage(
        bucketId: Buckets.chatAttachments,
        imageFile: imageFile,
        quality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (!uploadResult.success) {
        return MessageResult.failure(uploadResult.message);
      }

      // Get the image URL
      final imageUrl = Buckets.getFileUrl(Buckets.chatAttachments, uploadResult.fileId!);

      // Create the message
      final message = await _tablesDB.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.messages,
        rowId: ID.unique(),
        data: {
          'chatRoomId': chatRoomId,
          'senderId': senderId,
          'senderRole': senderRole,
          'messageType': CollectionEnums.messageImage,
          'imageUrl': imageUrl,
          'text': null, // No text for image messages
          'isRead': false,
        },
        permissions: [
          Permission.read(Role.any()),
          Permission.update(Role.any()),
        ],
      );

      // Update chat room with last message info
      await _updateChatRoomLastMessage(
        chatRoomId: chatRoomId,
        lastMessage: '📷 Image',
        senderRole: senderRole,
      );

      debugPrint('✅ Image message sent: ${message.$id}');

      return MessageResult.success(
        message: 'Image sent',
        messageId: message.$id,
        data: {...message.data, 'imageUrl': imageUrl},
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Send image message error: ${e.message}');
      return MessageResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Send image message error: $e');
      return MessageResult.failure('Failed to send image. Please try again.');
    }
  }

  /// Send a location message
  ///
  /// Location format: [longitude, latitude]
  Future<MessageResult> sendLocationMessage({
    required String chatRoomId,
    required String senderId,
    required String senderRole,
    required double latitude,
    required double longitude,
    String? locationName,
  }) async {
    try {
      final authUser = AuthService.instance.currentUser;
      if (authUser == null) {
        return MessageResult.failure('Please login first');
      }

      // Create the message with location as point type
      final message = await _tablesDB.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.messages,
        rowId: ID.unique(),
        data: {
          'chatRoomId': chatRoomId,
          'senderId': senderId,
          'senderRole': senderRole,
          'messageType': CollectionEnums.messageLocation,
          'location': [longitude, latitude], // Appwrite point format: [lng, lat]
          'text': locationName, // Optional location name/address
          'isRead': false,
        },
        permissions: [
          Permission.read(Role.any()),
          Permission.update(Role.any()),
        ],
      );

      // Update chat room with last message info
      await _updateChatRoomLastMessage(
        chatRoomId: chatRoomId,
        lastMessage: '📍 ${locationName ?? 'Location'}',
        senderRole: senderRole,
      );

      debugPrint('✅ Location message sent: ${message.$id}');

      return MessageResult.success(
        message: 'Location sent',
        messageId: message.$id,
        data: message.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Send location message error: ${e.message}');
      return MessageResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Send location message error: $e');
      return MessageResult.failure('Failed to send location. Please try again.');
    }
  }

  /// Get messages for a chat room with pagination
  ///
  /// Messages are returned in descending order (newest first).
  Future<MessageListResult> getMessages({
    required String chatRoomId,
    int limit = 50,
    int offset = 0,
    String? cursorAfter,
  }) async {
    try {
      final queries = <String>[
        Query.equal('chatRoomId', chatRoomId),
        Query.limit(limit),
        Query.orderDesc('\$createdAt'),
      ];

      if (cursorAfter != null) {
        queries.add(Query.cursorAfter(cursorAfter));
      } else {
        queries.add(Query.offset(offset));
      }

      final result = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.messages,
        queries: queries,
      );

      return MessageListResult.success(
        messages: result.rows.map((row) => {
          'id': row.$id,
          '\$createdAt': row.$createdAt,
          ...row.data,
        }).toList(),
        total: result.total,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get messages error: ${e.message}');
      return MessageListResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Get messages error: $e');
      return MessageListResult.failure('Failed to get messages');
    }
  }

  /// Mark messages as read in a chat room
  ///
  /// Marks all unread messages from the other party as read.
  Future<void> markMessagesAsRead({
    required String chatRoomId,
    required String readerRole, // 'parent' or 'driver' - who is reading
  }) async {
    try {
      // Get unread messages from the other party
      final otherRole = readerRole == 'parent' ? 'driver' : 'parent';
      
      final unreadMessages = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.messages,
        queries: [
          Query.equal('chatRoomId', chatRoomId),
          Query.equal('senderRole', otherRole),
          Query.equal('isRead', false),
          Query.limit(100),
        ],
      );

      // Mark each message as read
      for (final msg in unreadMessages.rows) {
        await _tablesDB.updateRow(
          databaseId: AppwriteConfig.databaseId,
          tableId: Collections.messages,
          rowId: msg.$id,
          data: {'isRead': true},
        );
      }

      // Reset unread count for the reader
      final unreadField = readerRole == 'parent' ? 'parentUnreadCount' : 'driverUnreadCount';
      await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.chatRooms,
        rowId: chatRoomId,
        data: {unreadField: 0},
      );

      debugPrint('✅ Marked ${unreadMessages.total} messages as read');
    } catch (e) {
      debugPrint('❌ Mark messages as read error: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REALTIME SUBSCRIPTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Subscribe to real-time messages for a specific chat room
  ///
  /// ```dart
  /// ChatService.instance.subscribeToMessages(
  ///   chatRoomId: 'room_123',
  ///   onNewMessage: (messageData) {
  ///     print('New message: $messageData');
  ///   },
  /// );
  /// ```
  void subscribeToMessages({
    required String chatRoomId,
    required void Function(Map<String, dynamic> messageData) onNewMessage,
  }) {
    // Unsubscribe from previous subscription
    _messagesSubscription?.close();

    final channel = 'databases.${AppwriteConfig.databaseId}.tables.${Collections.messages}.rows';
    
    _messagesSubscription = _realtime.subscribe([channel]);
    
    _messagesSubscription!.stream.listen((event) {
      // Filter for this chat room's messages
      if (event.events.any((e) => e.contains('.create'))) {
        final payload = event.payload;
        if (payload['chatRoomId'] == chatRoomId) {
          debugPrint('📨 New message received: ${payload['\$id']}');
          onNewMessage({
            'id': payload['\$id'],
            '\$createdAt': payload['\$createdAt'],
            ...payload,
          });
        }
      }
    });

    debugPrint('✅ Subscribed to messages for chat room: $chatRoomId');
  }

  /// Subscribe to chat room updates (for chat list screen)
  ///
  /// Notifies when chat rooms are updated (new messages, etc.)
  void subscribeToChatRooms({
    required String userId,
    required String userRole, // 'parent' or 'driver'
    required void Function(Map<String, dynamic> chatRoomData) onChatRoomUpdate,
  }) {
    _chatRoomsSubscription?.close();

    final channel = 'databases.${AppwriteConfig.databaseId}.tables.${Collections.chatRooms}.rows';
    
    _chatRoomsSubscription = _realtime.subscribe([channel]);
    
    _chatRoomsSubscription!.stream.listen((event) {
      if (event.events.any((e) => e.contains('.update') || e.contains('.create'))) {
        final payload = event.payload;
        // Filter for user's chat rooms
        final userIdField = userRole == 'parent' ? 'parentId' : 'driverId';
        if (payload[userIdField] == userId) {
          debugPrint('📨 Chat room updated: ${payload['\$id']}');
          onChatRoomUpdate({
            'id': payload['\$id'],
            ...payload,
          });
        }
      }
    });

    debugPrint('✅ Subscribed to chat room updates for $userRole: $userId');
  }

  /// Unsubscribe from all chat subscriptions
  void unsubscribeAll() {
    _messagesSubscription?.close();
    _messagesSubscription = null;
    
    _chatRoomsSubscription?.close();
    _chatRoomsSubscription = null;
    
    debugPrint('✅ Unsubscribed from all chat subscriptions');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Update chat room's last message and unread count
  Future<void> _updateChatRoomLastMessage({
    required String chatRoomId,
    required String lastMessage,
    required String senderRole,
  }) async {
    try {
      // Increment unread count for the recipient
      final unreadField = senderRole == 'parent' ? 'driverUnreadCount' : 'parentUnreadCount';
      
      // Get current unread count
      final room = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.chatRooms,
        rowId: chatRoomId,
      );
      
      final currentCount = (room.data[unreadField] as num?)?.toInt() ?? 0;

      await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.chatRooms,
        rowId: chatRoomId,
        data: {
          'lastMessage': lastMessage.length > 100 
              ? '${lastMessage.substring(0, 100)}...' 
              : lastMessage,
          'lastMessageAt': DateTime.now().toIso8601String(),
          unreadField: currentCount + 1,
        },
      );
    } catch (e) {
      debugPrint('❌ Update chat room last message error: $e');
    }
  }

  /// Parse Appwrite exception to user-friendly message
  String _parseError(AppwriteException e) {
    switch (e.code) {
      case 401:
        return 'Please login again';
      case 403:
        return 'You don\'t have permission for this action';
      case 404:
        return 'Chat not found';
      case 409:
        return 'Message already exists';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RESULT CLASSES
// ═══════════════════════════════════════════════════════════════════════════

/// Result class for single chat room operations
class ChatRoomResult {
  final bool success;
  final String message;
  final String? chatRoomId;
  final Map<String, dynamic>? data;
  final bool isNew;

  ChatRoomResult._({
    required this.success,
    required this.message,
    this.chatRoomId,
    this.data,
    this.isNew = false,
  });

  factory ChatRoomResult.success({
    required String message,
    String? chatRoomId,
    Map<String, dynamic>? data,
    bool isNew = false,
  }) {
    return ChatRoomResult._(
      success: true,
      message: message,
      chatRoomId: chatRoomId,
      data: data,
      isNew: isNew,
    );
  }

  factory ChatRoomResult.failure(String message) {
    return ChatRoomResult._(
      success: false,
      message: message,
    );
  }
}

/// Result class for chat room list operations
class ChatRoomListResult {
  final bool success;
  final String? message;
  final List<Map<String, dynamic>> chatRooms;
  final int total;

  ChatRoomListResult._({
    required this.success,
    this.message,
    this.chatRooms = const [],
    this.total = 0,
  });

  factory ChatRoomListResult.success({
    required List<Map<String, dynamic>> chatRooms,
    required int total,
  }) {
    return ChatRoomListResult._(
      success: true,
      chatRooms: chatRooms,
      total: total,
    );
  }

  factory ChatRoomListResult.failure(String message) {
    return ChatRoomListResult._(
      success: false,
      message: message,
    );
  }
}

/// Result class for single message operations
class MessageResult {
  final bool success;
  final String message;
  final String? messageId;
  final Map<String, dynamic>? data;

  MessageResult._({
    required this.success,
    required this.message,
    this.messageId,
    this.data,
  });

  factory MessageResult.success({
    required String message,
    String? messageId,
    Map<String, dynamic>? data,
  }) {
    return MessageResult._(
      success: true,
      message: message,
      messageId: messageId,
      data: data,
    );
  }

  factory MessageResult.failure(String message) {
    return MessageResult._(
      success: false,
      message: message,
    );
  }
}

/// Result class for message list operations
class MessageListResult {
  final bool success;
  final String? message;
  final List<Map<String, dynamic>> messages;
  final int total;

  MessageListResult._({
    required this.success,
    this.message,
    this.messages = const [],
    this.total = 0,
  });

  factory MessageListResult.success({
    required List<Map<String, dynamic>> messages,
    required int total,
  }) {
    return MessageListResult._(
      success: true,
      messages: messages,
      total: total,
    );
  }

  factory MessageListResult.failure(String message) {
    return MessageListResult._(
      success: false,
      message: message,
    );
  }
}
