import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:godropme/features/DriverSide/driverRegistration/models/driver_identification.dart';
import 'package:godropme/features/DriverSide/driverRegistration/models/driver_licence.dart';
import 'package:godropme/features/DriverSide/driverRegistration/models/personal_info.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/auth_service.dart';
import 'package:godropme/services/appwrite/database_constants.dart';
import 'package:godropme/services/appwrite/storage_service.dart';

/// Driver Service for GoDropMe
/// 
/// Handles driver profile CRUD operations:
/// - Create driver profile during registration
/// - Get driver profile by userId or driverId
/// - Update profile information
/// - Upload photos (profile, CNIC, license, selfie)
/// - Update verification status
/// - Set online/offline status
class DriverService {
  static DriverService? _instance;
  static DriverService get instance => _instance ??= DriverService._();
  
  final TablesDB _tablesDB = AppwriteClient.tablesDBService();
  final Account _account = AppwriteClient.accountService();
  final StorageService _storage = StorageService.instance;
  
  DriverService._();
  
  // ═══════════════════════════════════════════════════════════════════════════
  // CREATE
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Create a new driver profile during registration
  /// 
  /// This is called after basic auth registration. The driver profile
  /// is created with pending verification status.
  /// 
  /// ```dart
  /// final result = await DriverService.instance.createDriver(
  ///   personalInfo: PersonalInfo(...),
  ///   email: 'driver@email.com',
  ///   profilePhoto: imageFile, // optional at this stage
  /// );
  /// if (result.success) {
  ///   print('Driver created: ${result.driverId}');
  /// }
  /// ```
  @Deprecated('Use createDriverComplete instead - all fields are required by schema')
  Future<DriverResult> createDriver({
    required PersonalInfo personalInfo,
    required String email,
    File? profilePhoto,
  }) async {
    try {
      final authUser = AuthService.instance.currentUser;
      if (authUser == null) {
        return DriverResult.failure('Please login first');
      }
      
      final authUserId = authUser.$id;
      String? profilePhotoUrl;
      
      // Upload profile photo if provided
      if (profilePhoto != null) {
        final uploadResult = await _storage.uploadImage(
          bucketId: Buckets.profilePhotos,
          imageFile: profilePhoto,
          fileName: 'driver_profile_${authUserId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        
        if (uploadResult.success) {
          profilePhotoUrl = Buckets.getFileUrl(Buckets.profilePhotos, uploadResult.fileId!);
          debugPrint('📷 Driver profile photo uploaded: ${uploadResult.fileId}');
        }
      }
      
      // Create driver row
      final driverRow = await _tablesDB.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.drivers,
        rowId: ID.unique(),
        data: {
          'userId': authUserId,
          'fullName': personalInfo.fullName,
          'firstName': personalInfo.firstName,
          'surname': personalInfo.surName,
          'lastName': personalInfo.lastName,
          'phone': personalInfo.phone ?? '',
          'email': email,
          if (profilePhotoUrl != null) 'profilePhotoUrl': profilePhotoUrl,
          // Status is now managed in users table, not drivers table
          'rating': 0.0,
          'totalTrips': 0,
          'totalRatings': 0,
          'isOnline': false,
        },
        permissions: [
          Permission.read(Role.user(authUserId)),
          Permission.update(Role.user(authUserId)),
          Permission.delete(Role.user(authUserId)),
        ],
      );
      
      debugPrint('✅ Driver profile created: ${driverRow.$id}');
      
      return DriverResult.success(
        message: 'Driver profile created',
        driverId: driverRow.$id,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Create driver error: ${e.message}');
      return DriverResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Create driver error: $e');
      return DriverResult.failure('Failed to create driver profile. Please try again.');
    }
  }
  
  /// Create a complete driver profile with all required fields.
  /// 
  /// This method uploads all photos and creates the driver record in a single
  /// operation. All fields marked as required in the database schema must be
  /// provided.
  /// 
  /// Required photos: profilePhoto, cnicFront, cnicBack, licensePhoto, selfieWithLicense
  Future<DriverResult> createDriverComplete({
    required PersonalInfo personalInfo,
    required String email,
    required DriverIdentification identification,
    required DriverLicence licence,
    required File profilePhoto,
    required File cnicFront,
    required File cnicBack,
    required File licensePhoto,
    required File selfieWithLicense,
  }) async {
    try {
      final authUser = AuthService.instance.currentUser;
      if (authUser == null) {
        return DriverResult.failure('Please login first');
      }
      
      final authUserId = authUser.$id;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Upload all photos in parallel for efficiency
      debugPrint('📷 Uploading driver photos...');
      
      final uploadResults = await Future.wait([
        _storage.uploadImage(
          bucketId: Buckets.profilePhotos,
          imageFile: profilePhoto,
          fileName: 'driver_profile_${authUserId}_$timestamp.jpg',
        ),
        _storage.uploadImage(
          bucketId: Buckets.documents,
          imageFile: cnicFront,
          fileName: 'cnic_front_${authUserId}_$timestamp.jpg',
        ),
        _storage.uploadImage(
          bucketId: Buckets.documents,
          imageFile: cnicBack,
          fileName: 'cnic_back_${authUserId}_$timestamp.jpg',
        ),
        _storage.uploadImage(
          bucketId: Buckets.documents,
          imageFile: licensePhoto,
          fileName: 'license_${authUserId}_$timestamp.jpg',
        ),
        _storage.uploadImage(
          bucketId: Buckets.documents,
          imageFile: selfieWithLicense,
          fileName: 'selfie_license_${authUserId}_$timestamp.jpg',
        ),
      ]);
      
      // Check all uploads succeeded
      final profileResult = uploadResults[0];
      final cnicFrontResult = uploadResults[1];
      final cnicBackResult = uploadResults[2];
      final licenseResult = uploadResults[3];
      final selfieResult = uploadResults[4];
      
      if (!profileResult.success) {
        return DriverResult.failure('Failed to upload profile photo');
      }
      if (!cnicFrontResult.success) {
        return DriverResult.failure('Failed to upload CNIC front');
      }
      if (!cnicBackResult.success) {
        return DriverResult.failure('Failed to upload CNIC back');
      }
      if (!licenseResult.success) {
        return DriverResult.failure('Failed to upload license photo');
      }
      if (!selfieResult.success) {
        return DriverResult.failure('Failed to upload selfie');
      }
      
      // Build URLs
      final profilePhotoUrl = Buckets.getFileUrl(Buckets.profilePhotos, profileResult.fileId!);
      final cnicFrontUrl = Buckets.getFileUrl(Buckets.documents, cnicFrontResult.fileId!);
      final cnicBackUrl = Buckets.getFileUrl(Buckets.documents, cnicBackResult.fileId!);
      final licensePhotoUrl = Buckets.getFileUrl(Buckets.documents, licenseResult.fileId!);
      final selfieWithLicenseUrl = Buckets.getFileUrl(Buckets.documents, selfieResult.fileId!);
      
      debugPrint('✅ All photos uploaded successfully');
      
      // Create driver row with ALL required fields
      final driverRow = await _tablesDB.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.drivers,
        rowId: ID.unique(),
        data: {
          // Basic info
          'userId': authUserId,
          'fullName': personalInfo.fullName,
          'firstName': personalInfo.firstName,
          'surname': personalInfo.surName,
          'lastName': personalInfo.lastName,
          'phone': personalInfo.phone ?? '',
          'email': email,
          'profilePhotoUrl': profilePhotoUrl,
          
          // CNIC info
          'cnicNumber': identification.cnicNumber,
          if (identification.cnicExpiry != null && identification.cnicExpiry!.isNotEmpty)
            'cnicExpiry': _toIsoDate(identification.cnicExpiry!),
          'cnicFrontUrl': cnicFrontUrl,
          'cnicBackUrl': cnicBackUrl,
          
          // License info
          'licenseNumber': licence.licenceNumber,
          'licenseExpiry': _toIsoDate(licence.licenseExpiry),
          'licensePhotoUrl': licensePhotoUrl,
          'selfieWithLicenseUrl': selfieWithLicenseUrl,
          
          // Status fields (verificationStatus removed - using users.status instead)
          'rating': 0.0,
          'totalTrips': 0,
          'totalRatings': 0,
          'isOnline': false,
        },
        permissions: [
          Permission.read(Role.user(authUserId)),
          Permission.update(Role.user(authUserId)),
          Permission.delete(Role.user(authUserId)),
        ],
      );
      
      debugPrint('✅ Driver profile created: ${driverRow.$id}');
      
      return DriverResult.success(
        message: 'Driver profile created',
        driverId: driverRow.$id,
        driver: driverRow.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Create driver error: ${e.message}');
      return DriverResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Create driver error: $e');
      return DriverResult.failure('Failed to create driver profile. Please try again.');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // READ
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Get driver profile by user ID (from auth)
  /// 
  /// ```dart
  /// final result = await DriverService.instance.getDriver();
  /// if (result.success && result.driver != null) {
  ///   print('Hello, ${result.driver!['fullName']}');
  /// }
  /// ```
  Future<DriverResult> getDriver({String? userId}) async {
    try {
      final authUserId = userId ?? AuthService.instance.currentUser?.$id;
      if (authUserId == null) {
        return DriverResult.failure('Not logged in');
      }
      
      // Query drivers table by userId
      final response = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.drivers,
        queries: [
          Query.equal('userId', authUserId),
          Query.limit(1),
        ],
      );
      
      if (response.rows.isEmpty) {
        debugPrint('ℹ️ No driver profile found for user: $authUserId');
        return DriverResult.notFound();
      }
      
      final driverRow = response.rows.first;
      debugPrint('✅ Driver profile loaded: ${driverRow.$id}');
      
      return DriverResult.success(
        message: 'Driver profile loaded',
        driverId: driverRow.$id,
        driver: driverRow.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get driver error: ${e.message}');
      return DriverResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Get driver error: $e');
      return DriverResult.failure('Failed to load driver profile.');
    }
  }
  
  /// Get driver profile by driver document ID
  Future<DriverResult> getDriverById(String driverId) async {
    try {
      final row = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.drivers,
        rowId: driverId,
      );
      
      debugPrint('✅ Driver profile loaded by ID: $driverId');
      
      return DriverResult.success(
        message: 'Driver profile loaded',
        driverId: row.$id,
        driver: row.data,
      );
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        return DriverResult.notFound();
      }
      debugPrint('❌ Get driver by ID error: ${e.message}');
      return DriverResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Get driver by ID error: $e');
      return DriverResult.failure('Failed to load driver profile.');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // UPDATE
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Update driver profile with personal info
  Future<DriverResult> updatePersonalInfo({
    required String driverId,
    required PersonalInfo personalInfo,
    File? profilePhoto,
    String? existingPhotoUrl,
  }) async {
    try {
      String? profilePhotoUrl = existingPhotoUrl;
      
      // Upload new profile photo if provided
      if (profilePhoto != null) {
        // Delete old photo if exists
        if (existingPhotoUrl != null) {
          final oldFileId = _extractFileIdFromUrl(existingPhotoUrl);
          if (oldFileId != null) {
            await _storage.deleteFile(
              bucketId: Buckets.profilePhotos,
              fileId: oldFileId,
            );
          }
        }
        
        final uploadResult = await _storage.uploadImage(
          bucketId: Buckets.profilePhotos,
          imageFile: profilePhoto,
          fileName: 'driver_profile_${driverId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        
        if (uploadResult.success) {
          profilePhotoUrl = Buckets.getFileUrl(Buckets.profilePhotos, uploadResult.fileId!);
          debugPrint('📷 Profile photo updated: ${uploadResult.fileId}');
        }
      }
      
      // Update driver row
      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.drivers,
        rowId: driverId,
        data: {
          'fullName': personalInfo.fullName,
          'firstName': personalInfo.firstName,
          'surname': personalInfo.surName,
          'lastName': personalInfo.lastName,
          if (personalInfo.phone != null) 'phone': personalInfo.phone,
          if (profilePhotoUrl != null) 'profilePhotoUrl': profilePhotoUrl,
        },
      );
      
      // Also update Account display name
      try {
        await _account.updateName(name: personalInfo.fullName);
      } catch (e) {
        debugPrint('⚠️ Could not update account name: $e');
      }
      
      debugPrint('✅ Driver personal info updated: $driverId');
      
      return DriverResult.success(
        message: 'Personal info updated',
        driverId: row.$id,
        driver: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Update personal info error: ${e.message}');
      return DriverResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Update personal info error: $e');
      return DriverResult.failure('Failed to update personal info.');
    }
  }
  
  /// Update driver identification (CNIC) info
  Future<DriverResult> updateIdentification({
    required String driverId,
    required DriverIdentification identification,
    File? cnicFrontPhoto,
    File? cnicBackPhoto,
    String? existingFrontUrl,
    String? existingBackUrl,
  }) async {
    try {
      String? cnicFrontUrl = existingFrontUrl;
      String? cnicBackUrl = existingBackUrl;
      
      // Upload CNIC front photo
      if (cnicFrontPhoto != null) {
        if (existingFrontUrl != null) {
          final oldFileId = _extractFileIdFromUrl(existingFrontUrl);
          if (oldFileId != null) {
            await _storage.deleteFile(bucketId: Buckets.documents, fileId: oldFileId);
          }
        }
        
        final uploadResult = await _storage.uploadImage(
          bucketId: Buckets.documents,
          imageFile: cnicFrontPhoto,
          fileName: 'cnic_front_${driverId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        
        if (uploadResult.success) {
          cnicFrontUrl = Buckets.getFileUrl(Buckets.documents, uploadResult.fileId!);
          debugPrint('📷 CNIC front uploaded: ${uploadResult.fileId}');
        }
      }
      
      // Upload CNIC back photo
      if (cnicBackPhoto != null) {
        if (existingBackUrl != null) {
          final oldFileId = _extractFileIdFromUrl(existingBackUrl);
          if (oldFileId != null) {
            await _storage.deleteFile(bucketId: Buckets.documents, fileId: oldFileId);
          }
        }
        
        final uploadResult = await _storage.uploadImage(
          bucketId: Buckets.documents,
          imageFile: cnicBackPhoto,
          fileName: 'cnic_back_${driverId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        
        if (uploadResult.success) {
          cnicBackUrl = Buckets.getFileUrl(Buckets.documents, uploadResult.fileId!);
          debugPrint('📷 CNIC back uploaded: ${uploadResult.fileId}');
        }
      }
      
      // Update driver row with identification data
      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.drivers,
        rowId: driverId,
        data: {
          'cnicNumber': identification.cnicNumber,
          if (identification.cnicExpiry != null) 
            'cnicExpiry': _toIsoDate(identification.cnicExpiry!),
          if (cnicFrontUrl != null) 'cnicFrontUrl': cnicFrontUrl,
          if (cnicBackUrl != null) 'cnicBackUrl': cnicBackUrl,
        },
      );
      
      debugPrint('✅ Driver identification updated: $driverId');
      
      return DriverResult.success(
        message: 'Identification updated',
        driverId: row.$id,
        driver: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Update identification error: ${e.message}');
      return DriverResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Update identification error: $e');
      return DriverResult.failure('Failed to update identification.');
    }
  }
  
  /// Update driver license info
  Future<DriverResult> updateLicense({
    required String driverId,
    required DriverLicence license,
    File? licensePhoto,
    File? selfieWithLicense,
    String? existingLicenseUrl,
    String? existingSelfieUrl,
  }) async {
    try {
      String? licensePhotoUrl = existingLicenseUrl;
      String? selfieWithLicenseUrl = existingSelfieUrl;
      
      // Upload license photo
      if (licensePhoto != null) {
        if (existingLicenseUrl != null) {
          final oldFileId = _extractFileIdFromUrl(existingLicenseUrl);
          if (oldFileId != null) {
            await _storage.deleteFile(bucketId: Buckets.documents, fileId: oldFileId);
          }
        }
        
        final uploadResult = await _storage.uploadImage(
          bucketId: Buckets.documents,
          imageFile: licensePhoto,
          fileName: 'license_${driverId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        
        if (uploadResult.success) {
          licensePhotoUrl = Buckets.getFileUrl(Buckets.documents, uploadResult.fileId!);
          debugPrint('📷 License photo uploaded: ${uploadResult.fileId}');
        }
      }
      
      // Upload selfie with license
      if (selfieWithLicense != null) {
        if (existingSelfieUrl != null) {
          final oldFileId = _extractFileIdFromUrl(existingSelfieUrl);
          if (oldFileId != null) {
            await _storage.deleteFile(bucketId: Buckets.documents, fileId: oldFileId);
          }
        }
        
        final uploadResult = await _storage.uploadImage(
          bucketId: Buckets.documents,
          imageFile: selfieWithLicense,
          fileName: 'selfie_license_${driverId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        
        if (uploadResult.success) {
          selfieWithLicenseUrl = Buckets.getFileUrl(Buckets.documents, uploadResult.fileId!);
          debugPrint('📷 Selfie with license uploaded: ${uploadResult.fileId}');
        }
      }
      
      // Update driver row with license data
      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.drivers,
        rowId: driverId,
        data: {
          'licenseNumber': license.licenceNumber,
          'licenseExpiry': _toIsoDate(license.licenseExpiry),
          if (licensePhotoUrl != null) 'licensePhotoUrl': licensePhotoUrl,
          if (selfieWithLicenseUrl != null) 'selfieWithLicenseUrl': selfieWithLicenseUrl,
        },
      );
      
      debugPrint('✅ Driver license updated: $driverId');
      
      return DriverResult.success(
        message: 'License updated',
        driverId: row.$id,
        driver: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Update license error: ${e.message}');
      return DriverResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Update license error: $e');
      return DriverResult.failure('Failed to update license.');
    }
  }
  
  /// Set driver online/offline status
  Future<DriverResult> setOnlineStatus({
    required String driverId,
    required bool isOnline,
    List<double>? currentLocation, // [lng, lat]
  }) async {
    try {
      final data = <String, dynamic>{
        'isOnline': isOnline,
        'lastLocationUpdate': DateTime.now().toIso8601String(),
      };
      
      if (currentLocation != null && currentLocation.length == 2) {
        data['currentLocation'] = currentLocation;
      }
      
      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.drivers,
        rowId: driverId,
        data: data,
      );
      
      debugPrint('✅ Driver online status set to: $isOnline');
      
      return DriverResult.success(
        message: isOnline ? 'You are now online' : 'You are now offline',
        driverId: row.$id,
        driver: row.data,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Set online status error: ${e.message}');
      return DriverResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Set online status error: $e');
      return DriverResult.failure('Failed to update status.');
    }
  }
  
  /// Update driver's current location (for real-time tracking)
  Future<DriverResult> updateLocation({
    required String driverId,
    required List<double> location, // [lng, lat]
  }) async {
    try {
      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.drivers,
        rowId: driverId,
        data: {
          'currentLocation': location,
          'lastLocationUpdate': DateTime.now().toIso8601String(),
        },
      );
      
      return DriverResult.success(
        message: 'Location updated',
        driverId: row.$id,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Update location error: ${e.message}');
      return DriverResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Update location error: $e');
      return DriverResult.failure('Failed to update location.');
    }
  }
  
  /// Mark driver registration as complete and set to pending approval
  Future<DriverResult> completeRegistration({
    required String driverId,
  }) async {
    try {
      // Update users table to mark profile complete and set status to pending
      // Note: verificationStatus removed from drivers table - using users.status instead
      final authUserId = AuthService.instance.currentUser?.$id;
      if (authUserId != null) {
        await _tablesDB.updateRow(
          databaseId: AppwriteConfig.databaseId,
          tableId: Collections.users,
          rowId: authUserId,
          data: {
            'isProfileComplete': true,
            'status': CollectionEnums.statusPending, // Awaiting admin approval
          },
        );
      }
      
      debugPrint('✅ Driver registration completed, pending approval: $driverId');
      
      return DriverResult.success(
        message: 'Registration complete! Your application is under review.',
        driverId: driverId,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Complete registration error: ${e.message}');
      return DriverResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Complete registration error: $e');
      return DriverResult.failure('Failed to complete registration.');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // DELETE
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Delete driver profile and all associated photos
  Future<DriverResult> deleteDriver({
    required String driverId,
    Map<String, dynamic>? driverData,
  }) async {
    try {
      // Get driver data if not provided
      final driver = driverData ?? (await getDriverById(driverId)).driver;
      
      // Delete photos from storage
      if (driver != null) {
        final photosToDelete = [
          driver['profilePhotoUrl'],
          driver['cnicFrontUrl'],
          driver['cnicBackUrl'],
          driver['licensePhotoUrl'],
          driver['selfieWithLicenseUrl'],
        ];
        
        for (final url in photosToDelete) {
          if (url != null) {
            final fileId = _extractFileIdFromUrl(url.toString());
            if (fileId != null) {
              try {
                // Determine bucket from URL
                final bucket = url.toString().contains('profile_photos') 
                    ? Buckets.profilePhotos 
                    : Buckets.documents;
                await _storage.deleteFile(bucketId: bucket, fileId: fileId);
              } catch (e) {
                debugPrint('⚠️ Could not delete photo: $e');
              }
            }
          }
        }
      }
      
      // Delete driver row
      await _tablesDB.deleteRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.drivers,
        rowId: driverId,
      );
      
      debugPrint('✅ Driver profile deleted: $driverId');
      
      return DriverResult.success(message: 'Driver profile deleted');
    } on AppwriteException catch (e) {
      debugPrint('❌ Delete driver error: ${e.message}');
      return DriverResult.failure(_parseError(e));
    } catch (e) {
      debugPrint('❌ Delete driver error: $e');
      return DriverResult.failure('Failed to delete driver profile.');
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════
  
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
  
  /// Convert DD-MM-YYYY to ISO 8601 datetime string
  String? _toIsoDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day).toIso8601String();
      }
    } catch (_) {}
    // If already in ISO format or other valid format, return as-is
    return dateStr;
  }
  
  String _parseError(AppwriteException e) {
    switch (e.code) {
      case 401:
        return 'Session expired. Please login again.';
      case 404:
        return 'Driver profile not found.';
      case 409:
        return 'A driver with this information already exists.';
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

/// Result of a driver service operation
class DriverResult {
  final bool success;
  final String message;
  final String? driverId;
  final Map<String, dynamic>? driver;
  final bool notFound;
  
  const DriverResult._({
    required this.success,
    required this.message,
    this.driverId,
    this.driver,
    this.notFound = false,
  });
  
  factory DriverResult.success({
    required String message,
    String? driverId,
    Map<String, dynamic>? driver,
  }) {
    return DriverResult._(
      success: true,
      message: message,
      driverId: driverId,
      driver: driver,
    );
  }
  
  factory DriverResult.failure(String message) {
    return DriverResult._(
      success: false,
      message: message,
    );
  }
  
  factory DriverResult.notFound() {
    return const DriverResult._(
      success: false,
      message: 'Driver profile not found',
      notFound: true,
    );
  }
  
  @override
  String toString() => 'DriverResult(success: $success, message: $message, driverId: $driverId)';
}
