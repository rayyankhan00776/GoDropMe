import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/auth_service.dart';
import 'package:godropme/services/appwrite/database_constants.dart';

/// Service Request Service for GoDropMe
///
/// Handles service request CRUD operations:
/// - Parent sends request to driver for a child
/// - Driver accepts/rejects requests
/// - Parent can cancel pending requests
/// - List requests by parent or driver
class ServiceRequestService {
  static ServiceRequestService? _instance;
  static ServiceRequestService get instance =>
      _instance ??= ServiceRequestService._();

  final TablesDB _tablesDB = AppwriteClient.tablesDBService();

  ServiceRequestService._();

  // ═══════════════════════════════════════════════════════════════════════════
  // CREATE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Send a service request from parent to driver for a specific child
  ///
  /// ```dart
  /// final result = await ServiceRequestService.instance.sendRequest(
  ///   parentId: 'parent_123',
  ///   driverId: 'driver_456',
  ///   childId: 'child_789',
  ///   proposedPrice: 5000.0, // Optional monthly fee proposal
  /// );
  /// ```
  Future<ServiceRequestResult> sendRequest({
    required String parentId,
    required String driverId,
    required String childId,
    double? proposedPrice,
  }) async {
    try {
      final authUser = AuthService.instance.currentUser;
      if (authUser == null) {
        return ServiceRequestResult.failure('Please login first');
      }

      // Check if there's already a pending request for this child-driver pair
      final existingRequests = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.serviceRequests,
        queries: [
          Query.equal('parentId', parentId),
          Query.equal('driverId', driverId),
          Query.equal('childId', childId),
          Query.equal('status', CollectionEnums.requestPending),
        ],
      );

      if (existingRequests.total > 0) {
        return ServiceRequestResult.failure(
          'You already have a pending request for this child with this driver',
        );
      }

      // Create the service request
      final requestRow = await _tablesDB.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.serviceRequests,
        rowId: ID.unique(),
        data: {
          'parentId': parentId,
          'driverId': driverId,
          'childId': childId,
          'status': CollectionEnums.requestPending,
          if (proposedPrice != null) 'proposedPrice': proposedPrice,
        },
        permissions: [
          // Parent can read and cancel their own request
          Permission.read(Role.user(authUser.$id)),
          Permission.update(Role.user(authUser.$id)),
          Permission.delete(Role.user(authUser.$id)),
        ],
      );

      debugPrint('✅ Service request created: ${requestRow.$id}');

