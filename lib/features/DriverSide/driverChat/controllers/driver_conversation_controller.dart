import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/features/DriverSide/driverChat/models/chat_message.dart';
import 'package:godropme/services/appwrite/chat_service.dart';
import 'package:godropme/services/appwrite/driver_service.dart';

/// Controller for driver's conversation screen
/// 
/// Handles sending/receiving messages with real-time updates.
class DriverConversationController extends GetxController {
  final String chatRoomId;
  final messages = <DriverChatMessage>[].obs;
  final isLoading = false.obs;
  final isSending = false.obs;
  final errorMessage = ''.obs;
  
  String? _driverId;
  String? get driverId => _driverId;
  
  bool _hasMore = true;
  String? _lastMessageId;

  DriverConversationController(this.chatRoomId);

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  @override
  void onClose() {
    ChatService.instance.unsubscribeAll();
    super.onClose();
  }

  Future<void> _initialize() async {
    await _loadDriverId();
    await loadMessages();
    _subscribeToMessages();
    _markAsRead();
  }

  /// Load driver ID from driver service
  Future<void> _loadDriverId() async {
    try {
      final result = await DriverService.instance.getDriver();
      if (result.success && result.driverId != null) {
        _driverId = result.driverId;
        debugPrint('✅ Driver ID for conversation: $_driverId');
      }
    } catch (e) {
      debugPrint('❌ Load driver ID error: $e');
    }
  }

  /// Load messages from backend with pagination
  Future<void> loadMessages({bool loadMore = false}) async {
    if (isLoading.value) return;
    if (loadMore && !_hasMore) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await ChatService.instance.getMessages(
        chatRoomId: chatRoomId,
        limit: 50,
        cursorAfter: loadMore ? _lastMessageId : null,
      );

      if (result.success) {
        final newMessages = result.messages.map((data) => DriverChatMessage.fromJson(data)).toList();
        
        if (loadMore) {
          // Append older messages
          messages.addAll(newMessages);
        } else {
          // Replace all messages
          messages.assignAll(newMessages);
        }

        // Track pagination
        if (newMessages.isNotEmpty) {
          _lastMessageId = newMessages.last.id;
        }
        _hasMore = newMessages.length == 50;

        debugPrint('✅ Loaded ${newMessages.length} messages, total: ${messages.length}');
      } else {
        errorMessage.value = result.message ?? 'Failed to load messages';
        debugPrint('❌ Load messages error: ${result.message}');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load messages';
      debugPrint('❌ Load messages exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load more messages (for pagination)
  Future<void> loadMore() async {
    await loadMessages(loadMore: true);
  }

  /// Send a text message
  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;
    if (_driverId == null) {
      debugPrint('❌ Cannot send message: driver ID not available');
      return;
    }
    if (isSending.value) return;

    isSending.value = true;

    try {
      final result = await ChatService.instance.sendTextMessage(
        chatRoomId: chatRoomId,
        senderId: _driverId!,
        senderRole: 'driver',
        text: text,
      );

      if (result.success) {
        // Message will be added via realtime subscription
        debugPrint('✅ Message sent: ${result.messageId}');
      } else {
        Get.snackbar('Error', result.message);
        debugPrint('❌ Send message error: ${result.message}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message');
      debugPrint('❌ Send message exception: $e');
    } finally {
      isSending.value = false;
    }
  }

  /// Send an image message
  Future<void> sendImage(File imageFile) async {
    if (_driverId == null) {
      debugPrint('❌ Cannot send image: driver ID not available');
      return;
    }
    if (isSending.value) return;

    isSending.value = true;

    try {
      final result = await ChatService.instance.sendImageMessage(
        chatRoomId: chatRoomId,
        senderId: _driverId!,
        senderRole: 'driver',
        imageFile: imageFile,
      );

      if (result.success) {
        debugPrint('✅ Image sent: ${result.messageId}');
      } else {
        Get.snackbar('Error', result.message);
        debugPrint('❌ Send image error: ${result.message}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send image');
      debugPrint('❌ Send image exception: $e');
    } finally {
      isSending.value = false;
    }
  }

  /// Send a location message (driver's current location)
  Future<void> sendLocation({
    required double latitude,
    required double longitude,
    String? locationName,
  }) async {
    if (_driverId == null) {
      debugPrint('❌ Cannot send location: driver ID not available');
      return;
    }
    if (isSending.value) return;

    isSending.value = true;

    try {
      final result = await ChatService.instance.sendLocationMessage(
        chatRoomId: chatRoomId,
        senderId: _driverId!,
        senderRole: 'driver',
        latitude: latitude,
        longitude: longitude,
        locationName: locationName ?? 'My Current Location',
      );

      if (result.success) {
        debugPrint('✅ Location sent: ${result.messageId}');
      } else {
        Get.snackbar('Error', result.message);
        debugPrint('❌ Send location error: ${result.message}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send location');
      debugPrint('❌ Send location exception: $e');
    } finally {
      isSending.value = false;
    }
  }

  /// Subscribe to real-time message updates
  void _subscribeToMessages() {
    ChatService.instance.subscribeToMessages(
      chatRoomId: chatRoomId,
      onNewMessage: (messageData) {
        final newMessage = DriverChatMessage.fromJson(messageData);
        
        // Avoid duplicates
        if (!messages.any((m) => m.id == newMessage.id)) {
          // Insert at beginning (newest first)
          messages.insert(0, newMessage);
          debugPrint('📨 New message received: ${newMessage.id}');
          
          // Mark as read if from parent
          if (newMessage.senderRole == 'parent') {
            _markAsRead();
          }
        }
      },
    );
  }

  /// Mark messages as read
  Future<void> _markAsRead() async {
    try {
      await ChatService.instance.markMessagesAsRead(
        chatRoomId: chatRoomId,
        readerRole: 'driver',
      );
    } catch (e) {
      debugPrint('⚠️ Mark as read error: $e');
    }
  }

  /// Refresh messages
  @override
  Future<void> refresh() async {
    _hasMore = true;
    _lastMessageId = null;
    await loadMessages();
  }
}
