import 'package:flutter/material.dart';

enum DriverNotificationType { newRequest, childPresent, childAbsent }

class DriverNotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final DateTime time;
  final DriverNotificationType type;

  const DriverNotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
  });

  IconData get icon {
    switch (type) {
      case DriverNotificationType.newRequest:
        return Icons.markunread_mailbox_outlined;
      case DriverNotificationType.childPresent:
        return Icons.verified_outlined;
      case DriverNotificationType.childAbsent:
        return Icons.error_outline;
    }
  }

  static List<DriverNotificationItem> demo() => [
    DriverNotificationItem(
      id: 'dn1',
      title: 'New Request',
      subtitle: 'Request from Sara’s parent',
      time: DateTime.now().subtract(const Duration(minutes: 7)),
      type: DriverNotificationType.newRequest,
    ),
    DriverNotificationItem(
      id: 'dn2',
      title: 'Attendance',
      subtitle: 'Hassan marked present today',
      time: DateTime.now().subtract(const Duration(minutes: 30)),
      type: DriverNotificationType.childPresent,
    ),
    DriverNotificationItem(
      id: 'dn3',
      title: 'Attendance',
      subtitle: 'Mina marked absent today',
      time: DateTime.now().subtract(const Duration(hours: 3)),
      type: DriverNotificationType.childAbsent,
    ),
  ];
}
