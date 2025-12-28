import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/auth_service.dart';
import 'package:godropme/services/appwrite/database_constants.dart';
import 'package:godropme/services/appwrite/storage_service.dart';

/// Report Service for GoDropMe
///
/// Handles safety reports and complaints:
/// - Submit reports (safety concerns, behavior, delays, etc.)
/// - Upload report attachments
/// - Get user's reports
/// - Track report status
class ReportService {
  static ReportService? _instance;
  static ReportService get instance => _instance ??= ReportService._();

  final TablesDB _tablesDB = AppwriteClient.tablesDBService();

  ReportService._();

  // ═══════════════════════════════════════════════════════════════════════════
  // REPORT OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Submit a new report
  ///
  /// Creates a report for safety concerns, behavior issues, delays, etc.
  ///
  /// ```dart
  /// final result = await ReportService.instance.submitReport(
  ///   reporterId: 'parent_123',
  ///   reporterRole: ReporterRole.parent,
  ///   reportType: ReportType.safetyConcern,
  ///   title: 'Unsafe driving',
  ///   description: 'Driver was speeding on school zone...',
  ///   reportedUserId: 'driver_456',
  /// );
  /// ```
  Future<ReportResult> submitReport({
    required String reporterId,
    required ReporterRole reporterRole,
    required ReportType reportType,
    required String title,
    required String description,
    String? reportedUserId,
    String? tripId,
    List<String>? attachmentUrls,
  }) async {
    try {
      final authUser = AuthService.instance.currentUser;
      if (authUser == null) {
        return ReportResult.failure('Please login first');
      }

      // Validate inputs
      if (title.trim().isEmpty) {
        return ReportResult.failure('Please provide a title for your report');
      }
      if (description.trim().isEmpty) {
        return ReportResult.failure('Please provide a description for your report');
      }
      if (title.length > 150) {
        return ReportResult.failure('Title must be 150 characters or less');
      }
      if (description.length > 2000) {
        return ReportResult.failure('Description must be 2000 characters or less');
      }

      // Create the report
      final reportRow = await _tablesDB.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.reports,
        rowId: ID.unique(),
        data: {
          'reporterId': reporterId,
          'reporterRole': reporterRole.value,
          'reportedUserId': reportedUserId,
          'tripId': tripId,
          'reportType': reportType.value,
          'title': title.trim(),
          'description': description.trim(),
          'attachmentUrls': attachmentUrls ?? [],
          'status': ReportStatus.pending.value,
          'adminNotes': null,
          'resolvedAt': null,
        },
        permissions: [
          Permission.read(Role.user(authUser.$id)),
          Permission.update(Role.user(authUser.$id)),
        ],
      );

      debugPrint('✅ Report submitted: ${reportRow.$id}');

      return ReportResult.success(
        message: 'Report submitted successfully. We will review it shortly.',
        reportId: reportRow.$id,
        data: reportRow.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Report error: ${e.message}');
      return ReportResult.failure(_parseAppwriteError(e));
    } catch (e) {
      debugPrint('❌ Report error: $e');
      return ReportResult.failure('Failed to submit report. Please try again.');
    }
  }

  /// Upload attachment for a report
  ///
  /// Uploads image/document to report_attachments bucket.
  ///
  /// ```dart
  /// final url = await ReportService.instance.uploadAttachment(imageFile);
  /// ```
  Future<String?> uploadAttachment(File file) async {
    try {
      final result = await StorageService.instance.uploadImage(
        bucketId: Buckets.reportAttachments,
        imageFile: file,
        permissions: [
          Permission.read(Role.any()),
        ],
      );

      if (result.success && result.fileId != null) {
        final url = Buckets.getFileUrl(Buckets.reportAttachments, result.fileId!);
        debugPrint('✅ Report attachment uploaded: $url');
        return url;
      }

      debugPrint('❌ Upload attachment failed: ${result.message}');
      return null;
    } catch (e) {
      debugPrint('❌ Upload attachment error: $e');
      return null;
    }
  }

  /// Upload multiple attachments
  ///
  /// ```dart
  /// final urls = await ReportService.instance.uploadAttachments(files);
  /// ```
  Future<List<String>> uploadAttachments(List<File> files) async {
    final urls = <String>[];
    
    for (final file in files) {
      final url = await uploadAttachment(file);
      if (url != null) {
        urls.add(url);
      }
    }
    
    return urls;
  }

