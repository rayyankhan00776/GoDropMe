import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:godropme/features/parentSide/addChildren/models/child.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/auth_service.dart';
import 'package:godropme/services/appwrite/database_constants.dart';
import 'package:godropme/services/appwrite/storage_service.dart';

/// Child Service for GoDropMe
/// 
/// Handles child CRUD operations:
/// - Add children during parent registration
/// - Get children for a parent
/// - Update child information
/// - Delete child
/// - Upload/update child photos
class ChildService {
  static ChildService? _instance;
  static ChildService get instance => _instance ??= ChildService._();
  
  final TablesDB _tablesDB = AppwriteClient.tablesDBService();
  final StorageService _storage = StorageService.instance;
  
  ChildService._();
  
  // ═══════════════════════════════════════════════════════════════════════════
  // CREATE
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Add a new child for a parent
  /// 
  /// ```dart
  /// final result = await ChildService.instance.addChild(
  ///   parentId: 'parent123',
  ///   child: childModel,
  ///   photo: imageFile, // optional
  /// );
  /// if (result.success) {
  ///   print('Child added: ${result.child!.id}');
  /// }
  /// ```
  Future<ChildResult> addChild({
    required String parentId,
    required ChildModel child,
    File? photo,
  }) async {
    try {
      String? photoUrl;
      
      // Upload photo if provided
      if (photo != null) {
        final uploadResult = await _storage.uploadImage(
          bucketId: Buckets.childPhotos,
          imageFile: photo,
          fileName: 'child_${parentId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        
        if (uploadResult.success) {
          // Build the file URL for storage
          photoUrl = Buckets.getFileUrl(Buckets.childPhotos, uploadResult.fileId!);
          debugPrint('📷 Child photo uploaded: ${uploadResult.fileId}');
        } else {
          debugPrint('⚠️ Photo upload failed: ${uploadResult.message}');
          // Continue without photo - not a critical error
        }
      }
      
      // Prepare row data
      final data = _buildChildData(parentId, child, photoUrl: photoUrl);
      
      // Create child row using TablesDB
      final row = await _tablesDB.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.children,
        rowId: ID.unique(),
        data: data,
      );
      
      debugPrint('✅ Child added: ${row.$id}');
      
      return ChildResult.success(
        message: 'Child added successfully',
        child: ChildModel.fromJson(row.data),
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Add child error: ${e.message}');
      return ChildResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Add child error: $e');
      return ChildResult.failure('Failed to add child. Please try again.');
    }
  }
  
  /// Add multiple children at once (batch operation)
  /// 
  /// Useful when parent registers with multiple children.
  /// Returns list of successfully added children and any failures.
  Future<ChildBatchResult> addChildren({
    required String parentId,
    required List<ChildModel> children,
    Map<int, File>? photos, // Index -> Photo file
  }) async {
    final List<ChildModel> successful = [];
    final List<String> failures = [];
    
    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      final photo = photos?[i];
      
      final result = await addChild(
        parentId: parentId,
        child: child,
        photo: photo,
      );
      
      if (result.success && result.child != null) {
        successful.add(result.child!);
      } else {
        failures.add('${child.name}: ${result.message}');
      }
    }
    
    if (failures.isEmpty) {
      return ChildBatchResult.success(
        message: 'All ${children.length} children added successfully',
        children: successful,
      );
    } else if (successful.isEmpty) {
      return ChildBatchResult.failure(
        'Failed to add children: ${failures.join(", ")}',
      );
    } else {
      return ChildBatchResult.partial(
        message: '${successful.length}/${children.length} children added',
        children: successful,
        failures: failures,
      );
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // READ
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Get all children for a parent
  /// 
  /// ```dart
  /// final result = await ChildService.instance.getChildren(parentId: 'abc123');
  /// if (result.success) {
  ///   for (final child in result.children) {
  ///     print('Child: ${child.name}');
  ///   }
  /// }
  /// ```
  Future<ChildListResult> getChildren({String? parentId}) async {
    try {
      // Use provided parentId or get current user's parent profile
      String? targetParentId = parentId;
      
      if (targetParentId == null) {
        // Get parent ID from current user
        final userId = AuthService.instance.currentUser?.$id;
        if (userId == null) {
          return ChildListResult.failure('Not authenticated. Please login again.');
        }
        
        // Get parent row for current user
        final parentResult = await _tablesDB.listRows(
          databaseId: AppwriteConfig.databaseId,
          tableId: Collections.parents,
          queries: [Query.equal('userId', userId), Query.limit(1)],
        );
        
        if (parentResult.rows.isEmpty) {
          return ChildListResult.failure('Parent profile not found.');
        }
        
        targetParentId = parentResult.rows.first.$id;
      }
      
      // Query children by parentId
      final result = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.children,
        queries: [
          Query.equal('parentId', targetParentId),
          Query.orderDesc('\$createdAt'),
        ],
      );
      
      final children = result.rows
          .map((row) => ChildModel.fromJson(row.data))
          .toList();
      
      debugPrint('✅ Loaded ${children.length} children for parent: $targetParentId');
      
      return ChildListResult.success(
        message: 'Children loaded successfully',
        children: children,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get children error: ${e.message}');
      return ChildListResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Get children error: $e');
      return ChildListResult.failure('Failed to load children. Please try again.');
    }
  }
  
  /// Get a single child by ID
  Future<ChildResult> getChild(String childId) async {
    try {
      final row = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.children,
        rowId: childId,
      );
      
      debugPrint('✅ Child loaded: ${row.$id}');
      
      return ChildResult.success(
        message: 'Child loaded successfully',
        child: ChildModel.fromJson(row.data),
      );
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        return ChildResult.notFound();
      }
      debugPrint('❌ Get child error: ${e.message}');
      return ChildResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Get child error: $e');
      return ChildResult.failure('Failed to load child. Please try again.');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // UPDATE
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Update child information
  /// 
  /// ```dart
  /// final result = await ChildService.instance.updateChild(
  ///   childId: 'child123',
  ///   name: 'Updated Name',
  ///   schoolId: 'school456',
  /// );
  /// ```
  Future<ChildResult> updateChild({
    required String childId,
    String? name,
    int? age,
    String? gender,
    String? schoolId,
    String? pickPoint,
    String? dropPoint,
    String? relationshipToChild,
    String? schoolOpenTime,
    String? schoolOffTime,
    List<double>? pickLocation,
    List<double>? dropLocation,
    String? specialNotes,
    bool? isActive,
  }) async {
    try {
      // Build update data (only include non-null fields)
      final data = <String, dynamic>{};
      
      if (name != null) data['name'] = name;
      if (age != null) data['age'] = age;
      if (gender != null) data['gender'] = gender;
      if (schoolId != null) data['schoolId'] = schoolId;
      if (pickPoint != null) data['pickPoint'] = pickPoint;
      if (dropPoint != null) data['dropPoint'] = dropPoint;
      if (relationshipToChild != null) data['relationshipToChild'] = relationshipToChild;
      if (schoolOpenTime != null) data['schoolOpenTime'] = schoolOpenTime;
      if (schoolOffTime != null) data['schoolOffTime'] = schoolOffTime;
      if (pickLocation != null) data['pickLocation'] = pickLocation;
      if (dropLocation != null) data['dropLocation'] = dropLocation;
      if (specialNotes != null) data['specialNotes'] = specialNotes;
      if (isActive != null) data['isActive'] = isActive;
      
      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.children,
        rowId: childId,
        data: data,
      );
      
      debugPrint('✅ Child updated: ${row.$id}');
      
      return ChildResult.success(
        message: 'Child updated successfully',
        child: ChildModel.fromJson(row.data),
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Update child error: ${e.message}');
      return ChildResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Update child error: $e');
      return ChildResult.failure('Failed to update child. Please try again.');
    }
  }
  
  /// Update child photo
  Future<ChildResult> updateChildPhoto({
    required String childId,
    required File photo,
    String? oldPhotoUrl,
  }) async {
    try {
      // Delete old photo if exists (extract file ID from URL)
      if (oldPhotoUrl != null && oldPhotoUrl.isNotEmpty) {
        final oldFileId = _extractFileIdFromUrl(oldPhotoUrl);
        if (oldFileId != null) {
          await _storage.deleteFile(
            bucketId: Buckets.childPhotos,
            fileId: oldFileId,
          );
          debugPrint('🗑️ Old child photo deleted: $oldFileId');
        }
      }
      
      // Upload new photo
      final uploadResult = await _storage.uploadImage(
        bucketId: Buckets.childPhotos,
        imageFile: photo,
        fileName: 'child_${childId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      
      if (!uploadResult.success) {
        return ChildResult.failure(uploadResult.message);
      }
      
      debugPrint('📷 New child photo uploaded: ${uploadResult.fileId}');
      
      // Build the file URL for storage
      final photoUrl = Buckets.getFileUrl(Buckets.childPhotos, uploadResult.fileId!);
      
      // Update child row with new photo URL
      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.children,
        rowId: childId,
        data: {
          'photoUrl': photoUrl,
        },
      );
      
      debugPrint('✅ Child photo updated: ${row.$id}');
      
      return ChildResult.success(
        message: 'Photo updated successfully',
        child: ChildModel.fromJson(row.data),
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Update child photo error: ${e.message}');
      return ChildResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Update child photo error: $e');
      return ChildResult.failure('Failed to update photo. Please try again.');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // DELETE
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Delete a child
  Future<ChildResult> deleteChild({
    required String childId,
    String? photoUrl,
  }) async {
    try {
      // Delete photo if exists (extract file ID from URL)
      if (photoUrl != null && photoUrl.isNotEmpty) {
        final fileId = _extractFileIdFromUrl(photoUrl);
        if (fileId != null) {
          await _storage.deleteFile(
            bucketId: Buckets.childPhotos,
            fileId: fileId,
          );
          debugPrint('🗑️ Child photo deleted: $fileId');
        }
      }
      
      // Delete child row using TablesDB
      await _tablesDB.deleteRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.children,
        rowId: childId,
      );
      
      debugPrint('✅ Child deleted: $childId');
      
      return ChildResult.success(message: 'Child deleted successfully');
    } on AppwriteException catch (e) {
      debugPrint('❌ Delete child error: ${e.message}');
      return ChildResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Delete child error: $e');
      return ChildResult.failure('Failed to delete child. Please try again.');
    }
  }
  
  /// Delete all children for a parent
  Future<ChildResult> deleteAllChildren(String parentId) async {
    try {
      // Get all children for parent
      final listResult = await getChildren(parentId: parentId);
      
      if (!listResult.success) {
        return ChildResult.failure(listResult.message);
      }
      
      // Delete each child (including photos)
      for (final child in listResult.children) {
        if (child.id != null) {
          await deleteChild(
            childId: child.id!,
            photoUrl: child.photoUrl,
          );
        }
      }
      
      debugPrint('✅ All children deleted for parent: $parentId');
      
      return ChildResult.success(
        message: 'All children deleted successfully',
      );
    } catch (e) {
      debugPrint('❌ Delete all children error: $e');
      return ChildResult.failure('Failed to delete children. Please try again.');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Get child photo URL
  String? getChildPhotoUrl(String? fileId, {int? size}) {
    if (fileId == null || fileId.isEmpty) return null;
    
    if (size != null) {
      return Buckets.getPreviewUrl(
        Buckets.childPhotos,
        fileId,
        width: size,
        height: size,
      );
    }
    
    return Buckets.getFileUrl(Buckets.childPhotos, fileId);
  }
  
  /// Build child document data for Appwrite
  Map<String, dynamic> _buildChildData(
    String parentId,
    ChildModel child, {
    String? photoUrl,
  }) {
    final data = <String, dynamic>{
      'parentId': parentId,
      'name': child.name,
      'age': child.age,
      'gender': child.gender,
      'schoolId': child.schoolId, // FK to schools table
      'pickPoint': child.pickPoint,
      'dropPoint': child.dropPoint,
      'relationshipToChild': child.relationshipToChild,
      'pickLocation': child.pickLocation, // [lng, lat]
      'dropLocation': child.dropLocation, // [lng, lat]
      'isActive': child.isActive,
    };
    
    // Only add optional fields if they have values
    // URL fields must be valid URLs or omitted entirely
    final photo = photoUrl ?? child.photoUrl;
    if (photo != null && photo.isNotEmpty) {
      data['photoUrl'] = photo;
    }
    
    // School location is now looked up from schools table using schoolId
    // No need to store schoolLocation in children table
    
    if (child.schoolOpenTime != null && child.schoolOpenTime!.isNotEmpty) {
      data['schoolOpenTime'] = child.schoolOpenTime;
    }
    
    if (child.schoolOffTime != null && child.schoolOffTime!.isNotEmpty) {
      data['schoolOffTime'] = child.schoolOffTime;
    }
    
    if (child.specialNotes != null && child.specialNotes!.isNotEmpty) {
      data['specialNotes'] = child.specialNotes;
    }
    
    if (child.assignedDriverId != null && child.assignedDriverId!.isNotEmpty) {
      data['assignedDriverId'] = child.assignedDriverId;
    }
    
    return data;
  }
  
  String _parseError(AppwriteException e) {
    switch (e.code) {
      case 401:
        return 'Session expired. Please login again.';
      case 404:
        return 'Child not found.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return e.message ?? 'Operation failed.';
    }
  }
  
  /// Extract file ID from Appwrite storage URL
  /// URL format: https://[endpoint]/v1/storage/buckets/[bucket]/files/[fileId]/view
  String? _extractFileIdFromUrl(String url) {
    try {
      // Pattern: .../files/[fileId]/...
      final regex = RegExp(r'/files/([^/]+)/');
      final match = regex.firstMatch(url);
      return match?.group(1);
    } catch (e) {
      debugPrint('⚠️ Failed to extract file ID from URL: $url');
      return null;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RESULT CLASSES
// ═══════════════════════════════════════════════════════════════════════════

/// Result of a single child operation
class ChildResult {
  final bool success;
  final String message;
  final ChildModel? child;
  final bool notFound;
  
  const ChildResult._({
    required this.success,
    required this.message,
    this.child,
    this.notFound = false,
  });
  
  factory ChildResult.success({
    required String message,
    ChildModel? child,
  }) {
    return ChildResult._(
      success: true,
      message: message,
      child: child,
    );
  }
  
  factory ChildResult.failure(String message) {
    return ChildResult._(
      success: false,
      message: message,
    );
  }
  
  factory ChildResult.notFound() {
    return const ChildResult._(
      success: false,
      message: 'Child not found',
      notFound: true,
    );
  }
}

/// Result for listing children
class ChildListResult {
  final bool success;
  final String message;
  final List<ChildModel> children;
  
  const ChildListResult._({
    required this.success,
    required this.message,
    required this.children,
  });
  
  factory ChildListResult.success({
    required String message,
    required List<ChildModel> children,
  }) {
    return ChildListResult._(
      success: true,
      message: message,
      children: children,
    );
  }
  
  factory ChildListResult.failure(String message) {
    return ChildListResult._(
      success: false,
      message: message,
      children: [],
    );
  }
}

/// Result for batch child operations
class ChildBatchResult {
  final bool success;
  final String message;
  final List<ChildModel> children;
  final List<String> failures;
  final bool partial;
  
  const ChildBatchResult._({
    required this.success,
    required this.message,
    required this.children,
    this.failures = const [],
    this.partial = false,
  });
  
  factory ChildBatchResult.success({
    required String message,
    required List<ChildModel> children,
  }) {
    return ChildBatchResult._(
      success: true,
      message: message,
      children: children,
    );
  }
  
  factory ChildBatchResult.failure(String message) {
    return ChildBatchResult._(
      success: false,
      message: message,
      children: [],
    );
  }
  
  factory ChildBatchResult.partial({
    required String message,
    required List<ChildModel> children,
    required List<String> failures,
  }) {
    return ChildBatchResult._(
      success: true, // Partial success
      message: message,
      children: children,
      failures: failures,
      partial: true,
    );
  }
}
