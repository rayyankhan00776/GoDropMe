import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/auth_service.dart';
import 'package:godropme/services/appwrite/database_constants.dart';

/// Rating Service for GoDropMe
///
/// Handles driver rating operations:
/// - Submit ratings for drivers
/// - Get driver ratings
/// - Calculate average ratings
/// - Check if parent can rate a driver
class RatingService {
  static RatingService? _instance;
  static RatingService get instance => _instance ??= RatingService._();

  final TablesDB _tablesDB = AppwriteClient.tablesDBService();

  RatingService._();

  // ═══════════════════════════════════════════════════════════════════════════
  // RATING OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Submit a rating for a driver
  ///
  /// Parents can rate drivers they have an active or completed service with.
  /// Rating must be between 1-5.
  ///
  /// ```dart
  /// final result = await RatingService.instance.rateDriver(
  ///   driverId: 'driver_123',
  ///   parentId: 'parent_456',
  ///   rating: 5,
  ///   review: 'Great service!',
  /// );
  /// ```
  Future<RatingResult> rateDriver({
    required String driverId,
    required String parentId,
    required int rating,
    String? tripId,
    String? review,
  }) async {
    try {
      final authUser = AuthService.instance.currentUser;
      if (authUser == null) {
        return RatingResult.failure('Please login first');
      }

      // Validate rating range
      if (rating < 1 || rating > 5) {
        return RatingResult.failure('Rating must be between 1 and 5');
      }

      // Check if parent already rated this driver recently (prevent spam)
      final existingRating = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.ratings,
        queries: [
          Query.equal('driverId', driverId),
          Query.equal('parentId', parentId),
          Query.orderDesc('createdAt'),
          Query.limit(1),
        ],
      );

      // If rated within last 30 days, prevent duplicate
      if (existingRating.total > 0) {
        final lastRating = existingRating.rows.first;
        final lastRatingDate = DateTime.parse(lastRating.data['createdAt']);
        final daysSinceLastRating = DateTime.now().difference(lastRatingDate).inDays;
        
        if (daysSinceLastRating < 30) {
          return RatingResult.failure(
            'You already rated this driver $daysSinceLastRating days ago. '
            'You can rate again after ${30 - daysSinceLastRating} days.',
          );
        }
      }

      // Create the rating
      final ratingRow = await _tablesDB.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.ratings,
        rowId: ID.unique(),
        data: {
          'driverId': driverId,
          'parentId': parentId,
          'tripId': tripId,
          'rating': rating,
          'review': review,
          'createdAt': DateTime.now().toIso8601String(),
        },
        permissions: [
          Permission.read(Role.any()),
        ],
      );

      debugPrint('✅ Rating submitted: ${ratingRow.$id}');

      // Update driver's average rating
      await _updateDriverAverageRating(driverId);

