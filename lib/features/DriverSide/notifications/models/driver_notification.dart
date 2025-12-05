import 'package:flutter/material.dart';

/// Notification types matching Appwrite `notifications.type` enum.
/// Values: trip_started, driver_arrived, child_picked, child_dropped,
///         request_received, request_accepted, request_rejected, new_message, system
enum DriverNotificationType {
  requestReceived,
  requestCancelled,
  childPresent,
  childAbsent,
  newMessage,
  system,
}

/// Driver notification model matching Appwrite `notifications` collection.
class DriverNotificationItem {
  final String id; // notifications.\$id
  final String userId; // Target user auth ID
  final String title;
  final String body; // renamed from subtitle to match schema
  final DateTime time; // \$createdAt
  final DriverNotificationType type;
  final Map<String, dynamic>? data; // JSON payload for navigation
  final bool isRead;

  const DriverNotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.data,
    this.isRead = false,
  });

  /// Convenience getter for backwards compatibility
  String get subtitle => body;

  /// Convert to JSON for backend storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'targetRole': 'driver',
    'title': title,
    'body': body,
    'type': _typeToString(type),
    'data': data?.toString(),
    'isRead': isRead,
  };

  static String _typeToString(DriverNotificationType type) {
    switch (type) {
      case DriverNotificationType.requestReceived:
        return 'request_received';
      case DriverNotificationType.requestCancelled:
        return 'request_cancelled';
      case DriverNotificationType.childPresent:
        return 'child_present';
      case DriverNotificationType.childAbsent:
        return 'child_absent';
      case DriverNotificationType.newMessage:
        return 'new_message';
      case DriverNotificationType.system:
        return 'system';
    }
  }

  static DriverNotificationType _typeFromString(String? typeStr) {
    switch (typeStr) {
      case 'request_received':
        return DriverNotificationType.requestReceived;
      case 'request_cancelled':
        return DriverNotificationType.requestCancelled;
      case 'child_present':
        return DriverNotificationType.childPresent;
      case 'child_absent':
        return DriverNotificationType.childAbsent;
      case 'new_message':
        return DriverNotificationType.newMessage;
      case 'system':
        return DriverNotificationType.system;
      default:
        return DriverNotificationType.system;
    }
  }

  /// Create from backend JSON
  factory DriverNotificationItem.fromJson(Map<String, dynamic> json) => DriverNotificationItem(
    id: json['\$id']?.toString() ?? json['id']?.toString() ?? '',
    userId: json['userId']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    body: json['body']?.toString() ?? json['subtitle']?.toString() ?? '',
    time: DateTime.tryParse(json['\$createdAt']?.toString() ?? json['time']?.toString() ?? '') ?? DateTime.now(),
    type: _typeFromString(json['type']?.toString()),
    data: json['data'] is Map ? json['data'] as Map<String, dynamic> : null,
    isRead: json['isRead'] == true,
  );

  IconData get icon {
    switch (type) {
      case DriverNotificationType.requestReceived:
        return Icons.markunread_mailbox_outlined;
      case DriverNotificationType.requestCancelled:
        return Icons.cancel_outlined;
      case DriverNotificationType.childPresent:
        return Icons.verified_outlined;
      case DriverNotificationType.childAbsent:
        return Icons.error_outline;
      case DriverNotificationType.newMessage:
        return Icons.message_outlined;
      case DriverNotificationType.system:
        return Icons.info_outline;
    }
  }

  static List<DriverNotificationItem> demo() => [
    DriverNotificationItem(
      id: 'dn1',
      userId: 'driver_1',
      title: 'New Service Request',
      body: "Request from Sara's parent for pickup service",
      time: DateTime.now().subtract(const Duration(minutes: 7)),
      type: DriverNotificationType.requestReceived,
    ),
    DriverNotificationItem(
      id: 'dn2',
      userId: 'driver_1',
      title: 'Attendance Update',
      body: 'Hassan marked present for today',
      time: DateTime.now().subtract(const Duration(minutes: 30)),
      type: DriverNotificationType.childPresent,
    ),
    DriverNotificationItem(
      id: 'dn3',
      userId: 'driver_1',
      title: 'Attendance Update',
      body: 'Mina marked absent for today',
      time: DateTime.now().subtract(const Duration(hours: 3)),
      type: DriverNotificationType.childAbsent,
    ),
  ];
}
