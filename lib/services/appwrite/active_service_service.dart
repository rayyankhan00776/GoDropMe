import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/auth_service.dart';
import 'package:godropme/services/appwrite/database_constants.dart';

/// Active Service Service for GoDropMe
///
/// Handles active service (parent-driver subscription) operations:
/// - Create active service from accepted request
/// - Get active services for parent or driver
/// - Pause/resume service
/// - End service
class ActiveServiceService {
  static ActiveServiceService? _instance;
  static ActiveServiceService get instance =>
      _instance ??= ActiveServiceService._();

  final TablesDB _tablesDB = AppwriteClient.tablesDBService();

  ActiveServiceService._();

  // ═══════════════════════════════════════════════════════════════════════════
  // CREATE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Create an active service from an accepted request
  ///
  /// This is typically called after a driver accepts a service request.
  /// The monthly fee comes from the accepted request's proposedPrice or
  /// the driver's configured monthlyFee.
  ///
  /// ```dart
  /// final result = await ActiveServiceService.instance.createFromRequest(
  ///   parentId: 'parent_123',
  ///   driverId: 'driver_456',
  ///   childId: 'child_789',
  ///   monthlyFee: 5000.0,
  /// );
  /// ```
  Future<ActiveServiceResult> createActiveService({
    required String parentId,
    required String driverId,
    required String childId,
    required double monthlyFee,
    DateTime? startDate,
  }) async {
    try {
      final authUser = AuthService.instance.currentUser;
      if (authUser == null) {
        return ActiveServiceResult.failure('Please login first');
      }

      // Check if child already has an active service
      final existingService = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.activeServices,
        queries: [
          Query.equal('childId', childId),
          Query.equal('status', CollectionEnums.serviceActive),
          Query.limit(1),
        ],
      );

      if (existingService.total > 0) {
        return ActiveServiceResult.failure(
          'This child already has an active service. Please end it first.',
        );
      }

      // Create the active service
      final effectiveStartDate = startDate ?? DateTime.now();
      
      final serviceRow = await _tablesDB.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.activeServices,
        rowId: ID.unique(),
        data: {
          'parentId': parentId,
          'driverId': driverId,
          'childId': childId,
          'monthlyFee': monthlyFee,
          'startDate': effectiveStartDate.toIso8601String(),
          'status': CollectionEnums.serviceActive,
        },
        permissions: [
          // Both parent and driver can read
          Permission.read(Role.user(authUser.$id)),
          Permission.update(Role.user(authUser.$id)),
        ],
      );

      debugPrint('✅ Active service created: ${serviceRow.$id}');

