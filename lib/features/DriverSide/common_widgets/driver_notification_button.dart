// Glassy Notification Button widget for driver side
// ignore_for_file: deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/services/appwrite/notification_service.dart';
import 'package:godropme/theme/colors.dart';

class DriverGlassNotificationButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final double size;
  final double borderRadius;
  final Color iconColor;
  final IconData icon;

  const DriverGlassNotificationButton({
    super.key,
    this.onPressed,
    this.size = 45,
    this.borderRadius = 8,
    this.iconColor = AppColors.white,
    this.icon = Icons.notifications_none_rounded,
  });

  @override
  State<DriverGlassNotificationButton> createState() => _DriverGlassNotificationButtonState();
}

class _DriverGlassNotificationButtonState extends State<DriverGlassNotificationButton> {
  @override
  void initState() {
    super.initState();
    // Refresh unread count when widget loads
    NotificationService.instance.refreshUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0, sigmaY: 1),
        child: Container(
          height: widget.size,
          width: widget.size,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.9),
            border: Border.all(
              color: AppColors.primaryDark.withValues(alpha: 0.8),
              width: 0.6,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: Stack(
            children: [
              IconButton(
                icon: Icon(widget.icon, color: widget.iconColor, size: 26),
                onPressed: widget.onPressed,
                tooltip: 'Notifications',
              ),
              // Badge for unread count
              Obx(() {
                final count = NotificationService.instance.unreadCount.value;
                if (count == 0) return const SizedBox.shrink();
                return Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    alignment: Alignment.center,
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      count > 9 ? '9+' : count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
