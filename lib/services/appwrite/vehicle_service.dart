import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:godropme/features/DriverSide/driverRegistration/models/vehicle_registration.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/database_constants.dart';
import 'package:godropme/services/appwrite/storage_service.dart';

/// Vehicle Service for GoDropMe
/// 
/// Handles vehicle CRUD operations:
/// - Create vehicle for a driver
/// - Get vehicle by driverId
/// - Update vehicle information
/// - Upload vehicle photos (vehicle, registration front/back)
class VehicleService {
  static VehicleService? _instance;
  static VehicleService get instance => _instance ??= VehicleService._();
  
  final TablesDB _tablesDB = AppwriteClient.tablesDBService();
  final StorageService _storage = StorageService.instance;
  
  VehicleService._();
  
  // ═══════════════════════════════════════════════════════════════════════════
  // CREATE
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Create a new vehicle for a driver
  /// 
  /// ```dart
  /// final result = await VehicleService.instance.createVehicle(
  ///   driverId: 'driver123',
  ///   vehicle: VehicleRegistration(...),
  ///   vehiclePhoto: photoFile,
  ///   registrationFront: frontFile,
  ///   registrationBack: backFile,
  /// );
  /// if (result.success) {
  ///   print('Vehicle created: ${result.vehicleId}');
  /// }
  /// ```
  Future<VehicleResult> createVehicle({
    required String driverId,
    required VehicleRegistration vehicle,
    File? vehiclePhoto,
    File? registrationFront,
    File? registrationBack,
  }) async {
    try {
      String? vehiclePhotoUrl;
      String? registrationFrontUrl;
      String? registrationBackUrl;
      
      // Upload vehicle photo
      if (vehiclePhoto != null) {
        final uploadResult = await _storage.uploadImage(
          bucketId: Buckets.vehiclePhotos,
          imageFile: vehiclePhoto,
          fileName: 'vehicle_${driverId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        
        if (uploadResult.success) {
          vehiclePhotoUrl = Buckets.getFileUrl(Buckets.vehiclePhotos, uploadResult.fileId!);
          debugPrint('📷 Vehicle photo uploaded: ${uploadResult.fileId}');
        }
      }
      
      // Upload registration front
      if (registrationFront != null) {
        final uploadResult = await _storage.uploadImage(
          bucketId: Buckets.documents,
          imageFile: registrationFront,
          fileName: 'reg_front_${driverId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        
        if (uploadResult.success) {
          registrationFrontUrl = Buckets.getFileUrl(Buckets.documents, uploadResult.fileId!);
          debugPrint('📷 Registration front uploaded: ${uploadResult.fileId}');
        }
      }
      
      // Upload registration back
      if (registrationBack != null) {
        final uploadResult = await _storage.uploadImage(
          bucketId: Buckets.documents,
          imageFile: registrationBack,
          fileName: 'reg_back_${driverId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        
        if (uploadResult.success) {
          registrationBackUrl = Buckets.getFileUrl(Buckets.documents, uploadResult.fileId!);
          debugPrint('📷 Registration back uploaded: ${uploadResult.fileId}');
        }
      }
      
      // Get auth user ID for permissions
      final authUserId = await _getAuthUserId(driverId);
      
      // Create vehicle row
      final vehicleRow = await _tablesDB.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.vehicles,
        rowId: ID.unique(),
        data: {
          'driverId': driverId,
          'vehicleType': vehicle.vehicleType.name,
          'brand': vehicle.brand,
          'model': vehicle.model,
          'color': vehicle.color,
          'productionYear': vehicle.productionYear,
          'numberPlate': vehicle.numberPlate,
          'seatCapacity': vehicle.seatCapacity,
          if (vehiclePhotoUrl != null) 'vehiclePhotoUrl': vehiclePhotoUrl,
          if (registrationFrontUrl != null) 'registrationFrontUrl': registrationFrontUrl,
          if (registrationBackUrl != null) 'registrationBackUrl': registrationBackUrl,
          'isActive': true,
        },
        permissions: authUserId != null
            ? [
                Permission.read(Role.user(authUserId)),
                Permission.update(Role.user(authUserId)),
                Permission.delete(Role.user(authUserId)),
              ]
            : null,
      );
      
      debugPrint('✅ Vehicle created: ${vehicleRow.$id}');
      
      return VehicleResult.success(
        message: 'Vehicle registered successfully',
        vehicleId: vehicleRow.$id,
        vehicle: vehicleRow.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Create vehicle error: ${e.message}');
      return VehicleResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Create vehicle error: $e');
      return VehicleResult.failure('Failed to register vehicle. Please try again.');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // READ
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Get vehicle by driver ID
  Future<VehicleResult> getVehicleByDriverId(String driverId) async {
    try {
      final response = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.vehicles,
        queries: [
          Query.equal('driverId', driverId),
          Query.limit(1),
        ],
      );
      
      if (response.rows.isEmpty) {
        debugPrint('ℹ️ No vehicle found for driver: $driverId');
        return VehicleResult.notFound();
      }
      
      final vehicleRow = response.rows.first;
      debugPrint('✅ Vehicle loaded: ${vehicleRow.$id}');
      
      return VehicleResult.success(
        message: 'Vehicle loaded',
        vehicleId: vehicleRow.$id,
        vehicle: vehicleRow.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get vehicle error: ${e.message}');
      return VehicleResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Get vehicle error: $e');
      return VehicleResult.failure('Failed to load vehicle.');
    }
  }
  
  /// Get vehicle by vehicle document ID
  Future<VehicleResult> getVehicleById(String vehicleId) async {
    try {
      final row = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.vehicles,
        rowId: vehicleId,
      );
      
      debugPrint('✅ Vehicle loaded by ID: $vehicleId');
      
      return VehicleResult.success(
        message: 'Vehicle loaded',
        vehicleId: row.$id,
        vehicle: row.data,
      );
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        return VehicleResult.notFound();
      }
      debugPrint('❌ Get vehicle by ID error: ${e.message}');
      return VehicleResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Get vehicle by ID error: $e');
      return VehicleResult.failure('Failed to load vehicle.');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // UPDATE
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Update vehicle information
  Future<VehicleResult> updateVehicle({
    required String vehicleId,
    required VehicleRegistration vehicle,
    File? vehiclePhoto,
    File? registrationFront,
    File? registrationBack,
    String? existingVehiclePhotoUrl,
    String? existingRegistrationFrontUrl,
    String? existingRegistrationBackUrl,
  }) async {
    try {
      String? vehiclePhotoUrl = existingVehiclePhotoUrl;
      String? registrationFrontUrl = existingRegistrationFrontUrl;
      String? registrationBackUrl = existingRegistrationBackUrl;
      
      // Upload new vehicle photo if provided
      if (vehiclePhoto != null) {
        if (existingVehiclePhotoUrl != null) {
          final oldFileId = _extractFileIdFromUrl(existingVehiclePhotoUrl);
          if (oldFileId != null) {
            await _storage.deleteFile(bucketId: Buckets.vehiclePhotos, fileId: oldFileId);
          }
        }
        
        final uploadResult = await _storage.uploadImage(
          bucketId: Buckets.vehiclePhotos,
          imageFile: vehiclePhoto,
          fileName: 'vehicle_${vehicleId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        
        if (uploadResult.success) {
          vehiclePhotoUrl = Buckets.getFileUrl(Buckets.vehiclePhotos, uploadResult.fileId!);
        }
      }
      
      // Upload new registration front if provided
      if (registrationFront != null) {
        if (existingRegistrationFrontUrl != null) {
          final oldFileId = _extractFileIdFromUrl(existingRegistrationFrontUrl);
          if (oldFileId != null) {
            await _storage.deleteFile(bucketId: Buckets.documents, fileId: oldFileId);
          }
        }
        
        final uploadResult = await _storage.uploadImage(
          bucketId: Buckets.documents,
          imageFile: registrationFront,
          fileName: 'reg_front_${vehicleId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        
        if (uploadResult.success) {
          registrationFrontUrl = Buckets.getFileUrl(Buckets.documents, uploadResult.fileId!);
        }
      }
      
      // Upload new registration back if provided
      if (registrationBack != null) {
        if (existingRegistrationBackUrl != null) {
          final oldFileId = _extractFileIdFromUrl(existingRegistrationBackUrl);
          if (oldFileId != null) {
            await _storage.deleteFile(bucketId: Buckets.documents, fileId: oldFileId);
          }
        }
        
        final uploadResult = await _storage.uploadImage(
          bucketId: Buckets.documents,
          imageFile: registrationBack,
          fileName: 'reg_back_${vehicleId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        
        if (uploadResult.success) {
          registrationBackUrl = Buckets.getFileUrl(Buckets.documents, uploadResult.fileId!);
        }
      }
      
      // Update vehicle row
      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.vehicles,
        rowId: vehicleId,
        data: {
          'vehicleType': vehicle.vehicleType.name,
          'brand': vehicle.brand,
          'model': vehicle.model,
          'color': vehicle.color,
          'productionYear': vehicle.productionYear,
          'numberPlate': vehicle.numberPlate,
          'seatCapacity': vehicle.seatCapacity,
          if (vehiclePhotoUrl != null) 'vehiclePhotoUrl': vehiclePhotoUrl,
          if (registrationFrontUrl != null) 'registrationFrontUrl': registrationFrontUrl,
          if (registrationBackUrl != null) 'registrationBackUrl': registrationBackUrl,
          'isActive': vehicle.isActive,
        },
      );
      
      debugPrint('✅ Vehicle updated: $vehicleId');
      
      return VehicleResult.success(
        message: 'Vehicle updated',
        vehicleId: row.$id,
        vehicle: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Update vehicle error: ${e.message}');
      return VehicleResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Update vehicle error: $e');
      return VehicleResult.failure('Failed to update vehicle.');
    }
  }
  
  /// Set vehicle active/inactive status
  Future<VehicleResult> setActiveStatus({
    required String vehicleId,
    required bool isActive,
  }) async {
    try {
      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.vehicles,
        rowId: vehicleId,
        data: {'isActive': isActive},
      );
      
      debugPrint('✅ Vehicle active status set to: $isActive');
      
      return VehicleResult.success(
        message: isActive ? 'Vehicle activated' : 'Vehicle deactivated',
        vehicleId: row.$id,
        vehicle: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Set active status error: ${e.message}');
      return VehicleResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Set active status error: $e');
      return VehicleResult.failure('Failed to update vehicle status.');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // DELETE
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Delete vehicle and all associated photos
  Future<VehicleResult> deleteVehicle({
    required String vehicleId,
    Map<String, dynamic>? vehicleData,
  }) async {
    try {
      // Get vehicle data if not provided
      final vehicle = vehicleData ?? (await getVehicleById(vehicleId)).vehicle;
      
      // Delete photos from storage
      if (vehicle != null) {
        final photosToDelete = [
          (vehicle['vehiclePhotoUrl'], Buckets.vehiclePhotos),
          (vehicle['registrationFrontUrl'], Buckets.documents),
          (vehicle['registrationBackUrl'], Buckets.documents),
        ];
        
        for (final (url, bucket) in photosToDelete) {
          if (url != null) {
            final fileId = _extractFileIdFromUrl(url.toString());
            if (fileId != null) {
              try {
                await _storage.deleteFile(bucketId: bucket, fileId: fileId);
              } catch (e) {
                debugPrint('⚠️ Could not delete photo: $e');
              }
            }
          }
        }
      }
      
      // Delete vehicle row
      await _tablesDB.deleteRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.vehicles,
        rowId: vehicleId,
      );
      
      debugPrint('✅ Vehicle deleted: $vehicleId');
      
      return VehicleResult.success(message: 'Vehicle deleted');
    } on AppwriteException catch (e) {
      debugPrint('❌ Delete vehicle error: ${e.message}');
      return VehicleResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Delete vehicle error: $e');
      return VehicleResult.failure('Failed to delete vehicle.');
    }
  }
  
  /// Delete all vehicles for a driver
  Future<VehicleResult> deleteAllVehicles(String driverId) async {
    try {
      final response = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.vehicles,
        queries: [Query.equal('driverId', driverId)],
      );
      
      for (final row in response.rows) {
        await deleteVehicle(vehicleId: row.$id, vehicleData: row.data);
      }
      
      debugPrint('✅ All vehicles deleted for driver: $driverId');
      
      return VehicleResult.success(
        message: 'All vehicles deleted',
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Delete all vehicles error: ${e.message}');
      return VehicleResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Delete all vehicles error: $e');
      return VehicleResult.failure('Failed to delete vehicles.');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Get auth user ID from driver ID (for permissions)
  Future<String?> _getAuthUserId(String driverId) async {
    try {
      final row = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.drivers,
        rowId: driverId,
      );
      return row.data['userId']?.toString();
    } catch (e) {
      debugPrint('⚠️ Could not get auth user ID: $e');
      return null;
    }
  }
  
  /// Extract file ID from a full Appwrite storage URL
  String? _extractFileIdFromUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      final filesIdx = segments.indexOf('files');
      if (filesIdx != -1 && filesIdx + 1 < segments.length) {
        return segments[filesIdx + 1];
      }
    } catch (e) {
      debugPrint('⚠️ Could not extract file ID from URL: $url');
    }
    return null;
  }
  
  String _parseError(AppwriteException e) {
    switch (e.code) {
      case 401:
        return 'Session expired. Please login again.';
      case 404:
        return 'Vehicle not found.';
      case 409:
        return 'A vehicle with this number plate already exists.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RESULT CLASS
// ═══════════════════════════════════════════════════════════════════════════

/// Result of a vehicle service operation
class VehicleResult {
  final bool success;
  final String message;
  final String? vehicleId;
  final Map<String, dynamic>? vehicle;
  final bool notFound;
  
  const VehicleResult._({
    required this.success,
    required this.message,
    this.vehicleId,
    this.vehicle,
    this.notFound = false,
  });
  
  factory VehicleResult.success({
    required String message,
    String? vehicleId,
    Map<String, dynamic>? vehicle,
  }) {
    return VehicleResult._(
      success: true,
      message: message,
      vehicleId: vehicleId,
      vehicle: vehicle,
    );
  }
  
  factory VehicleResult.failure(String message) {
    return VehicleResult._(
      success: false,
      message: message,
    );
  }
  
  factory VehicleResult.notFound() {
    return const VehicleResult._(
      success: false,
      message: 'Vehicle not found',
      notFound: true,
    );
  }
  
  @override
  String toString() => 'VehicleResult(success: $success, message: $message, vehicleId: $vehicleId)';
}