      return ActiveServiceResult.success(
        message: 'Service activated successfully',
        serviceId: serviceRow.$id,
        data: serviceRow.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Create active service error: ${e.message}');
      return ActiveServiceResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Create active service error: $e');
      return ActiveServiceResult.failure(
          'Failed to create service. Please try again.');
    }
  }

  /// Create active service directly from an accepted service request
  ///
  /// Fetches request data, creates active service, then optionally
  /// updates the request status.
  Future<ActiveServiceResult> createFromRequest({
    required String requestId,
    required double monthlyFee,
    DateTime? startDate,
  }) async {
    try {
      // Get the request data
      final request = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.serviceRequests,
        rowId: requestId,
      );

      final parentId = request.data['parentId'] as String;
      final driverId = request.data['driverId'] as String;
      final childId = request.data['childId'] as String;

      // Create the active service
      return await createActiveService(
        parentId: parentId,
        driverId: driverId,
        childId: childId,
        monthlyFee: monthlyFee,
        startDate: startDate,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Create from request error: ${e.message}');
      return ActiveServiceResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Create from request error: $e');
      return ActiveServiceResult.failure('Failed to create service from request');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // READ
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get a single active service by ID
  Future<ActiveServiceResult> getService(String serviceId) async {
    try {
      final row = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.activeServices,
        rowId: serviceId,
      );

      return ActiveServiceResult.success(
        message: 'Service fetched',
        serviceId: row.$id,
        data: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get service error: ${e.message}');
      return ActiveServiceResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Get service error: $e');
      return ActiveServiceResult.failure('Failed to get service');
    }
  }

  /// Get all active services for a parent
  ///
  /// Optional filters:
  /// - [status]: Filter by service status (active, paused, ended)
  /// - [limit]: Number of results (default 25)
  /// - [offset]: Pagination offset
  Future<ActiveServiceListResult> getParentServices({
    required String parentId,
    String? status,
    int limit = 25,
    int offset = 0,
  }) async {
    try {
      final queries = <String>[
        Query.equal('parentId', parentId),
        Query.limit(limit),
        Query.offset(offset),
        Query.orderDesc('\$createdAt'),
      ];

      if (status != null) {
        queries.add(Query.equal('status', status));
      }

      final result = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.activeServices,
        queries: queries,
      );

      return ActiveServiceListResult.success(
        services: result.rows
            .map((doc) => {'id': doc.$id, ...doc.data})
            .toList(),
        total: result.total,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get parent services error: ${e.message}');
      return ActiveServiceListResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Get parent services error: $e');
      return ActiveServiceListResult.failure('Failed to get services');
    }
  }

  /// Get all active services for a driver
  ///
  /// Optional filters:
  /// - [status]: Filter by service status (active, paused, ended)
  /// - [limit]: Number of results (default 25)
  /// - [offset]: Pagination offset
  Future<ActiveServiceListResult> getDriverServices({
    required String driverId,
    String? status,
    int limit = 25,
    int offset = 0,
  }) async {
    try {
      final queries = <String>[
        Query.equal('driverId', driverId),
        Query.limit(limit),
        Query.offset(offset),
        Query.orderDesc('\$createdAt'),
      ];

      if (status != null) {
        queries.add(Query.equal('status', status));
      }

      final result = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.activeServices,
        queries: queries,
      );

      return ActiveServiceListResult.success(
        services: result.rows
            .map((doc) => {'id': doc.$id, ...doc.data})
            .toList(),
        total: result.total,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get driver services error: ${e.message}');
      return ActiveServiceListResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Get driver services error: $e');
      return ActiveServiceListResult.failure('Failed to get services');
    }
  }

  /// Get only active (not paused/ended) services for a parent
  Future<ActiveServiceListResult> getParentActiveServices({
    required String parentId,
    int limit = 25,
    int offset = 0,
  }) async {
    return getParentServices(
      parentId: parentId,
      status: CollectionEnums.serviceActive,
      limit: limit,
      offset: offset,
    );
  }

  /// Get only active (not paused/ended) services for a driver
  Future<ActiveServiceListResult> getDriverActiveServices({
    required String driverId,
    int limit = 25,
    int offset = 0,
  }) async {
    return getDriverServices(
      driverId: driverId,
      status: CollectionEnums.serviceActive,
      limit: limit,
      offset: offset,
    );
  }

  /// Get active service for a specific child
  Future<ActiveServiceResult?> getChildActiveService(String childId) async {
    try {
      final result = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.activeServices,
        queries: [
          Query.equal('childId', childId),
          Query.equal('status', CollectionEnums.serviceActive),
          Query.limit(1),
        ],
      );

      if (result.total == 0) {
        return null;
      }

      final doc = result.rows.first;
      return ActiveServiceResult.success(
        message: 'Service found',
        serviceId: doc.$id,
        data: doc.data,
      );
    } catch (e) {
      debugPrint('❌ Get child service error: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UPDATE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Pause an active service
  ///
  /// Sets status to 'paused'. Trips won't be generated for paused services.
  Future<ActiveServiceResult> pauseService(String serviceId) async {
    try {
      // Verify service is currently active
      final existing = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.activeServices,
        rowId: serviceId,
      );

      if (existing.data['status'] != CollectionEnums.serviceActive) {
        return ActiveServiceResult.failure(
          'Only active services can be paused',
        );
      }

      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.activeServices,
        rowId: serviceId,
        data: {
          'status': CollectionEnums.servicePaused,
        },
      );

      debugPrint('✅ Service paused: $serviceId');

      return ActiveServiceResult.success(
        message: 'Service paused',
        serviceId: row.$id,
        data: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Pause service error: ${e.message}');
      return ActiveServiceResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Pause service error: $e');
      return ActiveServiceResult.failure('Failed to pause service');
    }
  }

  /// Resume a paused service
  ///
  /// Sets status back to 'active'.
  Future<ActiveServiceResult> resumeService(String serviceId) async {
    try {
      // Verify service is currently paused
      final existing = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.activeServices,
        rowId: serviceId,
      );

      if (existing.data['status'] != CollectionEnums.servicePaused) {
        return ActiveServiceResult.failure(
          'Only paused services can be resumed',
        );
      }

      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.activeServices,
        rowId: serviceId,
        data: {
          'status': CollectionEnums.serviceActive,
        },
      );

      debugPrint('✅ Service resumed: $serviceId');

      return ActiveServiceResult.success(
        message: 'Service resumed',
        serviceId: row.$id,
        data: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Resume service error: ${e.message}');
      return ActiveServiceResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Resume service error: $e');
      return ActiveServiceResult.failure('Failed to resume service');
    }
  }

  /// End an active or paused service
  ///
  /// Sets status to 'ended' and records the end date.
  /// This is typically done by the driver or when the parent cancels.
  Future<ActiveServiceResult> endService({
    required String serviceId,
    DateTime? endDate,
  }) async {
    try {
      // Verify service is not already ended
      final existing = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.activeServices,
        rowId: serviceId,
      );

      if (existing.data['status'] == CollectionEnums.serviceTerminated) {
        return ActiveServiceResult.failure(
          'Service has already been ended',
        );
      }

      final effectiveEndDate = endDate ?? DateTime.now();

      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.activeServices,
        rowId: serviceId,
        data: {
          'status': CollectionEnums.serviceTerminated,
          'endDate': effectiveEndDate.toIso8601String(),
        },
      );

      debugPrint('✅ Service ended: $serviceId');

      return ActiveServiceResult.success(
        message: 'Service ended',
        serviceId: row.$id,
        data: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ End service error: ${e.message}');
      return ActiveServiceResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ End service error: $e');
      return ActiveServiceResult.failure('Failed to end service');
    }
  }

  /// Update monthly fee for an active service
  Future<ActiveServiceResult> updateMonthlyFee({
    required String serviceId,
    required double newFee,
  }) async {
    try {
      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.activeServices,
        rowId: serviceId,
        data: {
          'monthlyFee': newFee,
        },
      );

      debugPrint('✅ Monthly fee updated: $serviceId → $newFee');

      return ActiveServiceResult.success(
        message: 'Monthly fee updated',
        serviceId: row.$id,
        data: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Update fee error: ${e.message}');
      return ActiveServiceResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Update fee error: $e');
      return ActiveServiceResult.failure('Failed to update monthly fee');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DELETE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Delete an active service
  ///
  /// This is for admin/cleanup purposes. Normal flow should use endService.
  Future<ActiveServiceResult> deleteService(String serviceId) async {
    try {
      await _tablesDB.deleteRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.activeServices,
        rowId: serviceId,
      );

      debugPrint('✅ Service deleted: $serviceId');

      return ActiveServiceResult.success(
        message: 'Service deleted',
        serviceId: serviceId,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Delete service error: ${e.message}');
      return ActiveServiceResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Delete service error: $e');
      return ActiveServiceResult.failure('Failed to delete service');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Check if a child has an active service
  Future<bool> childHasActiveService(String childId) async {
    final result = await getChildActiveService(childId);
    return result != null;
  }

  /// Get count of active services for a driver
  Future<int> getDriverActiveServiceCount(String driverId) async {
    try {
      final result = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.activeServices,
        queries: [
          Query.equal('driverId', driverId),
          Query.equal('status', CollectionEnums.serviceActive),
        ],
        total: true,
      );
      return result.total;
    } catch (e) {
      debugPrint('❌ Get service count error: $e');
      return 0;
    }
  }

  /// Parse Appwrite exception to user-friendly message
  String _parseError(AppwriteException e) {
    switch (e.code) {
      case 401:
        return 'Please login again';
      case 403:
        return 'You don\'t have permission for this action';
      case 404:
        return 'Service not found';
      case 409:
        return 'Service already exists';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RESULT CLASSES
// ═══════════════════════════════════════════════════════════════════════════

/// Result class for single active service operations
class ActiveServiceResult {
  final bool success;
  final String message;
  final String? serviceId;
  final Map<String, dynamic>? data;

  ActiveServiceResult._({
    required this.success,
    required this.message,
    this.serviceId,
    this.data,
  });

  factory ActiveServiceResult.success({
    required String message,
    String? serviceId,
    Map<String, dynamic>? data,
  }) {
    return ActiveServiceResult._(
      success: true,
      message: message,
      serviceId: serviceId,
      data: data,
    );
  }

  factory ActiveServiceResult.failure(String message) {
    return ActiveServiceResult._(
      success: false,
      message: message,
    );
  }
}

/// Result class for list operations
class ActiveServiceListResult {
  final bool success;
  final String? message;
  final List<Map<String, dynamic>> services;
  final int total;

  ActiveServiceListResult._({
    required this.success,
    this.message,
    this.services = const [],
    this.total = 0,
  });

  factory ActiveServiceListResult.success({
    required List<Map<String, dynamic>> services,
    required int total,
  }) {
    return ActiveServiceListResult._(
      success: true,
      services: services,
      total: total,
    );
  }

  factory ActiveServiceListResult.failure(String message) {
    return ActiveServiceListResult._(
      success: false,
      message: message,
    );
  }
}