      return ServiceRequestResult.success(
        message: 'Request sent successfully',
        requestId: requestRow.$id,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Send request error: ${e.message}');
      return ServiceRequestResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Send request error: $e');
      return ServiceRequestResult.failure(
          'Failed to send request. Please try again.');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // READ
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get a single service request by ID
  Future<ServiceRequestResult> getRequest(String requestId) async {
    try {
      final row = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.serviceRequests,
        rowId: requestId,
      );

      return ServiceRequestResult.success(
        message: 'Request fetched',
        requestId: row.$id,
        data: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get request error: ${e.message}');
      return ServiceRequestResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Get request error: $e');
      return ServiceRequestResult.failure('Failed to get request');
    }
  }

  /// Get all service requests for a parent
  ///
  /// Optional filters:
  /// - [status]: Filter by request status (pending, accepted, rejected, cancelled)
  /// - [limit]: Number of results to return (default 25)
  /// - [offset]: Pagination offset
  Future<ServiceRequestListResult> getParentRequests({
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
        tableId: Collections.serviceRequests,
        queries: queries,
      );

      return ServiceRequestListResult.success(
        requests: result.rows
            .map((doc) => {'id': doc.$id, ...doc.data})
            .toList(),
        total: result.total,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get parent requests error: ${e.message}');
      return ServiceRequestListResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Get parent requests error: $e');
      return ServiceRequestListResult.failure('Failed to get requests');
    }
  }

  /// Get all service requests for a driver
  ///
  /// Optional filters:
  /// - [status]: Filter by request status (pending, accepted, rejected, cancelled)
  /// - [limit]: Number of results to return (default 25)
  /// - [offset]: Pagination offset
  Future<ServiceRequestListResult> getDriverRequests({
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
        tableId: Collections.serviceRequests,
        queries: queries,
      );

      return ServiceRequestListResult.success(
        requests: result.rows
            .map((doc) => {'id': doc.$id, ...doc.data})
            .toList(),
        total: result.total,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get driver requests error: ${e.message}');
      return ServiceRequestListResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Get driver requests error: $e');
      return ServiceRequestListResult.failure('Failed to get requests');
    }
  }

  /// Get pending requests for a driver (most common use case)
  Future<ServiceRequestListResult> getDriverPendingRequests({
    required String driverId,
    int limit = 25,
    int offset = 0,
  }) async {
    return getDriverRequests(
      driverId: driverId,
      status: CollectionEnums.requestPending,
      limit: limit,
      offset: offset,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UPDATE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Accept a service request (Driver action)
  ///
  /// This changes the request status to 'accepted' and should trigger
  /// creation of an active service in a follow-up step.
  Future<ServiceRequestResult> acceptRequest({
    required String requestId,
    String? responseMessage,
  }) async {
    try {
      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.serviceRequests,
        rowId: requestId,
        data: {
          'status': CollectionEnums.requestAccepted,
          'respondedAt': DateTime.now().toIso8601String(),
          if (responseMessage != null) 'responseMessage': responseMessage,
        },
      );

      debugPrint('✅ Request accepted: $requestId');

      return ServiceRequestResult.success(
        message: 'Request accepted',
        requestId: row.$id,
        data: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Accept request error: ${e.message}');
      return ServiceRequestResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Accept request error: $e');
      return ServiceRequestResult.failure('Failed to accept request');
    }
  }

  /// Reject a service request (Driver action)
  ///
  /// The driver should provide a reason for rejection in [responseMessage].
  Future<ServiceRequestResult> rejectRequest({
    required String requestId,
    String? responseMessage,
  }) async {
    try {
      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.serviceRequests,
        rowId: requestId,
        data: {
          'status': CollectionEnums.requestRejected,
          'respondedAt': DateTime.now().toIso8601String(),
          if (responseMessage != null) 'responseMessage': responseMessage,
        },
      );

      debugPrint('✅ Request rejected: $requestId');

      return ServiceRequestResult.success(
        message: 'Request rejected',
        requestId: row.$id,
        data: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Reject request error: ${e.message}');
      return ServiceRequestResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Reject request error: $e');
      return ServiceRequestResult.failure('Failed to reject request');
    }
  }

  /// Cancel a pending service request (Parent action)
  ///
  /// Only pending requests can be cancelled by the parent.
  Future<ServiceRequestResult> cancelRequest({
    required String requestId,
  }) async {
    try {
      // First verify the request is still pending
      final existingRequest = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.serviceRequests,
        rowId: requestId,
      );

      if (existingRequest.data['status'] != CollectionEnums.requestPending) {
        return ServiceRequestResult.failure(
          'Only pending requests can be cancelled',
        );
      }

      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.serviceRequests,
        rowId: requestId,
        data: {
          'status': CollectionEnums.requestCancelled,
          'respondedAt': DateTime.now().toIso8601String(),
        },
      );

      debugPrint('✅ Request cancelled: $requestId');

      return ServiceRequestResult.success(
        message: 'Request cancelled',
        requestId: row.$id,
        data: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Cancel request error: ${e.message}');
      return ServiceRequestResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Cancel request error: $e');
      return ServiceRequestResult.failure('Failed to cancel request');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DELETE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Delete a service request
  ///
  /// Typically only used for cleanup or admin purposes.
  /// Normal flow should use cancelRequest instead.
  Future<ServiceRequestResult> deleteRequest(String requestId) async {
    try {
      await _tablesDB.deleteRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.serviceRequests,
        rowId: requestId,
      );

      debugPrint('✅ Request deleted: $requestId');

      return ServiceRequestResult.success(
        message: 'Request deleted',
        requestId: requestId,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Delete request error: ${e.message}');
      return ServiceRequestResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Delete request error: $e');
      return ServiceRequestResult.failure('Failed to delete request');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Check if there's an existing pending request for a child-driver pair
  Future<bool> hasPendingRequest({
    required String parentId,
    required String driverId,
    required String childId,
  }) async {
    try {
      final result = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.serviceRequests,
        queries: [
          Query.equal('parentId', parentId),
          Query.equal('driverId', driverId),
          Query.equal('childId', childId),
          Query.equal('status', CollectionEnums.requestPending),
          Query.limit(1),
        ],
      );
      return result.total > 0;
    } catch (e) {
      debugPrint('❌ Check pending request error: $e');
      return false;
    }
  }

  /// Check if a child already has an active service with any driver
  Future<bool> childHasActiveService(String childId) async {
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
      return result.total > 0;
    } catch (e) {
      debugPrint('❌ Check active service error: $e');
      return false;
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
        return 'Request not found';
      case 409:
        return 'Request already exists';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RESULT CLASSES
// ═══════════════════════════════════════════════════════════════════════════

/// Result class for single service request operations
class ServiceRequestResult {
  final bool success;
  final String message;
  final String? requestId;
  final Map<String, dynamic>? data;

  ServiceRequestResult._({
    required this.success,
    required this.message,
    this.requestId,
    this.data,
  });

  factory ServiceRequestResult.success({
    required String message,
    String? requestId,
    Map<String, dynamic>? data,
  }) {
    return ServiceRequestResult._(
      success: true,
      message: message,
      requestId: requestId,
      data: data,
    );
  }

  factory ServiceRequestResult.failure(String message) {
    return ServiceRequestResult._(
      success: false,
      message: message,
    );
  }
}

/// Result class for list operations
class ServiceRequestListResult {
  final bool success;
  final String? message;
  final List<Map<String, dynamic>> requests;
  final int total;

  ServiceRequestListResult._({
    required this.success,
    this.message,
    this.requests = const [],
    this.total = 0,
  });

  factory ServiceRequestListResult.success({
    required List<Map<String, dynamic>> requests,
    required int total,
  }) {
    return ServiceRequestListResult._(
      success: true,
      requests: requests,
      total: total,
    );
  }

  factory ServiceRequestListResult.failure(String message) {
    return ServiceRequestListResult._(
      success: false,
      message: message,
    );
  }
}
