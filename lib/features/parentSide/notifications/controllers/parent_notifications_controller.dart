import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/features/parentSide/notifications/models/parent_notification.dart';
import 'package:godropme/services/appwrite/notification_service.dart';

class ParentNotificationsController extends GetxController {
  final notifications = <ParentNotificationItem>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    // Subscribe to realtime notifications
    _subscribeToNotifications();
  }

  /// Load notifications from backend
  Future<void> loadNotifications() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await NotificationService.instance.getUserNotifications();

      if (result.success) {
        final items = result.notifications
            .map((json) => ParentNotificationItem.fromJson(json))
            .toList();
        notifications.assignAll(items);
        debugPrint('✅ Loaded ${items.length} parent notifications');
      } else {
        errorMessage.value = result.message ?? 'Failed to load notifications';
        debugPrint('❌ Load notifications error: ${result.message}');
      }
    } catch (e) {
      errorMessage.value = 'Error loading notifications';
      debugPrint('❌ Load notifications exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Subscribe to realtime notification updates
  void _subscribeToNotifications() {
    NotificationService.instance.subscribeToNotifications(
      onNotification: (data) {
        // Add new notification to top of list
        final item = ParentNotificationItem.fromJson(data);
        notifications.insert(0, item);
        debugPrint('📨 New notification received: ${item.title}');
      },
    );
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final result = await NotificationService.instance.markAsRead(notificationId);
    if (result.success) {
      // Update local state
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final old = notifications[index];
        notifications[index] = ParentNotificationItem(
          id: old.id,
          userId: old.userId,
          title: old.title,
          body: old.body,
          time: old.time,
          type: old.type,
          data: old.data,
          isRead: true,
        );
      }
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final success = await NotificationService.instance.markAllAsRead();
    if (success) {
      // Reload to get updated state
      await loadNotifications();
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    final success = await NotificationService.instance.deleteNotification(notificationId);
    if (success) {
      notifications.removeWhere((n) => n.id == notificationId);
    }
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    final success = await NotificationService.instance.clearAllNotifications();
    if (success) {
      notifications.clear();
    }
  }

  /// Refresh notifications
  Future<void> refresh() => loadNotifications();

  @override
  void onClose() {
    NotificationService.instance.unsubscribe();
    super.onClose();
  }
}
