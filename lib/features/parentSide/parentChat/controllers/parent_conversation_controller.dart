import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/features/parentSide/parentChat/models/chat_message.dart';
import 'package:godropme/features/parentSide/parentProfile/controllers/parent_profile_controller.dart';
import 'package:godropme/services/appwrite/chat_service.dart';
import 'package:godropme/services/appwrite/parent_service.dart';

/// Controller for parent's conversation screen
/// 
/// Handles sending/receiving messages with real-time updates.
class ParentConversationController extends GetxController {
  final String chatRoomId;
  final messages = <ParentChatMessage>[].obs;
  final isLoading = false.obs;
  final isSending = false.obs;
  final errorMessage = ''.obs;
  
  String? _parentId;
  String? get parentId => _parentId;
  
  bool _hasMore = true;
  String? _lastMessageId;

  ParentConversationController(this.chatRoomId);

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
    await _loadParentId();
    await loadMessages();
    _subscribeToMessages();
    _markAsRead();
  }

  /// Load parent ID from profile controller or fallback to ParentService
  Future<void> _loadParentId() async {
    try {
      // Try from profile controller first
      if (Get.isRegistered<ParentProfileController>()) {
        final profileCtrl = Get.find<ParentProfileController>();
        _parentId = profileCtrl.parentId;
      }
      
      // Fallback: Query ParentService directly if controller not available or parentId null
      if (_parentId == null) {
        debugPrint('🔄 Fetching parent ID from ParentService...');
        final result = await ParentService.instance.getParent();
        if (result.success && result.parent != null) {
          _parentId = result.parent!.id;
          debugPrint('✅ Parent ID loaded from service: $_parentId');
        }
      }
      
      debugPrint('✅ Parent ID for conversation: $_parentId');
    } catch (e) {
      debugPrint('❌ Load parent ID error: $e');
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
        final newMessages = result.messages.map((data) => ParentChatMessage.fromJson(data)).toList();
        
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
    if (_parentId == null) {
      debugPrint('❌ Cannot send message: parent ID not available');
      return;
    }
    if (isSending.value) return;

    isSending.value = true;

    try {
      final result = await ChatService.instance.sendTextMessage(
        chatRoomId: chatRoomId,
        senderId: _parentId!,
        senderRole: 'parent',
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
    if (_parentId == null) {
      debugPrint('❌ Cannot send image: parent ID not available');
      return;
    }
    if (isSending.value) return;

    isSending.value = true;

    try {
      final result = await ChatService.instance.sendImageMessage(
        chatRoomId: chatRoomId,
        senderId: _parentId!,
        senderRole: 'parent',
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

  /// Send a location message
  Future<void> sendLocation({
    required double latitude,
    required double longitude,
    String? locationName,
  }) async {
    if (_parentId == null) {
      debugPrint('❌ Cannot send location: parent ID not available');
      return;
    }
    if (isSending.value) return;

    isSending.value = true;

    try {
      final result = await ChatService.instance.sendLocationMessage(
        chatRoomId: chatRoomId,
        senderId: _parentId!,
        senderRole: 'parent',
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
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
        final newMessage = ParentChatMessage.fromJson(messageData);
        
        // Avoid duplicates
        if (!messages.any((m) => m.id == newMessage.id)) {
          // Insert at beginning (newest first)
          messages.insert(0, newMessage);
          debugPrint('📨 New message received: ${newMessage.id}');
          
          // Mark as read if from driver
          if (newMessage.senderRole == 'driver') {
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
        readerRole: 'parent',
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
