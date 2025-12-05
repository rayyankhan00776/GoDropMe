import 'dart:io';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/database_constants.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Storage Service for GoDropMe
/// 
/// Handles file uploads, downloads, and image compression for:
/// - Profile photos (parents & drivers)
/// - Child photos
/// - Vehicle photos
/// - Documents (CNIC, License, Registration)
/// - Chat attachments
/// - Report attachments
class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  
  final Storage _storage = AppwriteClient.storageService();
  
  StorageService._();
  
  // ═══════════════════════════════════════════════════════════════════════════
  // FILE UPLOAD
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Upload a file to a storage bucket
  /// 
  /// Returns the file ID on success, null on failure.
  /// 
  /// ```dart
  /// final fileId = await StorageService.instance.uploadFile(
  ///   bucketId: Buckets.profilePhotos,
  ///   file: imageFile,
  ///   fileName: 'profile_123.jpg',
  /// );
  /// ```
  Future<StorageResult> uploadFile({
    required String bucketId,
    required File file,
    String? fileName,
    List<String>? permissions,
  }) async {
    try {
      final name = fileName ?? path.basename(file.path);
      
      final result = await _storage.createFile(
        bucketId: bucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: file.path, filename: name),
        permissions: permissions,
      );
      
      debugPrint('✅ File uploaded: ${result.$id} to $bucketId');
      
      return StorageResult.success(
        message: 'File uploaded successfully',
        fileId: result.$id,
        fileName: result.name,
        mimeType: result.mimeType,
        sizeBytes: result.sizeOriginal,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Upload error: ${e.message}');
      return StorageResult.failure(_parseStorageError(e));
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      return StorageResult.failure('Failed to upload file. Please try again.');
    }
  }
  
  /// Upload image with automatic compression
  /// 
  /// Compresses images to max 1MB before upload for optimal storage.
  /// 
  /// ```dart
  /// final fileId = await StorageService.instance.uploadImage(
  ///   bucketId: Buckets.profilePhotos,
  ///   imageFile: photo,
  ///   quality: 85,
  /// );
  /// ```
  Future<StorageResult> uploadImage({
    required String bucketId,
    required File imageFile,
    String? fileName,
    int quality = 85,
    int maxWidth = 1080,
    int maxHeight = 1080,
    List<String>? permissions,
  }) async {
    try {
      // Compress image first
      final compressed = await compressImage(
        imageFile,
        quality: quality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      
      if (compressed == null) {
        return StorageResult.failure('Failed to compress image');
      }
      
      // Upload compressed image
      return uploadFile(
        bucketId: bucketId,
        file: compressed,
        fileName: fileName,
        permissions: permissions,
      );
    } catch (e) {
      debugPrint('❌ Image upload error: $e');
      return StorageResult.failure('Failed to upload image. Please try again.');
    }
  }
  
  /// Upload from bytes (useful for web or memory images)
  Future<StorageResult> uploadBytes({
    required String bucketId,
    required Uint8List bytes,
    required String fileName,
    List<String>? permissions,
  }) async {
    try {
      final result = await _storage.createFile(
        bucketId: bucketId,
        fileId: ID.unique(),
        file: InputFile.fromBytes(bytes: bytes, filename: fileName),
        permissions: permissions,
      );
      
      debugPrint('✅ Bytes uploaded: ${result.$id} to $bucketId');
      
      return StorageResult.success(
        message: 'File uploaded successfully',
        fileId: result.$id,
        fileName: result.name,
        mimeType: result.mimeType,
        sizeBytes: result.sizeOriginal,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Upload bytes error: ${e.message}');
      return StorageResult.failure(_parseStorageError(e));
    } catch (e) {
      debugPrint('❌ Upload bytes error: $e');
      return StorageResult.failure('Failed to upload file. Please try again.');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // FILE DOWNLOAD & PREVIEW
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Get file for download (returns bytes)
  Future<Uint8List?> downloadFile({
    required String bucketId,
    required String fileId,
  }) async {
    try {
      final bytes = await _storage.getFileDownload(
        bucketId: bucketId,
        fileId: fileId,
      );
      
      debugPrint('✅ File downloaded: $fileId');
      return bytes;
    } on AppwriteException catch (e) {
      debugPrint('❌ Download error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('❌ Download error: $e');
      return null;
    }
  }
  
  /// Get image preview (smaller, optimized version)
  Future<Uint8List?> getImagePreview({
    required String bucketId,
    required String fileId,
    int? width,
    int? height,
    int? quality,
  }) async {
    try {
      final bytes = await _storage.getFilePreview(
        bucketId: bucketId,
        fileId: fileId,
        width: width,
        height: height,
        quality: quality ?? 80,
      );
      
      return bytes;
    } on AppwriteException catch (e) {
      debugPrint('❌ Preview error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('❌ Preview error: $e');
      return null;
    }
  }
  
  /// Get file view URL (for direct access in Image.network)
  String getFileViewUrl({
    required String bucketId,
    required String fileId,
  }) {
    return Buckets.getFileUrl(bucketId, fileId);
  }
  
  /// Get image preview URL with dimensions
  String getPreviewUrl({
    required String bucketId,
    required String fileId,
    int? width,
    int? height,
  }) {
    return Buckets.getPreviewUrl(bucketId, fileId, width: width, height: height);
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // FILE MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Get file metadata
  Future<FileInfo?> getFileInfo({
    required String bucketId,
    required String fileId,
  }) async {
    try {
      final file = await _storage.getFile(
        bucketId: bucketId,
        fileId: fileId,
      );
      
      return FileInfo(
        id: file.$id,
        name: file.name,
        mimeType: file.mimeType,
        sizeBytes: file.sizeOriginal,
        bucketId: file.bucketId,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get file info error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('❌ Get file info error: $e');
      return null;
    }
  }
  
  /// Delete a file from storage
  Future<StorageResult> deleteFile({
    required String bucketId,
    required String fileId,
  }) async {
    try {
      await _storage.deleteFile(
        bucketId: bucketId,
        fileId: fileId,
      );
      
      debugPrint('✅ File deleted: $fileId from $bucketId');
      
      return StorageResult.success(
        message: 'File deleted successfully',
        fileId: fileId,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Delete error: ${e.message}');
      return StorageResult.failure(_parseStorageError(e));
    } catch (e) {
      debugPrint('❌ Delete error: $e');
      return StorageResult.failure('Failed to delete file. Please try again.');
    }
  }
  
  /// Replace a file (delete old, upload new)
  Future<StorageResult> replaceFile({
    required String bucketId,
    required String oldFileId,
    required File newFile,
    String? fileName,
  }) async {
    // Delete old file (ignore errors - might not exist)
    await deleteFile(bucketId: bucketId, fileId: oldFileId);
    
    // Upload new file
    return uploadFile(
      bucketId: bucketId,
      file: newFile,
      fileName: fileName,
    );
  }
  
  /// Replace an image (with compression)
  Future<StorageResult> replaceImage({
    required String bucketId,
    required String oldFileId,
    required File newImage,
    String? fileName,
    int quality = 85,
  }) async {
    // Delete old file (ignore errors - might not exist)
    await deleteFile(bucketId: bucketId, fileId: oldFileId);
    
    // Upload new compressed image
    return uploadImage(
      bucketId: bucketId,
      imageFile: newImage,
      fileName: fileName,
      quality: quality,
    );
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // IMAGE COMPRESSION
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Compress an image file
  /// 
  /// Returns compressed file or null on failure.
  /// Target size is approximately 500KB-1MB depending on quality.
  Future<File?> compressImage(
    File file, {
    int quality = 85,
    int maxWidth = 1080,
    int maxHeight = 1080,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
      );
      
      if (result == null) {
        debugPrint('⚠️ Compression returned null, using original');
        return file;
      }
      
      final originalSize = await file.length();
      final compressedSize = await result.length();
      final savings = ((1 - compressedSize / originalSize) * 100).round();
      
      debugPrint('🗜️ Image compressed: ${_formatBytes(originalSize)} → ${_formatBytes(compressedSize)} ($savings% saved)');
      
      return File(result.path);
    } catch (e) {
      debugPrint('⚠️ Compression failed: $e, using original');
      return file;
    }
  }
  
  /// Compress image bytes
  Future<Uint8List?> compressImageBytes(
    Uint8List bytes, {
    int quality = 85,
    int maxWidth = 1080,
    int maxHeight = 1080,
  }) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        bytes,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
      );
      
      final savings = ((1 - result.length / bytes.length) * 100).round();
      debugPrint('🗜️ Bytes compressed: ${_formatBytes(bytes.length)} → ${_formatBytes(result.length)} ($savings% saved)');
      
      return result;
    } catch (e) {
      debugPrint('⚠️ Bytes compression failed: $e');
      return bytes;
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════
  
  String _parseStorageError(AppwriteException e) {
    switch (e.code) {
      case 404:
        return 'File not found.';
      case 413:
        return 'File too large. Please choose a smaller file.';
      case 415:
        return 'File type not allowed.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return e.message ?? 'Storage operation failed.';
    }
  }
  
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RESULT CLASSES
// ═══════════════════════════════════════════════════════════════════════════

/// Result of a storage operation
class StorageResult {
  final bool success;
  final String message;
  final String? fileId;
  final String? fileName;
  final String? mimeType;
  final int? sizeBytes;
  
  const StorageResult._({
    required this.success,
    required this.message,
    this.fileId,
    this.fileName,
    this.mimeType,
    this.sizeBytes,
  });
  
  factory StorageResult.success({
    required String message,
    String? fileId,
    String? fileName,
    String? mimeType,
    int? sizeBytes,
  }) {
    return StorageResult._(
      success: true,
      message: message,
      fileId: fileId,
      fileName: fileName,
      mimeType: mimeType,
      sizeBytes: sizeBytes,
    );
  }
  
  factory StorageResult.failure(String message) {
    return StorageResult._(
      success: false,
      message: message,
    );
  }
  
  @override
  String toString() => 'StorageResult(success: $success, fileId: $fileId, message: $message)';
}

/// File metadata info
class FileInfo {
  final String id;
  final String name;
  final String mimeType;
  final int sizeBytes;
  final String bucketId;
  
  const FileInfo({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.sizeBytes,
    required this.bucketId,
  });
  
  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