  /// Get reports submitted by a user
  ///
  /// ```dart
  /// final result = await ReportService.instance.getReports(
  ///   userId: 'parent_123',
  ///   role: ReporterRole.parent,
  /// );
  /// ```
  Future<ReportListResult> getReports({
    required String userId,
    required ReporterRole role,
    ReportStatus? status,
    int limit = 25,
    int offset = 0,
  }) async {
    try {
      final queries = <String>[
        Query.equal('reporterId', userId),
        Query.equal('reporterRole', role.value),
        Query.orderDesc('\$createdAt'),
        Query.limit(limit),
        Query.offset(offset),
      ];

      if (status != null) {
        queries.add(Query.equal('status', status.value));
      }

      final reports = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.reports,
        queries: queries,
      );

      final reportsList = reports.rows.map((row) => Report.fromMap(row.$id, row.data)).toList();

      debugPrint('✅ Fetched ${reportsList.length} reports for user $userId');

      return ReportListResult.success(
        message: 'Reports fetched successfully',
        reports: reportsList,
        total: reports.total,
        hasMore: offset + reportsList.length < reports.total,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get reports error: ${e.message}');
      return ReportListResult.failure(_parseAppwriteError(e));
    } catch (e) {
      debugPrint('❌ Get reports error: $e');
      return ReportListResult.failure('Failed to fetch reports. Please try again.');
    }
  }

  /// Get a specific report by ID
  ///
  /// ```dart
  /// final result = await ReportService.instance.getReport('report_123');
  /// ```
  Future<ReportResult> getReport(String reportId) async {
    try {
      final report = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.reports,
        rowId: reportId,
      );

      return ReportResult.success(
        message: 'Report fetched successfully',
        reportId: report.$id,
        data: report.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get report error: ${e.message}');
      return ReportResult.failure(_parseAppwriteError(e));
    } catch (e) {
      debugPrint('❌ Get report error: $e');
      return ReportResult.failure('Failed to fetch report. Please try again.');
    }
  }

  /// Get reports against a user (for admin)
  ///
  /// ```dart
  /// final result = await ReportService.instance.getReportsAgainst('driver_123');
  /// ```
  Future<ReportListResult> getReportsAgainst({
    required String userId,
    ReportStatus? status,
    int limit = 25,
    int offset = 0,
  }) async {
    try {
      final queries = <String>[
        Query.equal('reportedUserId', userId),
        Query.orderDesc('\$createdAt'),
        Query.limit(limit),
        Query.offset(offset),
      ];

      if (status != null) {
        queries.add(Query.equal('status', status.value));
      }

      final reports = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.reports,
        queries: queries,
      );

      final reportsList = reports.rows.map((row) => Report.fromMap(row.$id, row.data)).toList();

      debugPrint('✅ Fetched ${reportsList.length} reports against user $userId');

      return ReportListResult.success(
        message: 'Reports fetched successfully',
        reports: reportsList,
        total: reports.total,
        hasMore: offset + reportsList.length < reports.total,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get reports against error: ${e.message}');
      return ReportListResult.failure(_parseAppwriteError(e));
    } catch (e) {
      debugPrint('❌ Get reports against error: $e');
      return ReportListResult.failure('Failed to fetch reports. Please try again.');
    }
  }

