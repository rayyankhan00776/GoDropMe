import 'dart:math' as math;
import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/database_constants.dart';

/// Geofence Service for GoDropMe
///
/// Handles geofencing logic for trip tracking:
/// - Calculate distance between driver and target locations
/// - Check if driver is within geofence radius (approaching/arrived)
/// - Log geofence events for analytics
class GeofenceService {
  static GeofenceService? _instance;
  static GeofenceService get instance => _instance ??= GeofenceService._();

  final TablesDB _tablesDB = AppwriteClient.tablesDBService();

  GeofenceService._();

  // ═══════════════════════════════════════════════════════════════════════════
  // CONSTANTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Radius (meters) for "approaching" notification
  static const double approachingRadiusMeters = 500.0;

  /// Radius (meters) for "arrived" notification
  static const double arrivedRadiusMeters = 100.0;

  /// Earth radius in meters for Haversine calculation
  static const double earthRadiusMeters = 6371000.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // DISTANCE CALCULATION
  // ═══════════════════════════════════════════════════════════════════════════

  /// Calculate distance between two points using Haversine formula
  ///
  /// [from] and [to] must be in [longitude, latitude] format.
  /// Returns distance in meters.
  ///
  /// ```dart
  /// final distance = GeofenceService.instance.calculateDistanceMeters(
  ///   [71.5249, 34.0151], // driver location
  ///   [71.5349, 34.0251], // target location
  /// );
  /// print('Distance: ${distance}m'); // e.g., "Distance: 1234.5m"
  /// ```
  double calculateDistanceMeters(List<double> from, List<double> to) {
    if (from.length < 2 || to.length < 2) {
      throw ArgumentError('Points must have at least 2 elements [lng, lat]');
    }

    // Convert to radians
    final lat1 = _toRadians(from[1]);
    final lat2 = _toRadians(to[1]);
    final deltaLat = _toRadians(to[1] - from[1]);
    final deltaLon = _toRadians(to[0] - from[0]);

    // Haversine formula
    final a =
        math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(deltaLon / 2) *
            math.sin(deltaLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusMeters * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;

  // ═══════════════════════════════════════════════════════════════════════════
  // GEOFENCE CHECKING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Check geofence status for a driver approaching a target
  ///
  /// Returns the geofence event type if driver entered a new zone,
  /// or null if no new zone was entered.
  /// 
  /// [isGoingToPickup] determines whether we're checking for pickup or drop events.
  ///
  /// ```dart
  /// final event = GeofenceService.instance.checkGeofence(
  ///   driverLocation: [71.5249, 34.0151],
  ///   targetLocation: [71.5349, 34.0251],
  ///   approachingNotified: false,
  ///   arrivedNotified: false,
  ///   isGoingToPickup: true, // true = going to pickup, false = going to drop
  /// );
  ///
  /// if (event != null) {
  ///   print('New geofence event: ${event.type.dbValue}');
  /// }
  /// ```
  GeofenceCheckResult? checkGeofence({
    required List<double> driverLocation,
    required List<double> targetLocation,
    required bool approachingNotified,
    required bool arrivedNotified,
    bool isGoingToPickup = true,
  }) {
    final distance = calculateDistanceMeters(driverLocation, targetLocation);

    // Check arrived first (higher priority, smaller radius)
    if (distance <= arrivedRadiusMeters && !arrivedNotified) {
      final eventType = isGoingToPickup 
          ? GeofenceEventType.arrivedPickup 
          : GeofenceEventType.arrivedDrop;
      return GeofenceCheckResult(
        type: eventType,
        distanceMeters: distance,
        message: 'Driver has arrived at the ${isGoingToPickup ? "pickup" : "drop-off"} location',
      );
    }

    // Check approaching
    if (distance <= approachingRadiusMeters && !approachingNotified) {
      final minutesAway = _estimateMinutesAway(distance);
      final eventType = isGoingToPickup 
          ? GeofenceEventType.approachingPickup 
          : GeofenceEventType.approachingDrop;
      return GeofenceCheckResult(
        type: eventType,
        distanceMeters: distance,
        message: 'Driver is about $minutesAway minutes away from ${isGoingToPickup ? "pickup" : "drop-off"}',
      );
    }

    // No new zone entered
    return null;
  }

  /// Estimate minutes away based on distance
  /// Assumes average speed of 20 km/h in urban areas
  int _estimateMinutesAway(double distanceMeters) {
    const averageSpeedKmh = 20.0;
    const metersPerMinute = averageSpeedKmh * 1000 / 60;
    return (distanceMeters / metersPerMinute).ceil().clamp(1, 10);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EVENT LOGGING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Log a geofence event to the database
  ///
  /// Used for analytics and trip history.
  /// Note: geofence_events table does NOT have a 'locationType' column
  Future<GeofenceEventResult> logGeofenceEvent({
    required String tripId,
    required String driverId,
    required GeofenceEventType eventType,
    required List<double> driverLocation,
    required List<double> targetLocation,
    required double distanceMeters,
    bool notificationSent = true,
  }) async {
    try {
      final row = await _tablesDB.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.geofenceEvents,
        rowId: ID.unique(),
        data: {
          'tripId': tripId,
          'driverId': driverId,
          'eventType': eventType.dbValue, // Use dbValue for correct enum string
          'driverLocation': driverLocation,
          'targetLocation': targetLocation,
          'distanceMeters': distanceMeters.round(),
          'notificationSent': notificationSent,
        },
      );

      debugPrint('✅ Geofence event logged: ${eventType.dbValue} for trip $tripId');

      return GeofenceEventResult.success(
        message: 'Event logged',
        eventId: row.$id,
        data: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Log geofence event error: ${e.message}');
      return GeofenceEventResult.failure(
        e.message ?? 'Failed to log geofence event',
      );
    } catch (e) {
      debugPrint('❌ Log geofence event error: $e');
      return GeofenceEventResult.failure('Failed to log geofence event');
    }
  }

  /// Get all geofence events for a trip
  Future<GeofenceEventListResult> getEventsByTrip(String tripId) async {
    try {
      final result = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.geofenceEvents,
        queries: [
          Query.equal('tripId', tripId),
          Query.orderDesc('\$createdAt'),
        ],
      );

      return GeofenceEventListResult.success(
        events: result.rows.map((row) => {'id': row.$id, ...row.data}).toList(),
        total: result.total,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get geofence events error: ${e.message}');
      return GeofenceEventListResult.failure(
        e.message ?? 'Failed to get geofence events',
      );
    } catch (e) {
      debugPrint('❌ Get geofence events error: $e');
      return GeofenceEventListResult.failure('Failed to get geofence events');
    }
  }

  /// Get latest events for a driver (for debugging/monitoring)
  Future<GeofenceEventListResult> getEventsByDriver(
    String driverId, {
    int limit = 10,
  }) async {
    try {
      final result = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.geofenceEvents,
        queries: [
          Query.equal('driverId', driverId),
          Query.orderDesc('\$createdAt'),
          Query.limit(limit),
        ],
      );

      return GeofenceEventListResult.success(
        events: result.rows.map((row) => {'id': row.$id, ...row.data}).toList(),
        total: result.total,
      );
    } catch (e) {
      debugPrint('❌ Get driver geofence events error: $e');
      return GeofenceEventListResult.failure('Failed to get events');
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ENUMS & MODELS
// ═══════════════════════════════════════════════════════════════════════════

/// Geofence event types
/// 
/// Database enum values: ['approaching_pickup', 'arrived_pickup', 
/// 'approaching_drop', 'arrived_drop', 'left_geofence']
/// 
/// Uses constants from [CollectionEnums] for database values.
enum GeofenceEventType {
  /// Driver is within 500m of pickup location
  approachingPickup,

  /// Driver has arrived within 100m of pickup location
  arrivedPickup,
  
  /// Driver is within 500m of drop location
  approachingDrop,
  
  /// Driver has arrived within 100m of drop location
  arrivedDrop,
  
  /// Driver left the geofence area
  leftGeofence,
}

extension GeofenceEventTypeExt on GeofenceEventType {
  /// Returns the database enum value using [CollectionEnums]
  String get dbValue => switch (this) {
    GeofenceEventType.approachingPickup => CollectionEnums.geofenceApproachingPickup,
    GeofenceEventType.arrivedPickup => CollectionEnums.geofenceArrivedPickup,
    GeofenceEventType.approachingDrop => CollectionEnums.geofenceApproachingDrop,
    GeofenceEventType.arrivedDrop => CollectionEnums.geofenceArrivedDrop,
    GeofenceEventType.leftGeofence => CollectionEnums.geofenceLeftGeofence,
  };
  
  /// User-friendly display name
  String get displayName => switch (this) {
    GeofenceEventType.approachingPickup => 'Approaching Pickup',
    GeofenceEventType.arrivedPickup => 'Arrived at Pickup',
    GeofenceEventType.approachingDrop => 'Approaching Drop',
    GeofenceEventType.arrivedDrop => 'Arrived at Drop',
    GeofenceEventType.leftGeofence => 'Left Geofence',
  };
  
  /// Whether this is an "approaching" event
  bool get isApproaching => this == GeofenceEventType.approachingPickup || 
                             this == GeofenceEventType.approachingDrop;
  
  /// Whether this is an "arrived" event                           
  bool get isArrived => this == GeofenceEventType.arrivedPickup || 
                        this == GeofenceEventType.arrivedDrop;

  static GeofenceEventType fromString(String? s) {
    return switch (s?.toLowerCase()) {
      CollectionEnums.geofenceApproachingPickup => GeofenceEventType.approachingPickup,
      CollectionEnums.geofenceArrivedPickup => GeofenceEventType.arrivedPickup,
      CollectionEnums.geofenceApproachingDrop => GeofenceEventType.approachingDrop,
      CollectionEnums.geofenceArrivedDrop => GeofenceEventType.arrivedDrop,
      CollectionEnums.geofenceLeftGeofence => GeofenceEventType.leftGeofence,
      // Legacy support - map old values
      'approaching' => GeofenceEventType.approachingPickup,
      'arrived' => GeofenceEventType.arrivedPickup,
      _ => GeofenceEventType.approachingPickup,
    };
  }
}

/// Result from checking geofence
class GeofenceCheckResult {
  final GeofenceEventType type;
  final double distanceMeters;
  final String message;

  GeofenceCheckResult({
    required this.type,
    required this.distanceMeters,
    required this.message,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// RESULT CLASSES
// ═══════════════════════════════════════════════════════════════════════════

/// Result class for single geofence event operations
class GeofenceEventResult {
  final bool success;
  final String message;
  final String? eventId;
  final Map<String, dynamic>? data;

  GeofenceEventResult._({
    required this.success,
    required this.message,
    this.eventId,
    this.data,
  });

  factory GeofenceEventResult.success({
    required String message,
    String? eventId,
    Map<String, dynamic>? data,
  }) {
    return GeofenceEventResult._(
      success: true,
      message: message,
      eventId: eventId,
      data: data,
    );
  }

  factory GeofenceEventResult.failure(String message) {
    return GeofenceEventResult._(success: false, message: message);
  }
}

/// Result class for list operations
class GeofenceEventListResult {
  final bool success;
  final String? message;
  final List<Map<String, dynamic>> events;
  final int total;

  GeofenceEventListResult._({
    required this.success,
    this.message,
    this.events = const [],
    this.total = 0,
  });

  factory GeofenceEventListResult.success({
    required List<Map<String, dynamic>> events,
    required int total,
  }) {
    return GeofenceEventListResult._(
      success: true,
      events: events,
      total: total,
    );
  }

  factory GeofenceEventListResult.failure(String message) {
    return GeofenceEventListResult._(success: false, message: message);
  }
}
