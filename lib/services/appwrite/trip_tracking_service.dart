import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/database_constants.dart';

/// Trip Tracking Service for GoDropMe
///
/// Handles real-time tracking for parents:
/// - Subscribe to driver location updates via Appwrite Realtime
/// - Track trip status changes
/// - Receive notifications when driver approaches/arrives
class TripTrackingService {
  static TripTrackingService? _instance;
  static TripTrackingService get instance =>
      _instance ??= TripTrackingService._();

  final Realtime _realtime = AppwriteClient.realtimeService();

  RealtimeSubscription? _tripSubscription;
  String? _activeTripId;

  TripTrackingService._();

  /// Check if currently tracking a trip
  bool get isTracking => _tripSubscription != null;

  /// Get the active trip ID being tracked
  String? get activeTripId => _activeTripId;

  // ═══════════════════════════════════════════════════════════════════════════
  // TRIP TRACKING (PARENT SIDE)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Subscribe to a specific trip for real-time driver location updates
  ///
  /// ```dart
  /// TripTrackingService.instance.subscribeToTrip(
  ///   tripId: 'trip_123',
  ///   onLocationUpdate: (location, status) {
  ///     // Update map marker
  ///   },
  ///   onStatusChange: (status) {
  ///     // Show notification
  ///   },
  ///   onTripCompleted: () {
  ///     // Stop tracking
  ///   },
  /// );
  /// ```
  void subscribeToTrip({
    required String tripId,
    required void Function(LatLng location, String status) onLocationUpdate,
    void Function(String status)? onStatusChange,
    void Function()? onTripCompleted,
  }) {
    // Unsubscribe from any existing subscription
    unsubscribe();

    _activeTripId = tripId;

    debugPrint('📍 Subscribing to trip: $tripId');

    // Subscribe to the specific trip document
    final channel =
        'databases.${AppwriteConfig.databaseId}.collections.${Collections.trips}.documents.$tripId';

    _tripSubscription = _realtime.subscribe([channel]);

    _tripSubscription!.stream.listen(
      (RealtimeMessage response) {
        debugPrint('📍 Realtime event: ${response.events}');

        // Check if this is an update event
        if (response.events.any((e) => e.contains('.update'))) {
          final tripData = response.payload;
          final status = tripData['status'] as String?;

          // Notify status change
          if (status != null && onStatusChange != null) {
            onStatusChange(status);
          }

          // Check if trip is completed (dropped or cancelled)
          if (status == CollectionEnums.tripDropped ||
              status == CollectionEnums.tripCancelled ||
              status == CollectionEnums.tripAbsent) {
            debugPrint('📍 Trip completed with status: $status');
            onTripCompleted?.call();
            unsubscribe();
            return;
          }

          // Extract and broadcast driver location
          final location = tripData['currentDriverLocation'];
          final liveTrackingEnabled = tripData['liveTrackingEnabled'] ?? false;

          if (liveTrackingEnabled &&
              location != null &&
              location is List &&
              location.length >= 2) {
            // Convert from [lng, lat] to LatLng(lat, lng)
            final driverLatLng = LatLng(
              (location[1] as num).toDouble(),
              (location[0] as num).toDouble(),
            );
            onLocationUpdate(driverLatLng, status ?? 'unknown');
          }
        }
      },
      onError: (error) {
        debugPrint('❌ Realtime subscription error: $error');
      },
      onDone: () {
        debugPrint('📍 Realtime subscription closed');
      },
    );
  }

  /// Subscribe to all today's trips for a parent
  ///
  /// Used on parent dashboard to receive status notifications for all children.
  void subscribeToParentTrips({
    required String parentId,
    required void Function(Map<String, dynamic> trip, String eventType)
    onTripUpdate,
  }) {
    // Unsubscribe from any existing subscription
    unsubscribe();

    debugPrint('📍 Subscribing to all trips for parent: $parentId');

    // Subscribe to all trips (we'll filter by parentId in the callback)
    final channel =
        'databases.${AppwriteConfig.databaseId}.collections.${Collections.trips}.documents';

    _tripSubscription = _realtime.subscribe([channel]);

    _tripSubscription!.stream.listen(
      (RealtimeMessage response) {
        final tripData = response.payload;

        // Only process trips for this parent
        if (tripData['parentId'] != parentId) return;

        if (response.events.any((e) => e.contains('.create'))) {
          onTripUpdate(tripData, 'created');
        } else if (response.events.any((e) => e.contains('.update'))) {
          onTripUpdate(tripData, 'updated');
        }
      },
      onError: (error) {
        debugPrint('❌ Parent trips subscription error: $error');
      },
    );
  }

  /// Unsubscribe from all realtime updates
  void unsubscribe() {
    _tripSubscription?.close();
    _tripSubscription = null;
    _activeTripId = null;
    debugPrint('📍 Unsubscribed from trip updates');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STATUS HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get human-readable status message
  static String getStatusMessage(String status) {
    return switch (status) {
      'scheduled' => 'Trip scheduled',
      'driver_enroute' => 'Driver is on the way',
      'arrived' => 'Driver has arrived',
      'picked' => 'Child has been picked up',
      'in_transit' => 'On the way to destination',
      'dropped' => 'Child has been dropped off',
      'cancelled' => 'Trip was cancelled',
      'absent' => 'Child marked absent',
      _ => 'Status: $status',
    };
  }

  /// Get status icon
  static String getStatusIcon(String status) {
    return switch (status) {
      'scheduled' => '📅',
      'driver_enroute' => '🚗',
      'arrived' => '📍',
      'picked' => '✅',
      'in_transit' => '🚙',
      'dropped' => '🏠',
      'cancelled' => '❌',
      'absent' => '🚫',
      _ => '❓',
    };
  }
}