  /// Get count of pending reports for a user
  ///
  /// Useful for showing badge counts.
  Future<int> getPendingReportsCount(String userId, ReporterRole role) async {
    try {
      final reports = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.reports,
        queries: [
          Query.equal('reporterId', userId),
          Query.equal('reporterRole', role.value),
          Query.equal('status', ReportStatus.pending.value),
          Query.limit(1),
        ],
        total: true,
      );

      return reports.total;
    } catch (e) {
      debugPrint('❌ Get pending reports count error: $e');
      return 0;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Parse Appwrite exceptions into user-friendly messages
  String _parseAppwriteError(AppwriteException e) {
    switch (e.code) {
      case 401:
        return 'Please login to continue.';
      case 403:
        return 'You don\'t have permission to perform this action.';
      case 404:
        return 'Report not found.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ENUMS
// ═══════════════════════════════════════════════════════════════════════════

/// Reporter role enum (matches Appwrite enum)
enum ReporterRole {
  parent('parent'),
  driver('driver');

  final String value;
  const ReporterRole(this.value);

  static ReporterRole fromString(String value) {
    return ReporterRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReporterRole.parent,
    );
  }
}

/// Report type enum (matches Appwrite enum)
enum ReportType {
  safetyConcern('safety_concern'),
  behavior('behavior'),
  delay('delay'),
  noShow('no_show'),
  damage('damage'),
  payment('payment'),
  other('other');

  final String value;
  const ReportType(this.value);

  String get displayName {
    switch (this) {
      case ReportType.safetyConcern:
        return 'Safety Concern';
      case ReportType.behavior:
        return 'Behavior Issue';
      case ReportType.delay:
        return 'Delay';
      case ReportType.noShow:
        return 'No Show';
      case ReportType.damage:
        return 'Damage';
      case ReportType.payment:
        return 'Payment Issue';
      case ReportType.other:
        return 'Other';
    }
  }

  static ReportType fromString(String value) {
    return ReportType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReportType.other,
    );
  }
}

/// Report status enum (matches Appwrite enum)
enum ReportStatus {
  pending('pending'),
  underReview('under_review'),
  resolved('resolved'),
  dismissed('dismissed');

  final String value;
  const ReportStatus(this.value);

  String get displayName {
    switch (this) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.underReview:
        return 'Under Review';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.dismissed:
        return 'Dismissed';
    }
  }

  static ReportStatus fromString(String value) {
    return ReportStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReportStatus.pending,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MODELS
// ═══════════════════════════════════════════════════════════════════════════

/// Report model
class Report {
  final String id;
  final String reporterId;
  final ReporterRole reporterRole;
  final String? reportedUserId;
  final String? tripId;
  final ReportType reportType;
  final String title;
  final String description;
  final List<String> attachmentUrls;
  final ReportStatus status;
  final String? adminNotes;
  final DateTime? resolvedAt;
  final DateTime createdAt;

  const Report({
    required this.id,
    required this.reporterId,
    required this.reporterRole,
    this.reportedUserId,
    this.tripId,
    required this.reportType,
    required this.title,
    required this.description,
    this.attachmentUrls = const [],
    this.status = ReportStatus.pending,
    this.adminNotes,
    this.resolvedAt,
    required this.createdAt,
  });

  factory Report.fromMap(String id, Map<String, dynamic> map) {
    return Report(
      id: id,
      reporterId: map['reporterId'] ?? '',
      reporterRole: ReporterRole.fromString(map['reporterRole'] ?? 'parent'),
      reportedUserId: map['reportedUserId'],
      tripId: map['tripId'],
      reportType: ReportType.fromString(map['reportType'] ?? 'other'),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      attachmentUrls: (map['attachmentUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: ReportStatus.fromString(map['status'] ?? 'pending'),
      adminNotes: map['adminNotes'],
      resolvedAt: map['resolvedAt'] != null
          ? DateTime.parse(map['resolvedAt'])
          : null,
      createdAt: DateTime.parse(map['\$createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() => {
    'reporterId': reporterId,
    'reporterRole': reporterRole.value,
    'reportedUserId': reportedUserId,
    'tripId': tripId,
    'reportType': reportType.value,
    'title': title,
    'description': description,
    'attachmentUrls': attachmentUrls,
    'status': status.value,
    'adminNotes': adminNotes,
    'resolvedAt': resolvedAt?.toIso8601String(),
  };
}

// ═══════════════════════════════════════════════════════════════════════════
// RESULT CLASSES
// ═══════════════════════════════════════════════════════════════════════════

/// Result of a report operation
class ReportResult {
  final bool success;
  final String message;
  final String? reportId;
  final Map<String, dynamic>? data;

  const ReportResult._({
    required this.success,
    required this.message,
    this.reportId,
    this.data,
  });

  factory ReportResult.success({
    required String message,
    String? reportId,
    Map<String, dynamic>? data,
  }) {
    return ReportResult._(
      success: true,
      message: message,
      reportId: reportId,
      data: data,
    );
  }

  factory ReportResult.failure(String message) {
    return ReportResult._(
      success: false,
      message: message,
    );
  }
}

/// Result of fetching reports list
class ReportListResult {
  final bool success;
  final String message;
  final List<Report> reports;
  final int total;
  final bool hasMore;

  const ReportListResult._({
    required this.success,
    required this.message,
    this.reports = const [],
    this.total = 0,
    this.hasMore = false,
  });

  factory ReportListResult.success({
    required String message,
    required List<Report> reports,
    required int total,
    required bool hasMore,
  }) {
    return ReportListResult._(
      success: true,
      message: message,
      reports: reports,
      total: total,
      hasMore: hasMore,
    );
  }

  factory ReportListResult.failure(String message) {
    return ReportListResult._(
      success: false,
      message: message,
    );
  }
}
