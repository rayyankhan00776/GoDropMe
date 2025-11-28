import 'package:flutter/material.dart';

/// Notification types matching Appwrite `notifications.type` enum.
/// Values: trip_started, driver_arrived, child_picked, child_dropped,
///         request_received, request_accepted, request_rejected, new_message, system
enum ParentNotificationType {
  tripStarted,
  driverArrived,
  childPicked,
  childDropped,
  requestAccepted,
  requestRejected,
  newMessage,
  system,
}

/// Parent notification model matching Appwrite `notifications` collection.
class ParentNotificationItem {
  final String id; // notifications.$id
  final String userId; // Target user auth ID
  final String title;
  final String body; // renamed from subtitle to match schema
  final DateTime time; // $createdAt
  final ParentNotificationType type;
  final Map<String, dynamic>? data; // JSON payload for navigation
  final bool isRead;

  const ParentNotificationItem({
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
    'targetRole': 'parent',
    'title': title,
    'body': body,
    'type': _typeToString(type),
    'data': data?.toString(),
    'isRead': isRead,
  };

  static String _typeToString(ParentNotificationType type) {
    switch (type) {
      case ParentNotificationType.tripStarted:
        return 'trip_started';
      case ParentNotificationType.driverArrived:
        return 'driver_arrived';
      case ParentNotificationType.childPicked:
        return 'child_picked';
      case ParentNotificationType.childDropped:
        return 'child_dropped';
      case ParentNotificationType.requestAccepted:
        return 'request_accepted';
      case ParentNotificationType.requestRejected:
        return 'request_rejected';
      case ParentNotificationType.newMessage:
        return 'new_message';
      case ParentNotificationType.system:
        return 'system';
    }
  }

  static ParentNotificationType _typeFromString(String? typeStr) {
    switch (typeStr) {
      case 'trip_started':
        return ParentNotificationType.tripStarted;
      case 'driver_arrived':
        return ParentNotificationType.driverArrived;
      case 'child_picked':
        return ParentNotificationType.childPicked;
      case 'child_dropped':
        return ParentNotificationType.childDropped;
      case 'request_accepted':
        return ParentNotificationType.requestAccepted;
      case 'request_rejected':
        return ParentNotificationType.requestRejected;
      case 'new_message':
        return ParentNotificationType.newMessage;
      case 'system':
        return ParentNotificationType.system;
      default:
        return ParentNotificationType.system;
    }
  }

  /// Create from backend JSON
  factory ParentNotificationItem.fromJson(Map<String, dynamic> json) => ParentNotificationItem(
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
      case ParentNotificationType.tripStarted:
        return Icons.directions_car_outlined;
      case ParentNotificationType.driverArrived:
        return Icons.location_on_outlined;
      case ParentNotificationType.childPicked:
        return Icons.directions_bus_outlined;
      case ParentNotificationType.childDropped:
        return Icons.home_outlined;
      case ParentNotificationType.requestAccepted:
        return Icons.check_circle_outline;
      case ParentNotificationType.requestRejected:
        return Icons.cancel_outlined;
      case ParentNotificationType.newMessage:
        return Icons.message_outlined;
      case ParentNotificationType.system:
        return Icons.info_outline;
    }
  }

  static List<ParentNotificationItem> demo() => [
    ParentNotificationItem(
      id: 'pn1',
      userId: 'user_1',
      title: 'Driver Arrived',
      body: 'Driver Ali has arrived at your location',
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      type: ParentNotificationType.driverArrived,
    ),
    ParentNotificationItem(
      id: 'pn2',
      userId: 'user_1',
      title: 'Child Picked Up',
      body: 'Ayesha has been picked up by Driver Ali',
      time: DateTime.now().subtract(const Duration(minutes: 12)),
      type: ParentNotificationType.childPicked,
    ),
    ParentNotificationItem(
      id: 'pn3',
      userId: 'user_1',
      title: 'Child Dropped Off',
      body: 'Ayesha reached school safely',
      time: DateTime.now().subtract(const Duration(minutes: 48)),
      type: ParentNotificationType.childDropped,
    ),
    ParentNotificationItem(
      id: 'pn4',
      userId: 'user_1',
      title: 'Request Accepted',
      body: 'Driver Bilal accepted your service request',
      time: DateTime.now().subtract(const Duration(hours: 2, minutes: 5)),
      type: ParentNotificationType.requestAccepted,
    ),
  ];
}
