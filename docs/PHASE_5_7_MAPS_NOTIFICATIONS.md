# 📍🔔 Phase 5 & 7: Maps + Real-time Tracking + Notifications

> **Project**: GoDropMe - School Children Transportation App  
> **Created**: December 10, 2025  
> **Priority**: HIGH  
> **Status**: IN PROGRESS

---

## 🎯 Overview

This document tracks the completion of:
1. **Phase 5 Remaining**: Real-time maps, location tracking, geofencing UI
2. **Phase 7**: Push notifications via FCM + in-app notification UI

### Current Status

✅ **COMPLETED**:
- Appwrite Functions: `generate-morning-trips`, `generate-afternoon-trips`, `process-geofence`
- Services: `TripService`, `GeofenceService`, `DriverLocationService`, `TripTrackingService`
- Firebase integration in Appwrite Messaging
- `flutter_local_notifications` package added
- `firebase_messaging` package added
- Driver online/offline toggle with trip status updates
- Basic map screens for Parent and Driver

⚠️ **IN PROGRESS**:
- Real-time driver location updates on parent map
- Real-time trip tracking with markers
- Geofence notifications (local + push)
- Complete notification service layer

---

## 📋 Task Breakdown

### 🗺️ SECTION 1: Parent Map Enhancements

#### Task 1.1: Update ParentMapController - Real-time Trip Tracking
**Status**: ✅ COMPLETED (Dec 10, 2025)  
**File**: `lib/features/parentSide/parentHome/controllers/parent_map_controller.dart`

**Implementation Summary**:
✅ Added import statements for TripService, TripTrackingService, AuthService
✅ Added activeTrips observable list
✅ Created loadActiveTrips() method using TripService.getParentTrips()
✅ Created _loadMarkersFromTrips() method to show pickup, dropoff, and driver markers
✅ Created subscribeToTripUpdates() using TripTrackingService
✅ Created updateDriverMarker() for real-time location updates
✅ Created updateTripStatus() for status changes
✅ Added _getStatusMessage() helper for user-friendly status text
✅ Added _fitMarkersOnMap() for auto-zoom calculations
✅ Updated refreshMarkers() to reload from backend
✅ Added subscription cleanup in onClose()
✅ All compile errors resolved - READY FOR TESTING
   - Filter for active statuses: `driver_enroute`, `arrived`, `picked`, `in_transit`
   - Store active trips in observable list: `final activeTrips = <Trip>[].obs`

2. **Subscribe to Real-time Location Updates**:
   - Use `TripTrackingService.subscribeToTrip()` for each active trip
   - Update driver marker position when `onLocationUpdate` callback fires
   - Update trip status when `onStatusChange` callback fires
   - Clear subscription when trip completes (`onTripCompleted`)

3. **Dynamic Marker Management**:
   - **Home markers**: Show all children's home locations (pickup points)
   - **School markers**: Show unique schools from active trips
   - **Driver markers**: Show real-time driver location for each active trip
   - Update marker info windows with trip status and ETA

4. **Camera Management**:
   - Auto-zoom to fit all active markers on map load
   - Animate camera to driver when trip status changes
   - Show polyline route from driver → target location (optional)

**Implementation Checklist**:
- [ ] Add `activeTrips` observable list
- [ ] Create `loadActiveTrips()` method using `TripService`
- [ ] Create `subscribeToTripUpdates()` method using `TripTrackingService`
- [ ] Create `updateDriverMarker(tripId, location)` method
- [ ] Create `updateTripStatus(tripId, status)` method
- [ ] Update `_loadMarkers()` to use real trip data
- [ ] Add `fitMarkersOnMap()` for auto-zoom
- [ ] Handle subscription cleanup in `onClose()`

**Testing Checklist**:
- [ ] Verify trips load on map init
- [ ] Verify driver marker moves in real-time (test with simulator)
- [ ] Verify status changes trigger marker updates
- [ ] Verify map auto-zooms to show all trips
- [ ] Verify subscriptions clean up on screen exit

---

#### Task 1.2: Update ParentMapScreen UI
**Status**: ✅ COMPLETED (Dec 10, 2025)  
**File**: `lib/features/parentSide/parentHome/pages/parent_map_screen.dart`

**Implementation Summary**:
✅ Added loading overlay with "Loading trips..." message
✅ Added error message banner at top (dismissible)
✅ Added empty state card when no trips exist
✅ Created _TripStatusCard widget (bottom sheet) showing:
  - Status badge with color coding
  - Child name and trip type
  - Driver name and vehicle type
  - Pickup and dropoff locations
  - Clean address display
