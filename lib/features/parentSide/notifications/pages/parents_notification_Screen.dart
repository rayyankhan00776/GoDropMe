// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/features/parentSide/common widgets/parent_drawer_shell.dart';
import 'package:godropme/features/parentSide/notifications/controllers/parent_notifications_controller.dart';
import 'package:godropme/features/parentSide/common widgets/drawer widgets/drawer_card.dart';
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
                  child: Text('Notifications', style: AppTypography.titleLarge),
                ),

                Expanded(
                  child: Obx(
                    () => ListView.separated(
                      itemCount: controller.notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = controller.notifications[index];
                        return DrawerCard(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.12,
                              ),
                              child: Icon(item.icon, color: AppColors.primary),
                            ),
                            title: Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              item.subtitle,
                              style: const TextStyle(color: AppColors.darkGray),
                            ),
                            trailing: Text(
                              _formatTime(item.time),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.gray,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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
