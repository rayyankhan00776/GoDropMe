import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/database_constants.dart';

/// Trip Service for GoDropMe
///
/// Handles trip operations for drivers and parents:
/// - Get today's trips for a driver
/// - Get trips for parent's children
/// - Update trip status (enroute, arrived, picked, dropped, absent)
/// - Update driver location during active trips
/// - Parent drop confirmation
class TripService {
  static TripService? _instance;
  static TripService get instance => _instance ??= TripService._();

  final TablesDB _tablesDB = AppwriteClient.tablesDBService();

  TripService._();

  // ═══════════════════════════════════════════════════════════════════════════
  // READ OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get today's trips for a driver
  ///
  /// Filters by tripType (morning/afternoon) based on current time if not specified.
  /// Returns trips that are not cancelled or completed.
  ///
  /// ```dart
  /// final result = await TripService.instance.getTodayTrips(
  ///   driverId: 'driver_123',
  ///   tripType: 'morning', // optional
  /// );
  /// ```
  Future<TripListResult> getTodayTrips({
    required String driverId,
    String? tripType,
  }) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final tomorrowStart = todayStart.add(const Duration(days: 1));

      final queries = <String>[
        Query.equal('driverId', driverId),
        Query.greaterThanEqual('scheduledDate', todayStart.toIso8601String()),
        Query.lessThan('scheduledDate', tomorrowStart.toIso8601String()),
        Query.orderAsc('windowStartTime'),
      ];

      // Filter by trip type if specified
      if (tripType != null) {
        queries.add(Query.equal('tripType', tripType));
      }

