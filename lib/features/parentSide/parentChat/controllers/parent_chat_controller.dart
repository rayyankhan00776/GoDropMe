import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/features/parentSide/parentChat/models/chat_contact.dart';
import 'package:godropme/features/parentSide/parentProfile/controllers/parent_profile_controller.dart';
import 'package:godropme/services/appwrite/chat_service.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/database_constants.dart';
import 'package:godropme/services/appwrite/parent_service.dart';

/// Controller for parent's chat list screen
/// 
/// Fetches chat rooms from Appwrite and subscribes to real-time updates.
class ParentChatController extends GetxController {
  final contacts = <ParentChatContact>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  
  String? _parentId;
  String? get parentId => _parentId;

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
    await loadChatRooms();
    _subscribeToUpdates();
  }

  /// Load parent ID from profile controller or directly from service
  Future<void> _loadParentId() async {
    try {
      // Try to get from ParentProfileController if registered
      if (Get.isRegistered<ParentProfileController>()) {
        final profileCtrl = Get.find<ParentProfileController>();
        
        // Wait for profile to finish loading if in progress
        while (profileCtrl.isLoading.value) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        
        _parentId = profileCtrl.parentId;
        
        // If still null, try loading profile
        if (_parentId == null) {
          await profileCtrl.loadProfile();
          _parentId = profileCtrl.parentId;
        }
      }
      
      // If still null, directly query the parent service
      if (_parentId == null) {
        debugPrint('🔄 ParentProfileController not available, querying ParentService directly...');
        final result = await ParentService.instance.getParent();
        if (result.success && result.parent != null) {
          _parentId = result.parent!.id;
          debugPrint('✅ Parent ID loaded from service: $_parentId');
        }
      }
      
      debugPrint('✅ Parent ID loaded: $_parentId');
    } catch (e) {
      debugPrint('❌ Load parent ID error: $e');
    }
  }

  /// Refresh chat rooms (force reload with parent ID)
  Future<void> refreshChatRooms() async {
    _parentId = null; // Reset to force reload
    await _loadParentId();
    await loadChatRooms();
  }

  /// Load chat rooms from Appwrite backend
  Future<void> loadChatRooms() async {
    if (_parentId == null) {
      // Try to load parent ID first
      await _loadParentId();
      
      if (_parentId == null) {
        debugPrint('⚠️ Parent ID not available, showing empty chat list');
        contacts.clear();
        return;
      }
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await ChatService.instance.getParentChatRooms(
        parentId: _parentId!,
      );

      if (result.success) {
        final enrichedContacts = <ParentChatContact>[];
        
        for (final room in result.chatRooms) {
          // Fetch driver name for each chat room
          String driverName = 'Driver';
          String? avatarUrl;
          
          try {
            if (room['driverId'] != null) {
              final tablesDB = AppwriteClient.tablesDBService();
              final driverRow = await tablesDB.getRow(
                databaseId: AppwriteConfig.databaseId,
                tableId: Collections.drivers,
                rowId: room['driverId'],
              );
              driverName = driverRow.data['fullName']?.toString() ?? 'Driver';
              avatarUrl = driverRow.data['profilePhotoUrl']?.toString();
            }
          } catch (e) {
            debugPrint('⚠️ Could not fetch driver info: $e');
          }

          enrichedContacts.add(ParentChatContact(
            id: room['id'] ?? room['\$id'],
            driverId: room['driverId'] ?? '',
            name: driverName,
            avatarUrl: avatarUrl,
            lastMessage: room['lastMessage']?.toString(),
            lastMessageAt: room['lastMessageAt'] != null
                ? DateTime.tryParse(room['lastMessageAt'].toString())
                : null,
            unreadCount: (room['parentUnreadCount'] as num?)?.toInt() ?? 0,
          ));
        }

        contacts.assignAll(enrichedContacts);
        debugPrint('✅ Loaded ${contacts.length} chat rooms');
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
    if (_parentId == null) return;

    ChatService.instance.subscribeToChatRooms(
      userId: _parentId!,
      userRole: 'parent',
      onChatRoomUpdate: (roomData) {
        // Find and update the chat room in the list
        final index = contacts.indexWhere((c) => c.id == roomData['id']);
        if (index >= 0) {
          // Update existing room
          final existing = contacts[index];
          contacts[index] = ParentChatContact(
            id: existing.id,
            driverId: existing.driverId,
            name: existing.name,
            avatarUrl: existing.avatarUrl,
            lastMessage: roomData['lastMessage']?.toString() ?? existing.lastMessage,
            lastMessageAt: roomData['lastMessageAt'] != null
                ? DateTime.tryParse(roomData['lastMessageAt'].toString())
                : existing.lastMessageAt,
            unreadCount: (roomData['parentUnreadCount'] as num?)?.toInt() ?? existing.unreadCount,
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
    await refreshChatRooms();
  }
}
