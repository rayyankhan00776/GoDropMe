import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:godropme/features/parentSide/parentProfile/models/parent_profile.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/auth_service.dart';
import 'package:godropme/services/appwrite/database_constants.dart';
import 'package:godropme/services/appwrite/storage_service.dart';

/// Parent Service for GoDropMe
/// 
/// Handles parent profile CRUD operations:
/// - Create parent profile during registration
/// - Get parent profile for dashboard
/// - Update profile information (synced with Account & Users table)
/// - Upload/update profile photo
/// - Delete account (blocks Account + deletes data)
class ParentService {
  static ParentService? _instance;
  static ParentService get instance => _instance ??= ParentService._();
  
  /// Use TablesDB instead of deprecated Databases
  final TablesDB _tablesDB = AppwriteClient.tablesDBService();
  final Account _account = AppwriteClient.accountService();
  final StorageService _storage = StorageService.instance;
  
  ParentService._();
  
  // ═══════════════════════════════════════════════════════════════════════════
  // CREATE
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Create a new parent profile during registration
  /// 
  /// ```dart
  /// final result = await ParentService.instance.createParent(
  ///   profile: ParentProfile(fullName: 'John', phone: phone, email: email),
  ///   profilePhoto: imageFile, // optional
  /// );
  /// if (result.success) {
  ///   print('Parent created: ${result.parent!.id}');
  /// }
  /// ```
  Future<ParentResult> createParent({
    required ParentProfile profile,
    File? profilePhoto,
  }) async {
    try {
      // Get current auth user
      final authUser = AuthService.instance.currentUser;
      if (authUser == null) {
        return ParentResult.failure('Not authenticated. Please login again.');
      }
      
      String? photoUrl;
      
      // Upload profile photo if provided
      if (profilePhoto != null) {
        final uploadResult = await _storage.uploadImage(
          bucketId: Buckets.profilePhotos,
          imageFile: profilePhoto,
          fileName: 'parent_${authUser.$id}.jpg',
        );
        
        if (uploadResult.success) {
          // Build the file URL for storage
          photoUrl = Buckets.getFileUrl(Buckets.profilePhotos, uploadResult.fileId!);
          debugPrint('📷 Profile photo uploaded: ${uploadResult.fileId}');
        } else {
          debugPrint('⚠️ Photo upload failed: ${uploadResult.message}');
          // Continue without photo - not a critical error
        }
      }
      
      // Prepare document data
      final data = <String, dynamic>{
        'userId': authUser.$id,
        'fullName': profile.fullName,
        'email': profile.email ?? authUser.email,
      };
      
      // Only add optional fields if they have valid values
      // URL fields must be valid URLs or omitted entirely
      if (profile.phone != null && profile.phone!.e164.isNotEmpty) {
        data['phone'] = profile.phone!.e164;
      }
      
      if (photoUrl != null && photoUrl.isNotEmpty) {
        data['profilePhotoUrl'] = photoUrl;
      }
      
      // Create parent document using TablesDB
      final doc = await _tablesDB.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.parents,
        rowId: ID.unique(),
        data: data,
      );
      
      debugPrint('✅ Parent profile created: ${doc.$id}');
      
      // Return created profile
      return ParentResult.success(
        message: 'Profile created successfully',
        parent: ParentProfile.fromJson(doc.data),
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Create parent error: ${e.message}');
      return ParentResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Create parent error: $e');
      return ParentResult.failure('Failed to create profile. Please try again.');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // READ
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Get parent profile by user ID
  /// 
  /// ```dart
  /// final result = await ParentService.instance.getParent();
  /// if (result.success && result.parent != null) {
  ///   print('Hello, ${result.parent!.fullName}');
  /// }
  /// ```
  Future<ParentResult> getParent({String? userId}) async {
    try {
      // Use provided userId or current auth user
      final targetUserId = userId ?? AuthService.instance.currentUser?.$id;
      if (targetUserId == null) {
        return ParentResult.failure('Not authenticated. Please login again.');
      }
      
      // Query parents table by userId using TablesDB
      final result = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.parents,
        queries: [
          Query.equal('userId', targetUserId),
          Query.limit(1),
        ],
      );
      
      if (result.rows.isEmpty) {
        debugPrint('⚠️ No parent profile found for user: $targetUserId');
        return ParentResult.notFound();
      }
      
      final doc = result.rows.first;
      debugPrint('✅ Parent profile found: ${doc.$id}');
      
      return ParentResult.success(
        message: 'Profile loaded successfully',
        parent: ParentProfile.fromJson(doc.data),
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get parent error: ${e.message}');
      return ParentResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Get parent error: $e');
      return ParentResult.failure('Failed to load profile. Please try again.');
    }
  }
  
  /// Get parent profile by parent document ID
  Future<ParentResult> getParentById(String parentId) async {
    try {
      final doc = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.parents,
        rowId: parentId,
      );
      
      debugPrint('✅ Parent profile loaded: ${doc.$id}');
      
      return ParentResult.success(
        message: 'Profile loaded successfully',
        parent: ParentProfile.fromJson(doc.data),
      );
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        return ParentResult.notFound();
      }
      debugPrint('❌ Get parent by ID error: ${e.message}');
      return ParentResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Get parent by ID error: $e');
      return ParentResult.failure('Failed to load profile. Please try again.');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // UPDATE
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Update parent profile
  /// 
  /// Updates data in 3 places:
  /// 1. Account (name only - email requires password)
  /// 2. Users table
  /// 3. Parents table
  /// 
  /// ```dart
  /// final result = await ParentService.instance.updateParent(
  ///   parentId: 'abc123',
  ///   fullName: 'John Updated',
  ///   phone: newPhone,
  /// );
  /// ```
  Future<ParentResult> updateParent({
    required String parentId,
    String? fullName,
    String? phone,
    String? email,
  }) async {
    try {
      final authUserId = AuthService.instance.currentUser?.$id;
      if (authUserId == null) {
        return ParentResult.failure('Not authenticated. Please login again.');
      }
      
      // 1. Update Account name if provided
      if (fullName != null) {
        try {
          await _account.updateName(name: fullName);
          debugPrint('✅ Account name updated');
        } catch (e) {
          debugPrint('⚠️ Could not update account name: $e');
          // Continue - not critical
        }
      }
      
      // 2. Update Users table (only email if needed)
      // Note: phone is NOT stored in users table, only in parents table
      if (email != null) {
        try {
          await _tablesDB.updateRow(
            databaseId: AppwriteConfig.databaseId,
            tableId: Collections.users,
            rowId: authUserId, // Users table uses authUserId as document ID
            data: {'email': email},
          );
          debugPrint('✅ Users table updated');
        } catch (e) {
          debugPrint('⚠️ Could not update users table: $e');
          // Continue - not critical
        }
      }
      
      // 3. Update Parents table
      final parentData = <String, dynamic>{};
      if (fullName != null) parentData['fullName'] = fullName;
      if (phone != null) parentData['phone'] = phone;
      if (email != null) parentData['email'] = email;
      
      final doc = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.parents,
        rowId: parentId,
        data: parentData,
      );
      
      debugPrint('✅ Parent profile updated: ${doc.$id}');
      
      return ParentResult.success(
        message: 'Profile updated successfully',
        parent: ParentProfile.fromJson(doc.data),
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Update parent error: ${e.message}');
      return ParentResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Update parent error: $e');
      return ParentResult.failure('Failed to update profile. Please try again.');
    }
  }
  
  /// Update profile photo
  /// 
  /// Uploads new photo and updates parent document.
  /// Deletes old photo if exists.
  Future<ParentResult> updateProfilePhoto({
    required String parentId,
    required File photo,
    String? oldPhotoUrl,
  }) async {
    try {
      // Delete old photo if exists
      final oldFileId = _extractFileIdFromUrl(oldPhotoUrl);
      if (oldFileId != null) {
        await _storage.deleteFile(
          bucketId: Buckets.profilePhotos,
          fileId: oldFileId,
        );
        debugPrint('🗑️ Old photo deleted: $oldFileId');
      }
      
      // Get user ID for filename
      final userId = AuthService.instance.currentUser?.$id ?? 'unknown';
      
      // Upload new photo
      final uploadResult = await _storage.uploadImage(
        bucketId: Buckets.profilePhotos,
        imageFile: photo,
        fileName: 'parent_$userId.jpg',
      );
      
      if (!uploadResult.success) {
        return ParentResult.failure(uploadResult.message);
      }
      
      debugPrint('📷 New photo uploaded: ${uploadResult.fileId}');
      
      // Build the file URL for storage
      final photoUrl = Buckets.getFileUrl(Buckets.profilePhotos, uploadResult.fileId!);
      
      // Update parent row with new photo URL using TablesDB
      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.parents,
        rowId: parentId,
        data: {
          'profilePhotoUrl': photoUrl,
        },
      );
      
      debugPrint('✅ Parent photo updated: ${row.$id}');
      
      return ParentResult.success(
        message: 'Photo updated successfully',
        parent: ParentProfile.fromJson(row.data),
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Update photo error: ${e.message}');
      return ParentResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Update photo error: $e');
      return ParentResult.failure('Failed to update photo. Please try again.');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // DELETE
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Delete parent profile (with associated photo)
  /// 
  /// Note: This should cascade delete children as well in a real app
  Future<ParentResult> deleteParent({
    required String parentId,
    String? profilePhotoUrl,
  }) async {
    try {
      // Delete profile photo if exists
      final photoFileId = _extractFileIdFromUrl(profilePhotoUrl);
      if (photoFileId != null) {
        await _storage.deleteFile(
          bucketId: Buckets.profilePhotos,
          fileId: photoFileId,
        );
        debugPrint('🗑️ Profile photo deleted: $photoFileId');
      }
      
      // Delete parent row using TablesDB
      await _tablesDB.deleteRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.parents,
        rowId: parentId,
      );
      
      debugPrint('✅ Parent profile deleted: $parentId');
      
      return ParentResult.success(message: 'Profile deleted successfully');
    } on AppwriteException catch (e) {
      debugPrint('❌ Delete parent error: ${e.message}');
      return ParentResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Delete parent error: $e');
      return ParentResult.failure('Failed to delete profile. Please try again.');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Get profile photo URL
  String? getProfilePhotoUrl(String? fileId, {int? size}) {
    if (fileId == null || fileId.isEmpty) return null;
    
    if (size != null) {
      return Buckets.getPreviewUrl(
        Buckets.profilePhotos,
        fileId,
        width: size,
        height: size,
      );
    }
    
    return Buckets.getFileUrl(Buckets.profilePhotos, fileId);
  }
  
  /// Extract file ID from a full Appwrite storage URL
  /// URL format: https://fra.cloud.appwrite.io/v1/storage/buckets/{bucket}/files/{fileId}/view?project=...
  String? _extractFileIdFromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    
    try {
      // Pattern: /files/{fileId}/view
      final regex = RegExp(r'/files/([^/]+)/view');
      final match = regex.firstMatch(url);
      return match?.group(1);
    } catch (e) {
      debugPrint('⚠️ Failed to extract file ID from URL: $url');
      return null;
    }
  }
  
  String _parseError(AppwriteException e) {
    switch (e.code) {
      case 401:
        return 'Session expired. Please login again.';
      case 404:
        return 'Profile not found.';
      case 409:
        return 'A profile already exists for this account.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return e.message ?? 'Operation failed.';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RESULT CLASS
// ═══════════════════════════════════════════════════════════════════════════

/// Result of a parent service operation
class ParentResult {
  final bool success;
  final String message;
  final ParentProfile? parent;
  final bool notFound;
  
  const ParentResult._({
    required this.success,
    required this.message,
    this.parent,
    this.notFound = false,
  });
  
  factory ParentResult.success({
    required String message,
    ParentProfile? parent,
  }) {
    return ParentResult._(
      success: true,
      message: message,
      parent: parent,
    );
  }
  
  factory ParentResult.failure(String message) {
    return ParentResult._(
      success: false,
      message: message,
    );
  }
  
  factory ParentResult.notFound() {
    return const ParentResult._(
      success: false,
      message: 'Profile not found',
      notFound: true,
    );
  }
  
  @override
  String toString() => 'ParentResult(success: $success, parent: ${parent?.id}, message: $message)';
}
