import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/auth_service.dart';
import 'package:godropme/services/appwrite/database_constants.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/routes.dart';

/// Notification Service for GoDropMe
///
/// Handles both local notifications (in-app) and push notifications (FCM):
/// - Initialize FCM and local notifications
/// - Register FCM token with Appwrite Messaging
/// - Handle foreground, background, and terminated push notifications
/// - Display local notifications for geofence events
/// - CRUD operations for notifications table
/// - Navigate to appropriate screen on notification tap
class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance =>
      _instance ??= NotificationService._();

  final TablesDB _tablesDB = AppwriteClient.tablesDBService();
  final Messaging _messaging = AppwriteClient.messagingService();
  final _authService = AuthService.instance;

  // Firebase Messaging instance
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // Local Notifications plugin
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Unread count observable for badge
  final RxInt unreadCount = 0.obs;

  NotificationService._();

  // ═══════════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Initialize notification service
  ///
  /// Call this in main() after Firebase initialization:
  /// ```dart
  /// await Firebase.initializeApp();
  /// await NotificationService.instance.initialize();
  /// ```
  /// 
  /// Note: FCM token registration is skipped if no user is logged in.
  /// Call [registerForPushNotifications] after successful login/session restore.
  Future<void> initialize() async {
    try {
      debugPrint('🔔 Initializing NotificationService...');

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Initialize FCM
      await _initializeFCM();

      // Try to register FCM token (will skip if no user logged in)
      await _registerFCMToken();

      debugPrint('✅ NotificationService initialized');
    } catch (e) {
      debugPrint('❌ NotificationService initialization error: $e');
    }
  }

  /// Register for push notifications after user login
  /// 
  /// Call this after successful login or session restore:
  /// ```dart
  /// // After OTP verification
  /// await NotificationService.instance.registerForPushNotifications();
  /// 
  /// // After session restore in splash screen
  /// await NotificationService.instance.registerForPushNotifications();
  /// ```
  /// 
  /// This will:
  /// 1. Store FCM token in users table (for server-side notifications)
  /// 2. Register push target with Appwrite Messaging
  /// 3. Subscribe to role-based and general FCM topics
  Future<void> registerForPushNotifications() async {
    try {
      debugPrint('🔔 Registering for push notifications...');
      await _registerFCMToken();
    } catch (e) {
      debugPrint('❌ Push notification registration error: $e');
    }
  }



  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    // Android notification settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS notification settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channels
    await _createAndroidChannels();

    debugPrint('✅ Local notifications initialized');
  }

  /// Create Android notification channels
  /// 
  /// IMPORTANT: Channel settings (including importance) are LOCKED once created.
  /// If heads-up notifications don't work, user should uninstall and reinstall the app
  /// to recreate channels with the correct importance level.
  Future<void> _createAndroidChannels() async {
    const tripChannel = AndroidNotificationChannel(
      'trip_updates',
      'Trip Updates',
      description: 'Notifications about trip status and driver location',
      importance: Importance.max,  // MAX for heads-up notifications
      sound: RawResourceAndroidNotificationSound('notification'),
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    const serviceChannel = AndroidNotificationChannel(
      'service_requests',
      'Service Requests',
      description: 'Notifications about service requests and acceptances',
      importance: Importance.max,  // MAX for heads-up notifications
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    const messageChannel = AndroidNotificationChannel(
      'messages',
      'Messages',
      description: 'New chat messages',
      importance: Importance.max,  // MAX for heads-up notifications
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    const systemChannel = AndroidNotificationChannel(
      'system',
      'System Notifications',
      description: 'System announcements and alerts',
      importance: Importance.high,  // High for system notifications
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(tripChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(serviceChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(messageChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(systemChannel);

    debugPrint('✅ Android notification channels created');
  }

  /// Initialize Firebase Cloud Messaging
  /// Note: Permission is requested separately via [requestNotificationPermission]
  Future<void> _initializeFCM() async {
    // Check current permission status (don't request here - that's done in splash)
    final settings = await _fcm.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ FCM permission already granted');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('⚠️ FCM permission provisional');
    } else if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      debugPrint('⚠️ FCM permission not yet requested');
    } else {
      debugPrint('❌ FCM permission denied');
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages (requires top-level function)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification tap when app was terminated
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage.data);
    }

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationTap(message.data);
    });

    debugPrint('✅ FCM initialized');
  }

  /// Request notification permission from user
  /// 
  /// Call this from splash screen or a dedicated permission screen.
  /// Returns true if permission was granted.
  /// 
  /// ```dart
  /// final granted = await NotificationService.instance.requestNotificationPermission();
  /// if (granted) {
  ///   // Permission granted, proceed
  /// }
  /// ```
  Future<bool> requestNotificationPermission() async {
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
                      settings.authorizationStatus == AuthorizationStatus.provisional;
      
      if (granted) {
        debugPrint('✅ Notification permission granted');
      } else {
        debugPrint('❌ Notification permission denied');
      }
      
      return granted;
    } catch (e) {
      debugPrint('❌ Error requesting notification permission: $e');
      return false;
    }
  }

  /// Check if notification permission is granted
  Future<bool> hasNotificationPermission() async {
    final settings = await _fcm.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
           settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Register FCM token with Appwrite Messaging
  /// 
  /// This method does three things:
  /// 1. Stores FCM token in users table (for server-side/admin notifications)
  /// 2. Subscribes to FCM topics directly (for Firebase Console/Admin SDK notifications)
  /// 3. Registers push target with Appwrite Account API (for Appwrite Messaging)
  Future<void> _registerFCMToken() async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        debugPrint('⚠️ No user logged in, skipping FCM token registration');
        return;
      }

      // Get FCM token
      final token = await _fcm.getToken();
      if (token == null) {
        debugPrint('❌ Failed to get FCM token');
        return;
      }

      debugPrint('📱 FCM Token: $token');

      // ═══════════════════════════════════════════════════════════════════════
      // DATABASE - Store FCM token in users table
      // This allows server-side functions and admin to send targeted notifications
      // ═══════════════════════════════════════════════════════════════════════
      try {
        await _tablesDB.updateRow(
          databaseId: AppwriteConfig.databaseId,
          tableId: Collections.users,
          rowId: user.$id,
          data: {'fcmToken': token},
        );
        debugPrint('✅ FCM token stored in users table');
      } catch (e) {
        debugPrint('⚠️ Failed to store FCM token in database: $e');
      }

      // ═══════════════════════════════════════════════════════════════════════
      // APPWRITE MESSAGING - Register Push Target
      // This allows Appwrite Messaging to send push notifications to this device
      // ═══════════════════════════════════════════════════════════════════════
      try {
        final account = AppwriteClient.accountService();
        // Use a deterministic target ID based on user ID
        // This ensures we update the same target on re-login rather than creating duplicates
        final targetId = 'fcm_${user.$id}';
        
        await account.createPushTarget(
          targetId: targetId,
          identifier: token,  // The FCM token
          providerId: '692c4a95000ba5c3887d',  // Your FCM provider ID in Appwrite
        );
        debugPrint('✅ Appwrite push target created: $targetId');
        
        // Store target ID for later use (subscribing to topics)
        await LocalStorage.setString(StorageKeys.pushTargetId, targetId);
        
        // Subscribe to Appwrite Messaging topics
        await _subscribeToAppwriteTopics(targetId);
      } on AppwriteException catch (e) {
        if (e.code == 409) {
          // Target already exists - update it
          debugPrint('🔄 Push target already exists, updating...');
          try {
            final account = AppwriteClient.accountService();
            final targetId = 'fcm_${user.$id}';
            await account.updatePushTarget(
              targetId: targetId,
              identifier: token,
            );
            debugPrint('✅ Appwrite push target updated: $targetId');
            
            // Store target ID and subscribe
            await LocalStorage.setString(StorageKeys.pushTargetId, targetId);
            await _subscribeToAppwriteTopics(targetId);
          } catch (updateError) {
            debugPrint('⚠️ Update push target error: $updateError');
          }
        } else {
          debugPrint('⚠️ Create push target error: ${e.message}');
        }
      }

      // ═══════════════════════════════════════════════════════════════════════
      // FCM DIRECT - Subscribe to FCM topics 
      // This allows Firebase Console/Admin SDK to send notifications directly
      // ═══════════════════════════════════════════════════════════════════════
      
      // Subscribe to user-specific topic (userId)
      await _fcm.subscribeToTopic(user.$id);

      // Subscribe to role-specific topic (all_parents or all_drivers)
      final userDoc = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.users,
        rowId: user.$id,
      );

      final role = userDoc.data['role'] as String?;
      if (role == CollectionEnums.roleParent) {
        await _fcm.subscribeToTopic(Topics.allParents);
      } else if (role == CollectionEnums.roleDriver) {
        await _fcm.subscribeToTopic(Topics.allDrivers);
      }

      // Subscribe to general topics
      await _fcm.subscribeToTopic(Topics.tripNotifications);
      await _fcm.subscribeToTopic(Topics.serviceRequests);
      await _fcm.subscribeToTopic(Topics.systemAnnouncements);
      await _fcm.subscribeToTopic(Topics.geofenceAlerts);

      debugPrint('✅ FCM token registered and topics subscribed');

      // Listen for token refresh
      _fcm.onTokenRefresh.listen((newToken) {
        debugPrint('🔄 FCM token refreshed: $newToken');
        // Re-register push target with new token
        _handleTokenRefresh(newToken);
      });
    } catch (e) {
      debugPrint('❌ FCM token registration error: $e');
    }
  }

  /// Handle FCM token refresh - update push target and database with new token
  Future<void> _handleTokenRefresh(String newToken) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;
      
      // Update token in users table
      try {
        await _tablesDB.updateRow(
          databaseId: AppwriteConfig.databaseId,
          tableId: Collections.users,
          rowId: user.$id,
          data: {'fcmToken': newToken},
        );
        debugPrint('✅ FCM token updated in database');
      } catch (e) {
        debugPrint('⚠️ Failed to update FCM token in database: $e');
      }
      
      // Update Appwrite push target
      final account = AppwriteClient.accountService();
      final targetId = 'fcm_${user.$id}';
      
      await account.updatePushTarget(
        targetId: targetId,
        identifier: newToken,
      );
      debugPrint('✅ Push target updated with new token');
    } catch (e) {
      debugPrint('⚠️ Token refresh error: $e');
    }
  }

  /// Subscribe to Appwrite Messaging topics
  /// This allows Appwrite Messaging to send push notifications to this device
  Future<void> _subscribeToAppwriteTopics(String targetId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;
      
      // Get user role
      final userDoc = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.users,
        rowId: user.$id,
      );
      final role = userDoc.data['role'] as String?;
      
      // Subscribe to role-specific Appwrite topic
      if (role == CollectionEnums.roleParent) {
        await _subscribeTargetToTopic(targetId, Topics.allParents);
      } else if (role == CollectionEnums.roleDriver) {
        await _subscribeTargetToTopic(targetId, Topics.allDrivers);
      }
      
      // Subscribe to general topics
      await _subscribeTargetToTopic(targetId, Topics.tripNotifications);
      await _subscribeTargetToTopic(targetId, Topics.serviceRequests);
      await _subscribeTargetToTopic(targetId, Topics.systemAnnouncements);
      await _subscribeTargetToTopic(targetId, Topics.geofenceAlerts);
      
      debugPrint('✅ Subscribed to Appwrite Messaging topics');
    } catch (e) {
      debugPrint('⚠️ Subscribe to Appwrite topics error: $e');
    }
  }

  /// Subscribe a target to an Appwrite Messaging topic
  Future<void> _subscribeTargetToTopic(String targetId, String topicId) async {
    try {
      await _messaging.createSubscriber(
        topicId: topicId,
        subscriberId: ID.unique(),
        targetId: targetId,
      );
      debugPrint('   ✅ Subscribed to topic: $topicId');
    } on AppwriteException catch (e) {
      if (e.code == 409) {
        // Already subscribed
        debugPrint('   ⚠️ Already subscribed to topic: $topicId');
      } else {
        debugPrint('   ❌ Subscribe to $topicId error: ${e.message}');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FCM MESSAGE HANDLERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Handle foreground messages (app is open)
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📨 Foreground message: ${message.messageId}');
    debugPrint('   Title: ${message.notification?.title}');
    debugPrint('   Body: ${message.notification?.body}');
    debugPrint('   Data: ${message.data}');

    // Skip empty/null notifications (sometimes FCM sends empty pings)
    final title = message.notification?.title;
    final body = message.notification?.body;
    if ((title == null || title.isEmpty) && 
        (body == null || body.isEmpty) && 
        message.data.isEmpty) {
      debugPrint('   ⚠️ Skipping empty notification');
      return;
    }

    // Show local notification
    await _showLocalNotification(
      title: title ?? 'New Notification',
      body: body ?? '',
      payload: message.data,
    );

    // Save to database if not already saved
    if (message.data.containsKey('notificationId')) {
      // Already saved by backend
      debugPrint('   ℹ️ Notification already saved by backend');
    } else {
      // Save to database
      await _saveNotificationFromFCM(message);
    }
  }

  /// Save notification from FCM to database
  Future<void> _saveNotificationFromFCM(RemoteMessage message) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      final type =
          message.data['type'] as String? ?? CollectionEnums.notifySystem;
      final title = message.notification?.title ?? 'Notification';
      final body = message.notification?.body ?? '';

      // Get user role from SharedPreferences
      final role =
          await LocalStorage.getString(StorageKeys.userRole) ??
          CollectionEnums.roleParent;

      final result = await createNotification(
        userId: user.$id,
        targetRole: role,
        type: type,
        title: title,
        body: body,
        data: message.data,
      );

      if (result.success) {
        await refreshUnreadCount();
      }
    } catch (e) {
      debugPrint('❌ Save FCM notification error: $e');
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(Map<String, dynamic> data) {
    debugPrint('🔔 Notification tapped: $data');

    final type = data['type'] as String?;
    final targetId = data['targetId'] as String?;

    switch (type) {
      case CollectionEnums.notifyTripStarted:
      case CollectionEnums.notifyDriverArrived:
      case CollectionEnums.notifyChildPicked:
      case CollectionEnums.notifyChildDropped:
        // Navigate to parent/driver home (map screen)
        Get.toNamed(AppRoutes.parentmapScreen);
        break;

      case CollectionEnums.notifyRequestReceived:
        // Navigate to driver map (requests are shown in driver home)
        Get.toNamed(AppRoutes.driverMap);
        break;

      case CollectionEnums.notifyRequestAccepted:
      case CollectionEnums.notifyRequestRejected:
        // Navigate to parent find drivers
        Get.toNamed(AppRoutes.findDrivers);
        break;

      case CollectionEnums.notifyNewMessage:
        // Navigate to chat
        if (targetId != null) {
          Get.toNamed(AppRoutes.parentChat, arguments: {'contactId': targetId});
        }
        break;

      case CollectionEnums.notifySystem:
      default:
        // Navigate to notifications screen
        Get.toNamed(AppRoutes.parentNotifications);
        break;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOCAL NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Show a local notification
  /// 
  /// Uses Importance.max and Priority.max to ensure heads-up (overlay) display.
  /// Per Android docs: https://developer.android.com/guide/topics/ui/notifiers/notifications.html#Heads-up
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    final type = payload?['type'] as String? ?? CollectionEnums.notifySystem;
    final channelId = _getChannelId(type);
    final channelName = _getChannelName(channelId);

    // Strong vibration pattern: [delay, vibrate, pause, vibrate, pause, vibrate]
    // Similar to FCM default vibration
    final vibrationPattern = Int64List.fromList([0, 500, 200, 500, 200, 500]);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'GoDropMe notifications',
      importance: Importance.max,  // MAX importance for heads-up
      priority: Priority.max,      // MAX priority for heads-up
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      vibrationPattern: vibrationPattern,
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload != null ? jsonEncode(payload) : null,
    );
  }

  /// Show geofence notification (driver approaching/arrived)
  Future<void> showGeofenceNotification({
    required String title,
    required String body,
    required String eventType,
    String? tripId,
  }) async {
    await _showLocalNotification(
      title: title,
      body: body,
      payload: {
        'type': CollectionEnums.notifyDriverArrived,
        'eventType': eventType,
        'tripId': tripId,
      },
    );
  }

  /// Get notification channel ID based on type
  String _getChannelId(String type) {
    switch (type) {
      case CollectionEnums.notifyTripStarted:
      case CollectionEnums.notifyDriverArrived:
      case CollectionEnums.notifyChildPicked:
      case CollectionEnums.notifyChildDropped:
        return 'trip_updates';
      case CollectionEnums.notifyRequestReceived:
      case CollectionEnums.notifyRequestAccepted:
      case CollectionEnums.notifyRequestRejected:
        return 'service_requests';
      case CollectionEnums.notifyNewMessage:
        return 'messages';
      default:
        return 'system';
    }
  }

  /// Get channel name from ID
  String _getChannelName(String channelId) {
    switch (channelId) {
      case 'trip_updates':
        return 'Trip Updates';
      case 'service_requests':
        return 'Service Requests';
      case 'messages':
        return 'Messages';
      default:
        return 'System Notifications';
    }
  }

  /// Handle notification tap (local notifications)
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      debugPrint('🔔 Local notification tapped: ${response.payload}');
      try {
        // Parse the JSON payload
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        // Use the existing navigation handler
        _handleNotificationTap(data);
      } catch (e) {
        debugPrint('❌ Error parsing notification payload: $e');
        // Fallback: navigate to notifications screen
        Get.toNamed(AppRoutes.parentNotifications);
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DATABASE OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Create a new notification in database
  ///
  /// Schema: userId, targetRole, title, body, type, payload, isRead
  ///
  /// **IMPORTANT**: [userId] must be the AUTH USER ID from `users` table (NOT the
  /// profile document ID from `parents` or `drivers` table). This is because
  /// `AuthService.currentUser.$id` returns the auth user ID, which is used to
  /// filter notifications when fetching.
  ///
  /// Example:
  /// - Auth User ID (users.$id): `692e7abbae7e562ba007` ← USE THIS
  /// - Parent Profile ID (parents.$id): `693431ee237a45488866` ← NOT this
  ///
  /// ```dart
  /// final result = await NotificationService.instance.createNotification(
  ///   userId: AuthService.instance.currentUser!.$id, // Auth user ID
  ///   targetRole: CollectionEnums.roleParent,
  ///   type: CollectionEnums.notifyTripStarted,
  ///   title: 'Trip Started',
  ///   body: 'Driver is on the way',
  /// );
  /// ```
  Future<NotificationResult> createNotification({
    required String userId, // Must be auth user ID from users table
    required String targetRole, // 'parent' or 'driver'
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final row = await _tablesDB.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.notifications,
        rowId: ID.unique(),
        data: {
          'userId': userId,
          'targetRole': targetRole,
          'type': type,
          'title': title,
          'body': body,
          'payload': data != null ? jsonEncode(data) : null,
          'isRead': false,
        },
      );

      final notification = {'id': row.$id, ...row.data};

      debugPrint('✅ Notification created: ${row.$id} for userId: $userId');

      return NotificationResult.success(
        message: 'Notification created',
        notification: notification,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Create notification error: ${e.message}');
      return NotificationResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Create notification error: $e');
      return NotificationResult.failure('Failed to create notification');
    }
  }

  /// Get all notifications for current user
  ///
  /// Fetches all and filters locally due to Appwrite REST API query limitations
  Future<NotificationListResult> getUserNotifications({
    String? userId,
    bool? isRead,
    int limit = 50,
  }) async {
    try {
      final user = _authService.currentUser;
      final targetUserId = userId ?? user?.$id;

      if (targetUserId == null) {
        debugPrint('⚠️ getUserNotifications: No user authenticated');
        return NotificationListResult.failure('Not authenticated');
      }

      debugPrint('📬 getUserNotifications: Fetching for user $targetUserId');

      // Build queries for server-side filtering
      final queries = <String>[
        Query.equal('userId', targetUserId),  // Filter by userId on server (indexed)
        Query.orderDesc('\$createdAt'),       // Newest first
        Query.limit(limit),                   // Apply limit on server
      ];

      // Add isRead filter if specified
      if (isRead != null) {
        queries.add(Query.equal('isRead', isRead));
      }

      late final RowList result;
      try {
        result = await _tablesDB.listRows(
          databaseId: AppwriteConfig.databaseId,
          tableId: Collections.notifications,
          queries: queries,
        );
      } catch (listError) {
        debugPrint('❌ listRows error: $listError');
        return NotificationListResult.failure('Failed to fetch notifications');
      }

      debugPrint('📬 Fetched ${result.rows.length} notifications for user: $targetUserId');

      // Build notification objects with parsed payload
      final notifications = <Map<String, dynamic>>[];
      for (final row in result.rows) {
        try {
          Map<String, dynamic>? parsedData;
          final payload = row.data['payload'];
          if (payload != null && payload.toString().isNotEmpty) {
            try {
              if (payload is String) {
                parsedData = jsonDecode(payload);
              } else if (payload is Map) {
                parsedData = Map<String, dynamic>.from(payload);
              }
            } catch (_) {}
          }

          notifications.add({
            'id': row.$id,
            'userId': row.data['userId'],
            'targetRole': row.data['targetRole'],
            'title': row.data['title'],
            'body': row.data['body'],
            'type': row.data['type'],
            'data': parsedData,
            'isRead': row.data['isRead'] ?? false,
            'createdAt': row.$createdAt,
          });
        } catch (e) {
          debugPrint('⚠️ Error parsing notification row: $e');
        }
      }

      return NotificationListResult.success(
        notifications: notifications,
        total: notifications.length,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get notifications error: ${e.message}');
      return NotificationListResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Get notifications error: $e');
      return NotificationListResult.failure('Failed to get notifications');
    }
  }

  /// Get unread notification count for current user
  Future<int> getUnreadCount({String? userId}) async {
    try {
      final result = await getUserNotifications(userId: userId, isRead: false);
      return result.success ? result.total : 0;
    } catch (e) {
      debugPrint('❌ Get unread count error: $e');
      return 0;
    }
  }

  /// Refresh and update unread count observable
  Future<void> refreshUnreadCount() async {
    final count = await getUnreadCount();
    unreadCount.value = count;
  }

  /// Mark notification as read
  Future<NotificationResult> markAsRead(String notificationId) async {
    try {
      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.notifications,
        rowId: notificationId,
        data: {'isRead': true},
      );

      // Update unread count
      await refreshUnreadCount();

      return NotificationResult.success(
        message: 'Notification marked as read',
        notification: {'id': row.$id, ...row.data},
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Mark as read error: ${e.message}');
      return NotificationResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Mark as read error: $e');
      return NotificationResult.failure('Failed to mark as read');
    }
  }

  /// Mark all notifications as read for current user
  Future<bool> markAllAsRead({String? userId}) async {
    try {
      final unreadResult = await getUserNotifications(
        userId: userId,
        isRead: false,
      );

      if (!unreadResult.success) return false;

      for (var notification in unreadResult.notifications) {
        await markAsRead(notification['id'] as String);
      }

      return true;
    } catch (e) {
      debugPrint('❌ Mark all as read error: $e');
      return false;
    }
  }

  /// Delete a notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _tablesDB.deleteRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.notifications,
        rowId: notificationId,
      );

      debugPrint('✅ Notification deleted: $notificationId');

      // Update unread count
      await refreshUnreadCount();

      return true;
    } on AppwriteException catch (e) {
      debugPrint('❌ Delete notification error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('❌ Delete notification error: $e');
      return false;
    }
  }

  /// Clear all notifications for current user
  Future<bool> clearAllNotifications({String? userId}) async {
    try {
      final result = await getUserNotifications(userId: userId);
      if (!result.success) return false;

      for (var notification in result.notifications) {
        await deleteNotification(notification['id'] as String);
      }

      return true;
    } catch (e) {
      debugPrint('❌ Clear all notifications error: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // APPWRITE MESSAGING - SUBSCRIBER MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  /// Create a subscriber for push notifications via Appwrite Messaging
  /// This links the user's target (device) to a topic for push notifications
  Future<bool> createAppwriteSubscriber({
    required String topicId,
    required String targetId,
  }) async {
    try {
      await _messaging.createSubscriber(
        topicId: topicId,
        subscriberId: ID.unique(),
        targetId: targetId,
      );
      debugPrint('✅ Appwrite subscriber created for topic: $topicId');
      return true;
    } on AppwriteException catch (e) {
      debugPrint('❌ Create Appwrite subscriber error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('❌ Create Appwrite subscriber error: $e');
      return false;
    }
  }

  /// Delete a subscriber from an Appwrite Messaging topic
  Future<bool> deleteAppwriteSubscriber({
    required String topicId,
    required String subscriberId,
  }) async {
    try {
      await _messaging.deleteSubscriber(
        topicId: topicId,
        subscriberId: subscriberId,
      );
      debugPrint('✅ Appwrite subscriber deleted from topic: $topicId');
      return true;
    } on AppwriteException catch (e) {
      debugPrint('❌ Delete Appwrite subscriber error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('❌ Delete Appwrite subscriber error: $e');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  String _parseError(AppwriteException e) {
    switch (e.code) {
      case 401:
        return 'Unauthorized access';
      case 404:
        return 'Notification not found';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return e.message ?? 'An error occurred';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BACKGROUND MESSAGE HANDLER (Top-level function required by FCM)
// ═══════════════════════════════════════════════════════════════════════════

/// Background message handler (must be top-level function)
/// 
/// This handler is called when:
/// - App is in background (not visible)
/// - App is terminated (not running)
/// 
/// Important: This is a TOP-LEVEL function, so it cannot access instance
/// methods or state. We must initialize the local notifications plugin
/// directly here to show notifications.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📨 Background message received: ${message.messageId}');
  debugPrint('   Title: ${message.notification?.title}');
  debugPrint('   Body: ${message.notification?.body}');
  debugPrint('   Data: ${message.data}');

  // Skip empty/null notifications (sometimes FCM sends empty pings)
  final title = message.notification?.title ?? message.data['title'];
  final body = message.notification?.body ?? message.data['body'];
  if ((title == null || title.isEmpty) && 
      (body == null || body.isEmpty) && 
      message.data.isEmpty) {
    debugPrint('   ⚠️ Skipping empty background notification');
    return;
  }
  
  await _showBackgroundLocalNotification(
    title: title ?? 'New Notification',
    body: body ?? '',
    payload: message.data,
  );
}

/// Show local notification from background handler
/// Must be a top-level function as it's called from background handler
@pragma('vm:entry-point')
Future<void> _showBackgroundLocalNotification({
  required String title,
  required String body,
  Map<String, dynamic>? payload,
}) async {
  try {
    final FlutterLocalNotificationsPlugin localNotifications =
        FlutterLocalNotificationsPlugin();

    // Initialize (simplified for background)
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await localNotifications.initialize(initSettings);

    // Determine channel based on notification type
    final type = payload?['type'] as String? ?? 'system';
    String channelId = 'system';
    String channelName = 'System Notifications';

    if (type.contains('trip') || type.contains('arrived') || 
        type.contains('picked') || type.contains('dropped')) {
      channelId = 'trip_updates';
      channelName = 'Trip Updates';
    } else if (type.contains('request')) {
      channelId = 'service_requests';
      channelName = 'Service Requests';
    } else if (type.contains('message') || type.contains('chat')) {
      channelId = 'messages';
      channelName = 'Messages';
    }

    // Strong vibration pattern: [delay, vibrate, pause, vibrate, pause, vibrate]
    final vibrationPattern = Int64List.fromList([0, 500, 200, 500, 200, 500]);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'GoDropMe notifications',
      importance: Importance.max,   // MAX importance for heads-up
      priority: Priority.max,       // MAX priority for heads-up
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      vibrationPattern: vibrationPattern,
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload != null ? jsonEncode(payload) : null,
    );

    debugPrint('   ✅ Background local notification shown (heads-up)');
  } catch (e) {
    debugPrint('   ❌ Background notification error: $e');
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RESULT CLASSES
// ═══════════════════════════════════════════════════════════════════════════

class NotificationResult {
  final bool success;
  final String? message;
  final Map<String, dynamic>? notification;

  NotificationResult({required this.success, this.message, this.notification});

  factory NotificationResult.success({
    String? message,
    Map<String, dynamic>? notification,
  }) => NotificationResult(
    success: true,
    message: message,
    notification: notification,
  );

  factory NotificationResult.failure(String message) =>
      NotificationResult(success: false, message: message);
}

class NotificationListResult {
  final bool success;
  final String? message;
  final List<Map<String, dynamic>> notifications;
  final int total;

  NotificationListResult({
    required this.success,
    this.message,
    this.notifications = const [],
    this.total = 0,
  });

  factory NotificationListResult.success({
    List<Map<String, dynamic>>? notifications,
    int? total,
  }) => NotificationListResult(
    success: true,
    notifications: notifications ?? [],
    total: total ?? 0,
  );

  factory NotificationListResult.failure(String message) =>
      NotificationListResult(success: false, message: message);
}