✅ Added _RoutePoint widget for pickup/dropoff display
✅ Added refresh button (top-right) to reload trips
✅ Status color coding (grey/orange/blue/purple/teal/green/red)
✅ Smooth animations and gestures
✅ All compile errors resolved - READY FOR TESTING

---

### 🚗 SECTION 2: Driver Map Enhancements

#### Task 2.1: Update DriverHomeController - Active Trip Markers
**Status**: ✅ COMPLETED (Dec 10, 2025)  
**File**: `lib/features/DriverSide/driverHome/controllers/driver_home_controller.dart`

**Implementation Summary**:
✅ Added imports for ActiveServiceService, ChildService, AuthService, SchoolsLoader
✅ Created loadActiveServices() method to fetch active services from backend
✅ Created _loadChildrenFromServices() to load child details for each service
✅ Integrated SchoolsLoader to get school details and locations
✅ Updated _loadMarkers() to use real children data from backend
✅ Proper coordinate handling ([lng, lat] to LatLng)
✅ Error handling for each child loading step
✅ Updated refreshMarkers() to reload from backend
✅ All compile errors resolved - READY FOR TESTING

---

#### Task 2.2: Update DriverMapScreen UI
**Status**: ✅ COMPLETED (Dec 10, 2025)  
**File**: `lib/features/DriverSide/driverHome/pages/driver_map_screen.dart`

**Implementation Summary**:
✅ Added loading overlay with "Loading active services..." message
✅ Added error message banner (dismissible)
✅ Added empty state card when no active services
✅ Added refresh button (bottom-right) to reload services
✅ Updated _RoundFab widget with loading state support
✅ Repositioned buttons (refresh: right, my location: left)
✅ All compile errors resolved - READY FOR TESTING

**Note**: Similar to parent map, this is a clean map view with just markers (home, school, driver) updating from backend data.

---

### 🔔 SECTION 3: Notification Service Layer

#### Task 3.1: Create NotificationService
**Status**: 🔲 TODO  
**File**: `lib/services/appwrite/notification_service.dart`

**Purpose**: Handle both local notifications (in-app) and push notifications (FCM).

**Required Methods**:

```dart
class NotificationService {
  // ═══════════════════════════════════════════════════════════════════════════
  // FCM TOKEN MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Initialize FCM and request notification permissions
  Future<void> initialize();
  
  /// Register FCM token with Appwrite Messaging
  Future<void> registerFCMToken(String userId);
  
  /// Update FCM token when it refreshes
  Future<void> updateFCMToken(String userId, String newToken);
  
  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICATION DATABASE (notifications table)
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Get all notifications for a user
  Future<List<Notification>> getNotifications(String userId);
  
  /// Mark notification as read
  Future<void> markAsRead(String notificationId);
  
  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId);
  
  /// Clear all notifications for a user
  Future<void> clearAll(String userId);
  
  /// Get unread notification count
  Future<int> getUnreadCount(String userId);
  
  // ═══════════════════════════════════════════════════════════════════════════
  // LOCAL NOTIFICATIONS (flutter_local_notifications)
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Show local notification (used for geofence events)
  Future<void> showLocalNotification({
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? payload,
  });
  
  /// Show geofence notification (driver approaching/arrived)
  Future<void> showGeofenceNotification({
    required String driverName,
    required String childName,
    required GeofenceEventType eventType,
    required String tripId,
  });
  
  /// Show trip status notification (picked/dropped/cancelled)
  Future<void> showTripStatusNotification({
    required String childName,
    required TripStatus status,
    required String tripId,
  });
  
  // ═══════════════════════════════════════════════════════════════════════════
  // PUSH NOTIFICATIONS (FCM)
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Listen to FCM messages in foreground
  Stream<RemoteMessage> get onMessageReceived;
  
  /// Handle notification tap (background/terminated)
  Future<void> handleNotificationTap(RemoteMessage message);
  
  /// Subscribe to Appwrite Realtime for notification events
  void subscribeToNotifications(String userId);
}
```

**Notification Types** (from `database_constants.dart`):
- `trip_started` - Driver started trip
- `driver_arrived` - Driver arrived at pickup/drop
- `child_picked` - Child picked up successfully
- `child_dropped` - Child dropped off successfully
- `request_received` - New service request received (driver)
- `request_accepted` - Service request accepted (parent)
- `request_rejected` - Service request rejected (parent)
- `new_message` - New chat message
- `system` - System announcements

