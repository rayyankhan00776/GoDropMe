import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/features/DriverSide/driverChat/models/chat_contact.dart';
import 'package:godropme/services/appwrite/chat_service.dart';
import 'package:godropme/services/appwrite/driver_service.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/database_constants.dart';

/// Controller for driver's chat list screen
/// 
/// Fetches chat rooms from Appwrite and subscribes to real-time updates.
class DriverChatController extends GetxController {
  final contacts = <DriverChatContact>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  
  String? _driverId;
  String? get driverId => _driverId;

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
    await loadChatRooms();
    _subscribeToUpdates();
  }

  /// Load driver ID from driver service
  Future<void> _loadDriverId() async {
    try {
      final result = await DriverService.instance.getDriver();
      if (result.success && result.driverId != null) {
        _driverId = result.driverId;
        debugPrint('✅ Driver ID loaded: $_driverId');
      }
    } catch (e) {
      debugPrint('❌ Load driver ID error: $e');
    }
  }

  /// Load chat rooms from Appwrite backend
  Future<void> loadChatRooms() async {
    if (_driverId == null) {
      debugPrint('⚠️ Driver ID not available, showing empty chat list');
      contacts.clear();
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await ChatService.instance.getDriverChatRooms(
        driverId: _driverId!,
      );

      if (result.success) {
        final enrichedContacts = <DriverChatContact>[];
        
        for (final room in result.chatRooms) {
          // Fetch parent name for each chat room
          String parentName = 'Parent';
          String? avatarUrl;
          
          try {
            if (room['parentId'] != null) {
              final tablesDB = AppwriteClient.tablesDBService();
              final parentRow = await tablesDB.getRow(
                databaseId: AppwriteConfig.databaseId,
                tableId: Collections.parents,
                rowId: room['parentId'],
              );
              parentName = parentRow.data['fullName']?.toString() ?? 'Parent';
              avatarUrl = parentRow.data['profilePhotoUrl']?.toString();
            }
          } catch (e) {
            debugPrint('⚠️ Could not fetch parent info: $e');
          }

          enrichedContacts.add(DriverChatContact(
            id: room['id'] ?? room['\$id'],
            parentId: room['parentId'] ?? '',
            name: parentName,
            avatarUrl: avatarUrl,
            lastMessage: room['lastMessage']?.toString(),
            lastMessageAt: room['lastMessageAt'] != null
                ? DateTime.tryParse(room['lastMessageAt'].toString())
                : null,
            unreadCount: (room['driverUnreadCount'] as num?)?.toInt() ?? 0,
          ));
        }

        contacts.assignAll(enrichedContacts);
        debugPrint('✅ Loaded ${contacts.length} chat rooms for driver');
      } else {
        errorMessage.value = result.message ?? 'Failed to load chats';
        debugPrint('❌ Load chat rooms error: ${result.message}');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load chats. Please try again.';
      debugPrint('❌ Load chat rooms exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Subscribe to real-time chat room updates
  void _subscribeToUpdates() {
    if (_driverId == null) return;

    ChatService.instance.subscribeToChatRooms(
      userId: _driverId!,
      userRole: 'driver',
      onChatRoomUpdate: (roomData) {
        // Find and update the chat room in the list
        final index = contacts.indexWhere((c) => c.id == roomData['id']);
        if (index >= 0) {
          // Update existing room
          final existing = contacts[index];
          contacts[index] = DriverChatContact(
            id: existing.id,
            parentId: existing.parentId,
            name: existing.name,
            avatarUrl: existing.avatarUrl,
            lastMessage: roomData['lastMessage']?.toString() ?? existing.lastMessage,
            lastMessageAt: roomData['lastMessageAt'] != null
                ? DateTime.tryParse(roomData['lastMessageAt'].toString())
                : existing.lastMessageAt,
            unreadCount: (roomData['driverUnreadCount'] as num?)?.toInt() ?? existing.unreadCount,
          );
          
          // Re-sort by last message time
          contacts.sort((a, b) {
            if (a.lastMessageAt == null && b.lastMessageAt == null) return 0;
            if (a.lastMessageAt == null) return 1;
            if (b.lastMessageAt == null) return -1;
            return b.lastMessageAt!.compareTo(a.lastMessageAt!);
          });
        } else {
          // New chat room - reload the list
          loadChatRooms();
        }
      },
    );
  }

  /// Refresh chat rooms (pull to refresh)
  @override
  Future<void> refresh() async {
    await loadChatRooms();
  }
}
