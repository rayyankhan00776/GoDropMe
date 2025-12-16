// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/features/parentSide/common_widgets/parent_drawer_shell.dart';
import 'package:godropme/features/parentSide/notifications/controllers/parent_notifications_controller.dart';
import 'package:godropme/features/parentSide/common_widgets/drawer widgets/drawer_card.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/theme/colors.dart';

class ParentsNotificationScreen extends StatelessWidget {
  const ParentsNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ParentNotificationsController>();

    return ParentDrawerShell(
      body: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Space under top overlay buttons
                SizedBox(height: Responsive.scaleClamped(context, 60, 48, 72)),

                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Notifications', style: AppTypography.titleLarge),
                      Obx(() => controller.notifications.isNotEmpty
                        ? TextButton.icon(
                            onPressed: () => controller.markAllAsRead(),
                            icon: const Icon(Icons.done_all, size: 18),
                            label: const Text('Mark all read'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                            ),
                          )
                        : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Obx(() {
                    // Loading state
                    if (controller.isLoading.value && controller.notifications.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    // Error state
                    if (controller.errorMessage.isNotEmpty && controller.notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppColors.gray,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              controller.errorMessage.value,
                              style: const TextStyle(color: AppColors.darkGray),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => controller.refresh(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    // Empty state
                    if (controller.notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 64,
                              color: AppColors.gray.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No notifications yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.darkGray,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "You'll see trip updates and service requests here",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.gray,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    // Notifications list with pull-to-refresh
                    return RefreshIndicator(
                      onRefresh: () => controller.refresh(),
                      color: AppColors.primary,
                      child: ListView.separated(
                        itemCount: controller.notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = controller.notifications[index];
                          return Dismissible(
                            key: Key(item.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) => controller.deleteNotification(item.id),
                            child: DrawerCard(
                              child: ListTile(
                                onTap: () {
                                  if (!item.isRead) {
                                    controller.markAsRead(item.id);
                                  }
                                },
                                leading: CircleAvatar(
                                  backgroundColor: item.isRead 
                                    ? AppColors.lightGray
                                    : AppColors.primary.withValues(alpha: 0.12),
                                  child: Icon(
                                    item.icon,
                                    color: item.isRead 
                                      ? AppColors.gray 
                                      : AppColors.primary,
                                  ),
                                ),
                                title: Text(
                                  item.title,
                                  style: TextStyle(
                                    fontWeight: item.isRead 
                                      ? FontWeight.w500 
                                      : FontWeight.w600,
                                    color: item.isRead 
                                      ? AppColors.darkGray 
                                      : AppColors.black,
                                  ),
                                ),
                                subtitle: Text(
                                  item.subtitle,
                                  style: const TextStyle(color: AppColors.darkGray),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatTime(item.time),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.gray,
                                      ),
                                    ),
                                    if (!item.isRead)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatTime(DateTime time) {
  final now = DateTime.now();
  final diff = now.difference(time);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