**Implementation Checklist**:
- [ ] Create `NotificationService` singleton class
- [ ] Initialize `FlutterLocalNotificationsPlugin`
- [ ] Configure Android notification channels
- [ ] Configure iOS notification settings
- [ ] Implement FCM token registration with Appwrite
- [ ] Implement local notification methods
- [ ] Implement FCM message handlers (foreground/background/terminated)
- [ ] Implement notification tap navigation
- [ ] Implement Realtime subscription for live notifications
- [ ] Create notification models and enums

**Testing Checklist**:
- [ ] Test FCM token registration
- [ ] Test local notifications display
- [ ] Test push notifications (foreground/background/terminated)
- [ ] Test notification tap navigation
- [ ] Test Realtime notification updates

---

#### Task 3.2: Integrate Geofence Notifications
**Status**: 🔲 TODO  
**Files**: 
- `lib/features/parentSide/parentHome/controllers/parent_map_controller.dart`
- `lib/services/appwrite/trip_tracking_service.dart`

**Purpose**: Show notifications when driver approaches/arrives at pickup/drop locations.

**Required Changes**:

1. **In TripTrackingService**:
   - When `onLocationUpdate` callback fires, check if trip passed geofence threshold
   - Use `GeofenceService.checkGeofence()` to detect new events
   - Call `NotificationService.showGeofenceNotification()` for new events
   - Store notified events to prevent duplicates

2. **In ParentMapController**:
   - Subscribe to trip updates with geofence callbacks
   - Show in-app banner when driver approaching (500m)
   - Show in-app banner when driver arrived (100m)
   - Play notification sound/vibration

**Geofence Events**:
- `approaching_pickup` - Driver within 500m of pickup
- `arrived_pickup` - Driver within 100m of pickup
- `approaching_drop` - Driver within 500m of drop
- `arrived_drop` - Driver within 100m of drop

**Implementation Checklist**:
- [ ] Add geofence check in `TripTrackingService`
- [ ] Call `NotificationService` for geofence events
- [ ] Add in-app banner UI for geofence notifications
- [ ] Add sound/vibration for notifications
- [ ] Prevent duplicate notifications with state tracking

**Testing Checklist**:
- [ ] Test approaching notification (500m radius)
- [ ] Test arrived notification (100m radius)
- [ ] Test notifications don't duplicate
- [ ] Test in-app banner displays correctly
- [ ] Test notification sound/vibration

---

#### Task 3.3: Create Notification Screens UI
**Status**: 🔲 TODO  
**Files**:
- `lib/features/parentSide/notification/pages/parent_notification_screen.dart` (existing)
- `lib/features/DriverSide/driverNotification/pages/driver_notification_screen.dart` (existing)

**Required Changes**:

1. **Backend Integration**:
   - Replace static demo notifications with `NotificationService.getNotifications(userId)`
   - Load notifications on screen init
   - Subscribe to real-time notification updates

2. **Notification List**:
   - Show notification icon based on type (trip, request, message, system)
   - Show timestamp (e.g., "5 minutes ago")
   - Mark as read on tap
   - Swipe to delete

3. **Notification Actions**:
   - Tap trip notification → Navigate to trip details
   - Tap request notification → Navigate to requests screen
   - Tap message notification → Open chat
   - Mark all as read button
   - Clear all button

4. **Real-time Updates**:
   - Use Appwrite Realtime to listen for new notifications
   - Show badge count on app icon (parent/driver nav bar)
   - Auto-update list when new notification arrives

**Implementation Checklist**:
- [ ] Create `ParentNotificationController` with backend calls
- [ ] Create `DriverNotificationController` with backend calls
- [ ] Update UI to display real notifications
- [ ] Add notification type icons
- [ ] Add timestamp formatting
- [ ] Implement mark as read
- [ ] Implement delete notification
- [ ] Add real-time subscription
- [ ] Add badge count to nav bar

**Testing Checklist**:
- [ ] Test notifications load from backend
- [ ] Test mark as read updates backend
- [ ] Test delete removes from backend
- [ ] Test real-time updates work
- [ ] Test navigation from notification tap
- [ ] Test badge count updates

---

### 🔧 SECTION 4: Appwrite Integration

#### Task 4.1: Configure Appwrite Messaging Provider (FCM)
**Status**: 🔲 TODO  
**Location**: Appwrite Console

**Steps**:
1. Go to Appwrite Console → Messaging → Providers
2. Add new provider: **Firebase Cloud Messaging (FCM)**
3. Enter Firebase project credentials:
   - Server Key (from Firebase Console → Project Settings → Cloud Messaging)
   - Service Account JSON (download from Firebase → Service Accounts)