      final result = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.trips,
        queries: queries,
      );

      return TripListResult.success(
        trips: result.rows.map((row) => {'id': row.$id, ...row.data}).toList(),
        total: result.total,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get today trips error: ${e.message}');
      return TripListResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Get today trips error: $e');
      return TripListResult.failure('Failed to get trips');
    }
  }

  /// Get trips for a parent's children
  ///
  /// Returns all trips for today where parentId matches.
  Future<TripListResult> getParentTrips({
    required String parentId,
    String? tripType,
    String? status,
  }) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final tomorrowStart = todayStart.add(const Duration(days: 1));

      final queries = <String>[
        Query.equal('parentId', parentId),
        Query.greaterThanEqual('scheduledDate', todayStart.toIso8601String()),
        Query.lessThan('scheduledDate', tomorrowStart.toIso8601String()),
        Query.orderAsc('windowStartTime'),
      ];

      if (tripType != null) {
        queries.add(Query.equal('tripType', tripType));
      }

      if (status != null) {
        queries.add(Query.equal('status', status));
      }

      final result = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.trips,
        queries: queries,
      );

      return TripListResult.success(
        trips: result.rows.map((row) => {'id': row.$id, ...row.data}).toList(),
        total: result.total,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get parent trips error: ${e.message}');
      return TripListResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Get parent trips error: $e');
      return TripListResult.failure('Failed to get trips');
    }
  }

  /// Get today's trips for a specific child
  /// 
  /// Returns all trips for today where childId matches.
  /// Useful for marking a child absent for the day.
  Future<TripListResult> getChildTodayTrips({
    required String childId,
    String? status,
  }) async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final tomorrowStart = todayStart.add(const Duration(days: 1));

      final queries = <String>[
        Query.equal('childId', childId),
        Query.greaterThanEqual('scheduledDate', todayStart.toIso8601String()),
        Query.lessThan('scheduledDate', tomorrowStart.toIso8601String()),
        Query.orderAsc('windowStartTime'),
      ];

      if (status != null) {
        queries.add(Query.equal('status', status));
      }

      final result = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.trips,
        queries: queries,
      );

      return TripListResult.success(
        trips: result.rows.map((row) => {'id': row.$id, ...row.data}).toList(),
        total: result.total,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get child trips error: ${e.message}');
      return TripListResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Get child trips error: $e');
      return TripListResult.failure('Failed to get trips');
    }
  }

  /// Get a single trip by ID
  Future<TripResult> getTrip(String tripId) async {
    try {
      final row = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.trips,
        rowId: tripId,
      );

      return TripResult.success(
        message: 'Trip fetched',
        tripId: row.$id,
        data: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get trip error: ${e.message}');
      return TripResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Get trip error: $e');
      return TripResult.failure('Failed to get trip');
    }
  }

  /// Get the currently active trip for a driver (status: driver_enroute, arrived, picked, in_transit)
  Future<TripResult?> getActiveTrip(String driverId) async {
    try {
      final result = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.trips,
        queries: [
          Query.equal('driverId', driverId),
          Query.contains('status', [
            CollectionEnums.tripEnroute,
            CollectionEnums.tripArrived,
            CollectionEnums.tripPicked,
            CollectionEnums.tripInTransit,
          ]),
          Query.limit(1),
        ],
      );

      if (result.total == 0) {
        return null;
      }

      final row = result.rows.first;
      return TripResult.success(
        message: 'Active trip found',
        tripId: row.$id,
        data: row.data,
      );
    } catch (e) {
      debugPrint('❌ Get active trip error: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STATUS UPDATE OPERATIONS (Driver Actions)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Start a trip - Driver begins route to pickup location
  ///
  /// Updates status to 'driver_enroute' and enables live tracking.
  Future<TripResult> startTrip(String tripId) async {
    try {
      // Verify trip is currently scheduled
      final existing = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.trips,
        rowId: tripId,
      );

      if (existing.data['status'] != CollectionEnums.tripScheduled) {
        return TripResult.failure(
          'Trip must be scheduled to start. Current: ${existing.data['status']}',
        );
      }

      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.trips,
        rowId: tripId,
        data: {
          'status': 'driver_enroute',
          'driverEnrouteAt': DateTime.now().toUtc().toIso8601String(),
          'liveTrackingEnabled': true,
        },
      );

      debugPrint('✅ Trip started: $tripId → driver_enroute');

      return TripResult.success(
        message: 'Trip started',
        tripId: row.$id,
        data: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Start trip error: ${e.message}');
      return TripResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Start trip error: $e');
      return TripResult.failure('Failed to start trip');
    }
  }

  /// Mark arrived - Driver has arrived at pickup location
  Future<TripResult> markArrived(String tripId) async {
    try {
      final existing = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.trips,
        rowId: tripId,
      );

      if (existing.data['status'] != 'driver_enroute') {
        return TripResult.failure(
          'Trip must be enroute to mark arrived. Current: ${existing.data['status']}',
        );
      }

      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.trips,
        rowId: tripId,
        data: {
          'status': CollectionEnums.tripArrived,
          'arrivedAt': DateTime.now().toUtc().toIso8601String(),
        },
      );

      debugPrint('✅ Trip arrived: $tripId');

      return TripResult.success(
        message: 'Arrived at pickup location',
        tripId: row.$id,
        data: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Mark arrived error: ${e.message}');
      return TripResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Mark arrived error: $e');
      return TripResult.failure('Failed to mark arrived');
    }
  }

  /// Mark picked - Child has been picked up
  Future<TripResult> markPicked(String tripId) async {
    try {
      final existing = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.trips,
        rowId: tripId,
      );

      final currentStatus = existing.data['status'];
      if (currentStatus != CollectionEnums.tripArrived &&
          currentStatus != CollectionEnums.tripEnroute) {
        return TripResult.failure(
          'Trip must be arrived or enroute to mark picked. Current: $currentStatus',
        );
      }

      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.trips,
        rowId: tripId,
        data: {
          'status': CollectionEnums.tripPicked,
          'pickedAt': DateTime.now().toUtc().toIso8601String(),
        },
      );

      debugPrint('✅ Child picked: $tripId');

      return TripResult.success(
        message: 'Child picked up',
        tripId: row.$id,
        data: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Mark picked error: ${e.message}');
      return TripResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Mark picked error: $e');
      return TripResult.failure('Failed to mark picked');
    }
  }

  /// Mark in transit - On the way to drop location
  Future<TripResult> markInTransit(String tripId) async {
    try {
      final existing = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.trips,
        rowId: tripId,
      );

      if (existing.data['status'] != CollectionEnums.tripPicked) {
        return TripResult.failure(
          'Trip must be picked to mark in transit. Current: ${existing.data['status']}',
        );
      }

      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.trips,
        rowId: tripId,
        data: {
          'status': CollectionEnums.tripInTransit,
          'inTransitAt': DateTime.now().toUtc().toIso8601String(),
        },
      );

      debugPrint('✅ Trip in transit: $tripId');

      return TripResult.success(
        message: 'In transit to drop location',
        tripId: row.$id,
        data: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Mark in transit error: ${e.message}');
      return TripResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Mark in transit error: $e');
      return TripResult.failure('Failed to mark in transit');
    }
  }

  /// Mark dropped - Child has been dropped off
  ///
  /// Disables live tracking.
  Future<TripResult> markDropped(String tripId) async {
    try {
      final existing = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.trips,
        rowId: tripId,
      );

      final currentStatus = existing.data['status'];
      if (currentStatus != CollectionEnums.tripPicked &&
          currentStatus != CollectionEnums.tripInTransit) {
        return TripResult.failure(
          'Trip must be picked or in_transit to mark dropped. Current: $currentStatus',
        );
      }

      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.trips,
        rowId: tripId,
        data: {
          'status': CollectionEnums.tripDropped,
          'droppedAt': DateTime.now().toUtc().toIso8601String(),
          'liveTrackingEnabled': false,
        },
      );

      debugPrint('✅ Child dropped: $tripId');

      return TripResult.success(
        message: 'Child dropped off safely',
        tripId: row.$id,
        data: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Mark dropped error: ${e.message}');
      return TripResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Mark dropped error: $e');
      return TripResult.failure('Failed to mark dropped');
    }
  }

  /// Mark absent - Child is absent for this trip
  ///
  /// Records the reason and marks trip as absent.
  Future<TripResult> markAbsent(String tripId, {String? reason}) async {
    try {
      final existing = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.trips,
        rowId: tripId,
      );

      final currentStatus = existing.data['status'];
      // Can mark absent from scheduled, enroute, or arrived
      final validStatuses = [
        CollectionEnums.tripScheduled,
        CollectionEnums.tripEnroute,
        CollectionEnums.tripArrived,
      ];
      if (!validStatuses.contains(currentStatus)) {
        return TripResult.failure(
          'Cannot mark absent for trip with status: $currentStatus',
        );
      }

      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.trips,
        rowId: tripId,
        data: {
          'status': CollectionEnums.tripAbsent,
          'absentReason': reason ?? 'No reason provided',
          'liveTrackingEnabled': false,
        },
      );

      debugPrint('✅ Trip marked absent: $tripId');

      return TripResult.success(
        message: 'Trip marked as absent',
        tripId: row.$id,
        data: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Mark absent error: ${e.message}');
      return TripResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Mark absent error: $e');
      return TripResult.failure('Failed to mark absent');
    }
  }

  /// Cancel a trip
  Future<TripResult> cancelTrip(String tripId, {String? reason}) async {
    try {
      final existing = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.trips,
        rowId: tripId,
      );

      final currentStatus = existing.data['status'];
      // Cannot cancel completed trips
      if (currentStatus == CollectionEnums.tripDropped) {
        return TripResult.failure('Cannot cancel a completed trip');
      }

      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.trips,
        rowId: tripId,
        data: {
          'status': CollectionEnums.tripCancelled,
          'notes': reason ?? 'Trip cancelled',
          'liveTrackingEnabled': false,
        },
      );

      debugPrint('✅ Trip cancelled: $tripId');

      return TripResult.success(
        message: 'Trip cancelled',
        tripId: row.$id,
        data: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Cancel trip error: ${e.message}');
      return TripResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Cancel trip error: $e');
      return TripResult.failure('Failed to cancel trip');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOCATION UPDATES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Update driver's current location during an active trip
  ///
  /// Called periodically (every 5-10 seconds) by the driver app
  /// to stream location to the parent for real-time tracking.
  ///
  /// [location] must be in [longitude, latitude] format.
  Future<TripResult> updateDriverLocation(
    String tripId,
    List<double> location,
  ) async {
    try {
      if (location.length != 2) {
        return TripResult.failure('Location must be [longitude, latitude]');
      }

      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.trips,
        rowId: tripId,
        data: {'currentDriverLocation': location},
      );

      return TripResult.success(
        message: 'Location updated',
        tripId: row.$id,
        data: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Update location error: ${e.message}');
      return TripResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Update location error: $e');
      return TripResult.failure('Failed to update location');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PARENT ACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Parent confirms child was dropped off safely
  Future<TripResult> confirmDrop(String tripId) async {
    try {
      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.trips,
        rowId: tripId,
        data: {'parentConfirmed': true},
      );

      debugPrint('✅ Drop confirmed by parent: $tripId');

      return TripResult.success(
        message: 'Drop-off confirmed',
        tripId: row.$id,
        data: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Confirm drop error: ${e.message}');
      return TripResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Confirm drop error: $e');
      return TripResult.failure('Failed to confirm drop-off');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICATION FLAGS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Update notification sent flags
  ///
  /// Called after sending geofence notifications to prevent duplicates.
  Future<TripResult> updateNotificationFlags(
    String tripId, {
    bool? approachingNotified,
    bool? arrivedNotified,
    bool? pickedNotified,
    bool? droppedNotified,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (approachingNotified != null) {
        updates['approachingNotified'] = approachingNotified;
      }
      if (arrivedNotified != null) {
        updates['arrivedNotified'] = arrivedNotified;
      }
      if (pickedNotified != null) {
        updates['pickedNotified'] = pickedNotified;
      }
      if (droppedNotified != null) {
        updates['droppedNotified'] = droppedNotified;
      }

      if (updates.isEmpty) {
        return TripResult.failure('No flags to update');
      }

      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.trips,
        rowId: tripId,
        data: updates,
      );

      return TripResult.success(
        message: 'Notification flags updated',
        tripId: row.$id,
        data: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Update flags error: ${e.message}');
      return TripResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Update flags error: $e');
      return TripResult.failure('Failed to update flags');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Parse Appwrite exception to user-friendly message
  String _parseError(AppwriteException e) {
    switch (e.code) {
      case 401:
        return 'Please login again';
      case 403:
        return 'You don\'t have permission for this action';
      case 404:
        return 'Trip not found';
      case 409:
        return 'Trip conflict';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RESULT CLASSES
// ═══════════════════════════════════════════════════════════════════════════

/// Result class for single trip operations
class TripResult {
  final bool success;
  final String message;
  final String? tripId;
  final Map<String, dynamic>? data;

  TripResult._({
    required this.success,
    required this.message,
    this.tripId,
    this.data,
  });

  factory TripResult.success({
    required String message,
    String? tripId,
    Map<String, dynamic>? data,
  }) {
    return TripResult._(
      success: true,
      message: message,
      tripId: tripId,
      data: data,
    );
  }

  factory TripResult.failure(String message) {
    return TripResult._(success: false, message: message);
  }
}

/// Result class for list operations
class TripListResult {
  final bool success;
  final String? message;
  final List<Map<String, dynamic>> trips;
  final int total;

  TripListResult._({
    required this.success,
    this.message,
    this.trips = const [],
    this.total = 0,
  });

  factory TripListResult.success({
    required List<Map<String, dynamic>> trips,
    required int total,
  }) {
    return TripListResult._(success: true, trips: trips, total: total);
  }

  factory TripListResult.failure(String message) {
    return TripListResult._(success: false, message: message);
  }
}