      return RatingResult.success(
        message: 'Rating submitted successfully',
        ratingId: ratingRow.$id,
        data: ratingRow.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Rating error: ${e.message}');
      return RatingResult.failure(_parseAppwriteError(e));
    } catch (e) {
      debugPrint('❌ Rating error: $e');
      return RatingResult.failure('Failed to submit rating. Please try again.');
    }
  }

  /// Get all ratings for a driver
  ///
  /// Returns paginated list of ratings with optional filtering.
  ///
  /// ```dart
  /// final result = await RatingService.instance.getDriverRatings(
  ///   driverId: 'driver_123',
  ///   limit: 10,
  /// );
  /// ```
  Future<RatingListResult> getDriverRatings({
    required String driverId,
    int limit = 25,
    int offset = 0,
  }) async {
    try {
      final ratings = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.ratings,
        queries: [
          Query.equal('driverId', driverId),
          Query.orderDesc('createdAt'),
          Query.limit(limit),
          Query.offset(offset),
        ],
      );

      final ratingsList = ratings.rows.map((row) => Rating.fromMap(row.$id, row.data)).toList();

      debugPrint('✅ Fetched ${ratingsList.length} ratings for driver $driverId');

      return RatingListResult.success(
        message: 'Ratings fetched successfully',
        ratings: ratingsList,
        total: ratings.total,
        hasMore: offset + ratingsList.length < ratings.total,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get ratings error: ${e.message}');
      return RatingListResult.failure(_parseAppwriteError(e));
    } catch (e) {
      debugPrint('❌ Get ratings error: $e');
      return RatingListResult.failure('Failed to fetch ratings. Please try again.');
    }
  }

  /// Get average rating for a driver
  ///
  /// Calculates the average from all ratings.
  ///
  /// ```dart
  /// final result = await RatingService.instance.getDriverAverageRating('driver_123');
  /// print('Average: ${result.averageRating}, Total: ${result.totalRatings}');
  /// ```
  Future<AverageRatingResult> getDriverAverageRating(String driverId) async {
    try {
      final ratings = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.ratings,
        queries: [
          Query.equal('driverId', driverId),
          Query.limit(1000), // Get all ratings
        ],
      );

      if (ratings.total == 0) {
        return AverageRatingResult.success(
          averageRating: 0.0,
          totalRatings: 0,
          ratingDistribution: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        );
      }

      // Calculate average and distribution
      int total = 0;
      final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (final row in ratings.rows) {
        final ratingValue = row.data['rating'] as int;
        total += ratingValue;
        distribution[ratingValue] = (distribution[ratingValue] ?? 0) + 1;
      }

      final average = total / ratings.total;

      debugPrint('✅ Driver $driverId average rating: ${average.toStringAsFixed(1)}');

      return AverageRatingResult.success(
        averageRating: double.parse(average.toStringAsFixed(1)),
        totalRatings: ratings.total,
        ratingDistribution: distribution,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get average rating error: ${e.message}');
      return AverageRatingResult.failure(_parseAppwriteError(e));
    } catch (e) {
      debugPrint('❌ Get average rating error: $e');
      return AverageRatingResult.failure('Failed to fetch rating. Please try again.');
    }
  }

  /// Check if a parent can rate a specific driver
  ///
  /// Returns true if parent has/had an active service with the driver
  /// and hasn't rated in the last 30 days.
  ///
  /// ```dart
  /// final canRate = await RatingService.instance.canRate(
  ///   parentId: 'parent_123',
  ///   driverId: 'driver_456',
  /// );
  /// ```
  Future<CanRateResult> canRate({
    required String parentId,
    required String driverId,
  }) async {
    try {
      // Check if parent has any active/completed service with this driver
      final services = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.activeServices,
        queries: [
          Query.equal('parentId', parentId),
          Query.equal('driverId', driverId),
          Query.limit(1),
        ],
      );

      if (services.total == 0) {
        return CanRateResult(
          canRate: false,
          reason: 'You need to have a service with this driver to rate them.',
        );
      }

      // Check for recent rating
      final recentRating = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.ratings,
        queries: [
          Query.equal('driverId', driverId),
          Query.equal('parentId', parentId),
          Query.orderDesc('createdAt'),
          Query.limit(1),
        ],
      );

      if (recentRating.total > 0) {
        final lastRatingDate = DateTime.parse(recentRating.rows.first.data['createdAt']);
        final daysSinceLastRating = DateTime.now().difference(lastRatingDate).inDays;
        
        if (daysSinceLastRating < 30) {
          return CanRateResult(
            canRate: false,
            reason: 'You can rate again in ${30 - daysSinceLastRating} days.',
            lastRatingDate: lastRatingDate,
          );
        }
      }

      return CanRateResult(canRate: true);
    } on AppwriteException catch (e) {
      debugPrint('❌ Can rate check error: ${e.message}');
      return CanRateResult(
        canRate: false,
        reason: _parseAppwriteError(e),
      );
    } catch (e) {
      debugPrint('❌ Can rate check error: $e');
      return CanRateResult(
        canRate: false,
        reason: 'Unable to check rating eligibility.',
      );
    }
  }

  /// Get ratings given by a parent
  ///
  /// ```dart
  /// final result = await RatingService.instance.getParentRatings(
  ///   parentId: 'parent_123',
  /// );
  /// ```
  Future<RatingListResult> getParentRatings({
    required String parentId,
    int limit = 25,
    int offset = 0,
  }) async {
    try {
      final ratings = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.ratings,
        queries: [
          Query.equal('parentId', parentId),
          Query.orderDesc('createdAt'),
          Query.limit(limit),
          Query.offset(offset),
        ],
      );

      final ratingsList = ratings.rows.map((row) => Rating.fromMap(row.$id, row.data)).toList();

      return RatingListResult.success(
        message: 'Ratings fetched successfully',
        ratings: ratingsList,
        total: ratings.total,
        hasMore: offset + ratingsList.length < ratings.total,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get parent ratings error: ${e.message}');
      return RatingListResult.failure(_parseAppwriteError(e));
    } catch (e) {
      debugPrint('❌ Get parent ratings error: $e');
      return RatingListResult.failure('Failed to fetch ratings. Please try again.');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INTERNAL HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Update driver's average rating in drivers table
  Future<void> _updateDriverAverageRating(String driverId) async {
    try {
      final avgResult = await getDriverAverageRating(driverId);
      if (avgResult.success) {
        await _tablesDB.updateRow(
          databaseId: AppwriteConfig.databaseId,
          tableId: Collections.drivers,
          rowId: driverId,
          data: {
            'rating': avgResult.averageRating,
            'totalRatings': avgResult.totalRatings,
          },
        );
        debugPrint('✅ Updated driver $driverId rating to ${avgResult.averageRating}');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to update driver average rating: $e');
      // Non-critical error, don't throw
    }
  }

  /// Parse Appwrite exceptions into user-friendly messages
  String _parseAppwriteError(AppwriteException e) {
    switch (e.code) {
      case 401:
        return 'Please login to continue.';
      case 403:
        return 'You don\'t have permission to perform this action.';
      case 404:
        return 'Rating not found.';
      case 409:
        return 'Rating already exists.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MODELS
// ═══════════════════════════════════════════════════════════════════════════

/// Rating model
class Rating {
  final String id;
  final String driverId;
  final String parentId;
  final String? tripId;
  final int rating;
  final String? review;
  final DateTime createdAt;

  const Rating({
    required this.id,
    required this.driverId,
    required this.parentId,
    this.tripId,
    required this.rating,
    this.review,
    required this.createdAt,
  });

  factory Rating.fromMap(String id, Map<String, dynamic> map) {
    return Rating(
      id: id,
      driverId: map['driverId'] ?? '',
      parentId: map['parentId'] ?? '',
      tripId: map['tripId'],
      rating: map['rating'] ?? 0,
      review: map['review'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() => {
    'driverId': driverId,
    'parentId': parentId,
    'tripId': tripId,
    'rating': rating,
    'review': review,
    'createdAt': createdAt.toIso8601String(),
  };
}

// ═══════════════════════════════════════════════════════════════════════════
// RESULT CLASSES
// ═══════════════════════════════════════════════════════════════════════════

/// Result of a rating operation
class RatingResult {
  final bool success;
  final String message;
  final String? ratingId;
  final Map<String, dynamic>? data;

  const RatingResult._({
    required this.success,
    required this.message,
    this.ratingId,
    this.data,
  });

  factory RatingResult.success({
    required String message,
    String? ratingId,
    Map<String, dynamic>? data,
  }) {
    return RatingResult._(
      success: true,
      message: message,
      ratingId: ratingId,
      data: data,
    );
  }

  factory RatingResult.failure(String message) {
    return RatingResult._(
      success: false,
      message: message,
    );
  }
}

/// Result of fetching ratings list
class RatingListResult {
  final bool success;
  final String message;
  final List<Rating> ratings;
  final int total;
  final bool hasMore;

  const RatingListResult._({
    required this.success,
    required this.message,
    this.ratings = const [],
    this.total = 0,
    this.hasMore = false,
  });

  factory RatingListResult.success({
    required String message,
    required List<Rating> ratings,
    required int total,
    required bool hasMore,
  }) {
    return RatingListResult._(
      success: true,
      message: message,
      ratings: ratings,
      total: total,
      hasMore: hasMore,
    );
  }

  factory RatingListResult.failure(String message) {
    return RatingListResult._(
      success: false,
      message: message,
    );
  }
}

/// Result of average rating calculation
class AverageRatingResult {
  final bool success;
  final String? message;
  final double averageRating;
  final int totalRatings;
  final Map<int, int> ratingDistribution;

  const AverageRatingResult._({
    required this.success,
    this.message,
    this.averageRating = 0.0,
    this.totalRatings = 0,
    this.ratingDistribution = const {},
  });

  factory AverageRatingResult.success({
    required double averageRating,
    required int totalRatings,
    required Map<int, int> ratingDistribution,
  }) {
    return AverageRatingResult._(
      success: true,
      averageRating: averageRating,
      totalRatings: totalRatings,
      ratingDistribution: ratingDistribution,
    );
  }

  factory AverageRatingResult.failure(String message) {
    return AverageRatingResult._(
      success: false,
      message: message,
    );
  }
}

/// Result of can rate check
class CanRateResult {
  final bool canRate;
  final String? reason;
  final DateTime? lastRatingDate;

  const CanRateResult({
    required this.canRate,
    this.reason,
    this.lastRatingDate,
  });
}