4. Test provider by sending test notification

**Checklist**:
- [ ] Create FCM provider in Appwrite
- [ ] Configure Firebase credentials
- [ ] Test push notification delivery
- [ ] Create Appwrite messaging topics (if needed)

---

#### Task 4.2: Update process-geofence Function for Notifications
**Status**: 🔲 TODO  
**File**: `functions/process-geofence/src/main.js`

**Current Behavior**:
- Logs geofence events to `geofence_events` table
- Creates notification records in `notifications` table
- Does NOT send push notifications

**Required Changes**:
1. **Send Push Notifications via Appwrite Messaging**:
   - After creating notification record, send push notification to parent
   - Use Appwrite Messaging API: `messaging.createPush()`
   - Target specific user by FCM token or topic

2. **Enhanced Notification Data**:
   - Include tripId, driverId, childId in payload
   - Include deep link for app navigation (e.g., `godropme://trip/{tripId}`)

**Implementation Checklist**:
- [ ] Import Appwrite Messaging SDK in function
- [ ] Add push notification call after creating notification record
- [ ] Add error handling for failed push notifications
- [ ] Log push notification results
- [ ] Test push delivery from function

---

#### Task 4.3: Create send-push-notification Function (Optional)
**Status**: 🔲 TODO (OPTIONAL)  
**File**: `functions/send-push-notification/src/main.js`

**Purpose**: Centralized function for sending push notifications from client or other functions.

**Trigger**: HTTP (POST `/v1/functions/{functionId}/executions`)

**Required Features**:
- Accept notification data in request body
- Send push notification via Appwrite Messaging
- Create notification record in database
- Return success/failure status

**Implementation Checklist**:
- [ ] Create function scaffolding
- [ ] Implement push notification sending
- [ ] Add notification record creation
- [ ] Add validation and error handling
- [ ] Deploy and test

---

### 📊 SECTION 5: Testing & Validation

#### Task 5.1: End-to-End Testing - Parent Flow
**Status**: 🔲 TODO

**Test Scenarios**:
1. **Morning Trip (Home → School)**:
   - [ ] Parent opens app, sees child's trip as "scheduled"
   - [ ] Driver toggles online, trip changes to "driver_enroute"
   - [ ] Parent map shows driver marker moving in real-time
   - [ ] At 500m: Parent receives "Driver approaching" notification
   - [ ] At 100m: Parent receives "Driver arrived" notification
   - [ ] Driver marks "arrived", status updates on parent map
   - [ ] Driver marks "picked", parent receives notification
   - [ ] Driver moves to school, parent sees location update
   - [ ] Driver marks "dropped", trip completes, parent receives notification

2. **Afternoon Trip (School → Home)**:
   - [ ] Repeat above for afternoon window (11 AM - 3 PM)
   - [ ] Verify pickup = school, drop = home

3. **Multiple Children**:
   - [ ] Parent with 2+ children sees all trips on map
   - [ ] Each driver marker updates independently
   - [ ] Notifications are child-specific

**Checklist**:
- [ ] Test morning trip flow
- [ ] Test afternoon trip flow
- [ ] Test multiple children
- [ ] Test notification delivery at all stages
- [ ] Test map marker updates

---

#### Task 5.2: End-to-End Testing - Driver Flow
**Status**: 🔲 TODO

**Test Scenarios**:
1. **Start Shift**:
   - [ ] Driver opens app, sees today's scheduled trips
   - [ ] Driver toggles online, trips change to "driver_enroute"
   - [ ] Driver map shows all pickup/drop markers
   - [ ] GPS tracking starts automatically

2. **Trip Execution**:
   - [ ] Driver navigates to first child's home
   - [ ] Mark arrived → Parent notified
   - [ ] Mark picked → Parent notified
   - [ ] Navigate to school
   - [ ] Mark dropped → Parent notified, trip completes

3. **Multiple Trips**:
   - [ ] Driver completes 3+ trips in sequence
   - [ ] Each trip transitions correctly
   - [ ] No marker overlap or confusion

**Checklist**:
- [ ] Test driver toggle online
- [ ] Test trip status updates
- [ ] Test GPS location streaming
- [ ] Test multiple trip execution
- [ ] Test service area polygon display

---

#### Task 5.3: Notification Testing
**Status**: 🔲 TODO

**Test Cases**:
1. **Local Notifications**:
   - [ ] Geofence approaching (500m)
   - [ ] Geofence arrived (100m)
   - [ ] Trip picked/dropped
   - [ ] Service request received/accepted/rejected

