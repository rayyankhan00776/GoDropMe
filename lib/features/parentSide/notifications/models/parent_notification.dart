import 'package:flutter/material.dart';

enum ParentNotificationType { pickup, dropoff, requestAccepted }

class ParentNotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final DateTime time;
  final ParentNotificationType type;

  const ParentNotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.type,
  });

  IconData get icon {
    switch (type) {
      case ParentNotificationType.pickup:
        return Icons.directions_bus_outlined;
      case ParentNotificationType.dropoff:
        return Icons.home_outlined;
      case ParentNotificationType.requestAccepted:
        return Icons.check_circle_outline;
    }
  }

  static List<ParentNotificationItem> demo() => [
    ParentNotificationItem(
      id: 'pn1',
      title: 'Picked Up',
      subtitle: 'Driver Ali picked Ayesha from home',
      time: DateTime.now().subtract(const Duration(minutes: 12)),
      type: ParentNotificationType.pickup,
    ),
    ParentNotificationItem(
      id: 'pn2',
      title: 'Dropped Off',
      subtitle: 'Ayesha reached school safely',
      time: DateTime.now().subtract(const Duration(minutes: 48)),
      type: ParentNotificationType.dropoff,
    ),
    ParentNotificationItem(
      id: 'pn3',
      title: 'Request Accepted',
      subtitle: 'Driver Bilal accepted your request',
      time: DateTime.now().subtract(const Duration(hours: 2, minutes: 5)),
      type: ParentNotificationType.requestAccepted,
    ),
  ];
}