2. **Push Notifications (FCM)**:
   - [ ] Foreground: App open, notification banner shows
   - [ ] Background: App backgrounded, notification tray
   - [ ] Terminated: App closed, notification tray
   - [ ] Tap notification: App opens to correct screen

3. **Notification UI**:
   - [ ] Notifications appear in list
   - [ ] Mark as read works
   - [ ] Delete works
   - [ ] Badge count updates
   - [ ] Real-time updates appear

**Checklist**:
- [ ] Test all local notifications
- [ ] Test push notifications in all app states
- [ ] Test notification tap navigation
- [ ] Test notification UI actions
- [ ] Test real-time notification updates

---

## 📅 Implementation Timeline

| Task | Estimated Time | Dependencies |
|------|---------------|--------------|
| **Section 1: Parent Map** | 4-6 hours | TripService, TripTrackingService |
| Task 1.1: Controller updates | 3-4 hours | - |
| Task 1.2: UI enhancements | 1-2 hours | Task 1.1 |
| **Section 2: Driver Map** | 4-6 hours | ActiveServiceService, DriverLocationService |
| Task 2.1: Controller updates | 3-4 hours | - |
| Task 2.2: UI enhancements | 1-2 hours | Task 2.1 |
| **Section 3: Notifications** | 8-10 hours | FCM setup, Appwrite Messaging |
| Task 3.1: NotificationService | 4-5 hours | - |
| Task 3.2: Geofence integration | 2-3 hours | Task 3.1 |
| Task 3.3: Notification screens | 2-3 hours | Task 3.1 |
| **Section 4: Appwrite** | 2-3 hours | Appwrite Console access |
| Task 4.1: FCM provider setup | 1 hour | Firebase project |
| Task 4.2: Update process-geofence | 1-2 hours | Task 3.1 |
| Task 4.3: send-push-notification | 2 hours (optional) | - |
| **Section 5: Testing** | 4-6 hours | All above |
| Task 5.1: Parent flow testing | 2 hours | Sections 1, 3 |
| Task 5.2: Driver flow testing | 2 hours | Sections 2, 3 |
| Task 5.3: Notification testing | 2 hours | Section 3, 4 |

**Total Estimated Time**: 22-31 hours (3-4 working days)

---

## 🎯 Success Criteria

- [ ] Parent sees driver moving in real-time on map
- [ ] Parent receives geofence notifications (approaching/arrived)
- [ ] Driver sees all enrolled children's locations on map
- [ ] Driver's location updates automatically via GPS
- [ ] Push notifications work in foreground/background/terminated
- [ ] Notification tap navigates to correct screen
- [ ] Notification UI shows real backend data
- [ ] No notification duplicates
- [ ] Service area polygon displays correctly
- [ ] Map performance is smooth with multiple markers

---

## 📝 Notes

### Key Integrations
1. **TripTrackingService**: Real-time Appwrite subscriptions for trip updates
2. **DriverLocationService**: GPS streaming to update trip documents
3. **GeofenceService**: Distance calculations for notification triggers
4. **NotificationService**: Unified interface for local + push notifications
5. **process-geofence Function**: Server-side geofence checks and notifications

### Service Window Validation
- Morning: 5 AM - 9 AM (Home → School)
- Afternoon: 11 AM - 3 PM (School → Home)
- Driver toggle only works within service windows

### Notification Flow
```
[GPS Update] → [Trip Document Updated] 
  → [process-geofence Function Triggered]
  → [Distance Check < 500m or < 100m]
  → [Create Notification Record + Send Push]
  → [Client Receives Push + Shows Local Notification]
  → [Update UI Badge Count]
```

### Map Marker Strategy
**Parent Map**:
- Green home markers for each child
- Blue school markers for unique schools
- Moving car/rickshaw marker for driver (updates every 5 seconds)

**Driver Map**:
- Green home markers for enrolled children
- Blue school markers for service schools
- Red polygon for service area boundary
- Yellow driver marker (own location)

---

## ✅ Completion Checklist

This TODO will be marked complete when:
- [ ] All Section 1 tasks completed (Parent Map)
- [ ] All Section 2 tasks completed (Driver Map)
- [ ] All Section 3 tasks completed (Notifications)
- [ ] All Section 4 tasks completed (Appwrite)
- [ ] All Section 5 tasks completed (Testing)
- [ ] Success criteria met
- [ ] Code reviewed and merged
- [ ] Documentation updated
