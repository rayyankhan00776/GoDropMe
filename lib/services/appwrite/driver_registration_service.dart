import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:godropme/features/DriverSide/driverRegistration/models/driver_identification.dart';
import 'package:godropme/features/DriverSide/driverRegistration/models/driver_licence.dart';
import 'package:godropme/features/DriverSide/driverRegistration/models/personal_info.dart';
import 'package:godropme/features/DriverSide/driverRegistration/models/service_details.dart';
import 'package:godropme/features/DriverSide/driverRegistration/models/vehicle_registration.dart';
import 'package:godropme/models/enums/vehicle_type.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/auth_service.dart';
import 'package:godropme/services/appwrite/database_constants.dart';
import 'package:godropme/services/appwrite/driver_config_service.dart';
import 'package:godropme/services/appwrite/driver_service.dart';
import 'package:godropme/services/appwrite/vehicle_service.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';

/// Result wrapper for driver registration operations.
class RegistrationResult {
  final bool success;
  final String? message;
  final String? driverId;
  final String? vehicleId;
  final String? configId;

  const RegistrationResult({
    required this.success,
    this.message,
    this.driverId,
    this.vehicleId,
    this.configId,
  });

  factory RegistrationResult.success({
    String? message,
    String? driverId,
    String? vehicleId,
    String? configId,
  }) =>
      RegistrationResult(
        success: true,
        message: message,
        driverId: driverId,
        vehicleId: vehicleId,
        configId: configId,
      );

  factory RegistrationResult.failure(String message) =>
      RegistrationResult(success: false, message: message);
}

/// Orchestrates the complete driver registration flow.
///
/// This service collects all locally stored registration data,
/// uploads files to Appwrite Storage, and creates records in:
/// - drivers table (profile + documents)
/// - vehicles table (vehicle info + photos)
/// - driver_services table (service config)
///
/// Usage:
/// ```dart
/// final result = await DriverRegistrationService.instance.submitRegistration();
/// if (result.success) {
///   // Navigate to pending approval
/// } else {
///   // Show error: result.message
/// }
/// ```
class DriverRegistrationService {
  static DriverRegistrationService? _instance;
  static DriverRegistrationService get instance =>
      _instance ??= DriverRegistrationService._();

  final DriverService _driverService = DriverService.instance;
  final VehicleService _vehicleService = VehicleService.instance;
  final DriverConfigService _configService = DriverConfigService.instance;

  DriverRegistrationService._();

  /// Strip dashes and non-digit characters from CNIC number.
  /// Converts "17301-4753215-4" to "1730147532154" (13 digits).
  String _sanitizeCnic(String cnic) {
    return cnic.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Submit complete driver registration to Appwrite.
  ///
  /// Collects all data from local storage and sends to backend.
  /// This should be called on the final registration step.
  Future<RegistrationResult> submitRegistration() async {
    try {
      // Verify user is logged in
      final authUser = AuthService.instance.currentUser;
      if (authUser == null) {
        return RegistrationResult.failure('Please login first');
      }

      debugPrint('🚗 Starting driver registration submission...');

      // 1. Load all local storage data
      final data = await _loadAllLocalData();
      if (data == null) {
        return RegistrationResult.failure(
          'Missing registration data. Please complete all steps.',
        );
      }

      // 2. Create driver profile with all documents
      // NOTE: This now uploads all photos and provides all required fields at once
      final driverResult = await _createDriverProfile(data, authUser.email);
      if (!driverResult.success || driverResult.driverId == null) {
        return RegistrationResult.failure(
          driverResult.message,
        );
      }
      final driverId = driverResult.driverId!;
      debugPrint('✅ Driver profile created with all documents: $driverId');

      // 3. Create vehicle record
      final vehicleResult = await _createVehicle(driverId, data);
      if (!vehicleResult.success || vehicleResult.vehicleId == null) {
        debugPrint('⚠️ Warning: Vehicle not created - ${vehicleResult.message}');
      }
      final vehicleId = vehicleResult.vehicleId;
      if (vehicleId != null) {
        debugPrint('✅ Vehicle created: $vehicleId');
      }

      // 4. Create service configuration
      final configResult = await _createServiceConfig(driverId, data);
      if (!configResult.success) {
        debugPrint('⚠️ Warning: Service config not created - ${configResult.message}');
      }
      final configId = configResult.configId;
      if (configId != null) {
        debugPrint('✅ Service config created: $configId');
      }

      // 5. Mark user profile as complete (optional - might be done via auth_service)
      await _markProfileComplete();

      debugPrint('🎉 Driver registration completed successfully!');

      return RegistrationResult.success(
        message: 'Registration submitted successfully',
        driverId: driverId,
        vehicleId: vehicleId,
        configId: configId,
      );
    } catch (e) {
      debugPrint('❌ Registration submission error: $e');
      return RegistrationResult.failure(
        'Registration failed. Please try again.',
      );
    }
  }

  /// Load all registration data from local storage.
  Future<_RegistrationData?> _loadAllLocalData() async {
    try {
      final driverName = await LocalStorage.getString(StorageKeys.driverName);
      final vehicleType =
          await LocalStorage.getString(StorageKeys.vehicleSelection);
      final personal =
          await LocalStorage.getJson(StorageKeys.personalInfo);
      final licence = await LocalStorage.getJson(StorageKeys.driverLicence);
      final identification =
          await LocalStorage.getJson(StorageKeys.driverIdentification);
      final vehicle =
          await LocalStorage.getJson(StorageKeys.vehicleRegistration);
      final serviceDetails =
          await LocalStorage.getJson(StorageKeys.driverServiceDetails);

      // Validate required data
      if (driverName == null || driverName.isEmpty) {
        debugPrint('❌ Missing driver name');
        return null;
      }
      if (personal == null) {
        debugPrint('❌ Missing personal info');
        return null;
      }

      return _RegistrationData(
        driverName: driverName,
        vehicleType: vehicleType ?? 'car',
        personal: personal,
        licence: licence,
        identification: identification,
        vehicle: vehicle,
        serviceDetails: serviceDetails,
      );
    } catch (e) {
      debugPrint('❌ Error loading local data: $e');
      return null;
    }
  }

  /// Create driver profile with ALL required documents in Appwrite.
  /// Uses createDriverComplete() to provide all required fields at creation time.
  Future<DriverResult> _createDriverProfile(
    _RegistrationData data,
    String email,
  ) async {
    // Build PersonalInfo from stored data
    final personal = PersonalInfo(
      firstName: (data.personal['firstName'] ?? '') as String,
      surName: (data.personal['surName'] ?? '') as String,
      lastName: (data.personal['lastName'] ?? '') as String,
      phone: (data.personal['phoneE164'] ?? data.personal['phone'] ?? '') as String,
      photoPath: data.personal['imagePath'] as String?,
    );

    // Get profile photo file if exists
    File? profilePhoto;
    final photoPath = personal.photoPath;
    if (photoPath != null && photoPath.isNotEmpty) {
      final file = File(photoPath);
      if (await file.exists()) {
        profilePhoto = file;
      }
    }

    // Build DriverIdentification from stored data
    DriverIdentification? identification;
    File? cnicFrontFile;
    File? cnicBackFile;

    if (data.identification != null) {
      // Sanitize CNIC number - remove dashes for storage (13 digits only)
      final rawCnic = (data.identification!['cnicNumber'] ?? '') as String;
      final sanitizedCnic = _sanitizeCnic(rawCnic);

      identification = DriverIdentification(
        cnicNumber: sanitizedCnic,
        cnicExpiry: (data.identification!['cnicExpiry'] ?? data.identification!['expiryDate'] ?? '') as String,
      );

      // Get CNIC photo files
      final frontPath = data.identification!['frontImagePath'] as String?;
      final backPath = data.identification!['backImagePath'] as String?;

      if (frontPath != null && frontPath.isNotEmpty) {
        final file = File(frontPath);
        if (await file.exists()) cnicFrontFile = file;
      }
      if (backPath != null && backPath.isNotEmpty) {
        final file = File(backPath);
        if (await file.exists()) cnicBackFile = file;
      }
    }

    // Build DriverLicence from stored data
    DriverLicence? licence;
    File? licenseFile;
    File? selfieFile;

    if (data.licence != null) {
      licence = DriverLicence(
        licenceNumber: (data.licence!['licenceNumber'] ?? '') as String,
        licenseExpiry: (data.licence!['licenseExpiry'] ?? data.licence!['expiryDate'] ?? '') as String,
      );

      // Get license photo files
      final licensePath = data.licence!['licenceImagePath'] as String?;
      final selfiePath = data.licence!['selfieWithLicencePath'] as String?;

      if (licensePath != null && licensePath.isNotEmpty) {
        final file = File(licensePath);
        if (await file.exists()) licenseFile = file;
      }
      if (selfiePath != null && selfiePath.isNotEmpty) {
        final file = File(selfiePath);
        if (await file.exists()) selfieFile = file;
      }
    }

    // Ensure all required files exist before calling createDriverComplete
    if (profilePhoto == null) {
      return DriverResult.failure('Profile photo is required');
    }
    if (cnicFrontFile == null) {
      return DriverResult.failure('CNIC front photo is required');
    }
    if (cnicBackFile == null) {
      return DriverResult.failure('CNIC back photo is required');
    }
    if (licenseFile == null) {
      return DriverResult.failure('License photo is required');
    }
    if (selfieFile == null) {
      return DriverResult.failure('Selfie with license is required');
    }

    // Use createDriverComplete() to provide ALL required fields at creation time
    return _driverService.createDriverComplete(
      personalInfo: personal,
      identification: identification ?? DriverIdentification(cnicNumber: '', cnicExpiry: ''),
      licence: licence ?? DriverLicence(licenceNumber: '', licenseExpiry: ''),
      email: email,
      profilePhoto: profilePhoto,
      cnicFront: cnicFrontFile,
      cnicBack: cnicBackFile,
      licensePhoto: licenseFile,
      selfieWithLicense: selfieFile,
    );
  }

  /// Create vehicle record in Appwrite.
  Future<VehicleResult> _createVehicle(
    String driverId,
    _RegistrationData data,
  ) async {
    if (data.vehicle == null) {
      return VehicleResult.failure('No vehicle data provided');
    }

    // Build VehicleRegistration from stored data
    final vehicleReg = VehicleRegistration(
      vehicleType: data.vehicleType == 'rikshaw'
          ? VehicleType.rikshaw
          : VehicleType.car,
      brand: (data.vehicle!['brand'] ?? '') as String,
      model: (data.vehicle!['model'] ?? '') as String,
      color: (data.vehicle!['color'] ?? '') as String,
      productionYear: (data.vehicle!['year'] ?? '') as String,
      numberPlate: (data.vehicle!['plate'] ?? '') as String,
      seatCapacity: (data.vehicle!['seatCapacity'] as num?)?.toInt() ?? 4,
      vehiclePhotoPath: data.vehicle!['vehiclePhotoPath'] as String?,
      certificateFrontPath: data.vehicle!['certFrontPath'] as String?,
      certificateBackPath: data.vehicle!['certBackPath'] as String?,
    );

    // Get vehicle photo file if exists
    File? vehiclePhoto;
    final photoPath = vehicleReg.vehiclePhotoPath;
    if (photoPath != null && photoPath.isNotEmpty) {
      final file = File(photoPath);
      if (await file.exists()) {
        vehiclePhoto = file;
      }
    }

    // Get registration certificate files
    File? certFront;
    File? certBack;
    final frontPath = vehicleReg.certificateFrontPath;
    final backPath = vehicleReg.certificateBackPath;
    if (frontPath != null && frontPath.isNotEmpty) {
      final file = File(frontPath);
      if (await file.exists()) certFront = file;
    }
    if (backPath != null && backPath.isNotEmpty) {
      final file = File(backPath);
      if (await file.exists()) certBack = file;
    }

    return _vehicleService.createVehicle(
      driverId: driverId,
      vehicle: vehicleReg,
      vehiclePhoto: vehiclePhoto,
      registrationFront: certFront,
      registrationBack: certBack,
    );
  }

  /// Create service configuration in Appwrite.
  Future<DriverConfigResult> _createServiceConfig(
    String driverId,
    _RegistrationData data,
  ) async {
    if (data.serviceDetails == null) {
      return DriverConfigResult.failure('No service details provided');
    }

    // Build ServiceDetails from stored data
    final sd = data.serviceDetails!;

    // Parse school IDs
    List<String> schoolIds = [];
    final schoolIdsData = sd['schoolIds'];
    if (schoolIdsData is List) {
      schoolIds = schoolIdsData.map((e) => e.toString()).toList();
    }

    // Parse center point [lng, lat]
    List<double>? centerPoint;
    final centerData = sd['serviceAreaCenter'];
    if (centerData is List && centerData.length >= 2) {
      centerPoint = [
        (centerData[0] as num).toDouble(),
        (centerData[1] as num).toDouble(),
      ];
    }

    // Parse polygon [[[lng, lat], ...]]
    List<List<List<double>>>? polygon;
    final polyData = sd['serviceAreaPolygon'];
    if (polyData is List && polyData.isNotEmpty) {
      // Check if it's already 3D format
      if (polyData.first is List &&
          (polyData.first as List).isNotEmpty &&
          (polyData.first as List).first is List) {
        // Already 3D format
        polygon = [];
        for (final ring in polyData) {
          if (ring is List) {
            final parsedRing = <List<double>>[];
            for (final p in ring) {
              if (p is List && p.length >= 2) {
                parsedRing.add([
                  (p[0] as num).toDouble(),
                  (p[1] as num).toDouble(),
                ]);
              }
            }
            if (parsedRing.isNotEmpty) polygon.add(parsedRing);
          }
        }
      }
    }

    final serviceDetails = ServiceDetails(
      schoolIds: schoolIds,
      serviceCategory: sd['serviceCategory']?.toString(),
      serviceAreaCenter: centerPoint,
      serviceAreaRadiusKm: (sd['serviceAreaRadiusKm'] as num?)?.toDouble(),
      serviceAreaPolygon: polygon,
      serviceAreaAddress: sd['serviceAreaAddress']?.toString(),
      monthlyPricePkr: (sd['monthlyPricePkr'] as num?)?.toInt(),
      extraNotes: sd['extraNotes']?.toString(),
    );

    return _configService.createServiceConfig(
      driverId: driverId,
      serviceDetails: serviceDetails,
    );
  }

  /// Mark user profile as complete in users table.
  Future<void> _markProfileComplete() async {
    try {
      final authUser = AuthService.instance.currentUser;
      if (authUser == null) {
        debugPrint('⚠️ No auth user to mark profile complete');
        return;
      }

      // Update users table to mark profile as complete
      await AppwriteClient.tablesDBService().updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.users,
        rowId: authUser.$id,
        data: {
          'isProfileComplete': true,
        },
      );

      // Save locally too
      await LocalStorage.setString('driver_registration_submitted', 'true');
      debugPrint('📝 Registration submission marked complete in users table');
    } catch (e) {
      debugPrint('⚠️ Failed to mark profile complete: $e');
      // Don't fail the whole registration for this
    }
  }

  /// Clear all local registration data after successful submission.
  Future<void> clearLocalData() async {
    try {
      await LocalStorage.remove(StorageKeys.driverName);
      await LocalStorage.remove(StorageKeys.vehicleSelection);
      await LocalStorage.remove(StorageKeys.personalInfo);
      await LocalStorage.remove(StorageKeys.driverLicence);
      await LocalStorage.remove(StorageKeys.driverIdentification);
      await LocalStorage.remove(StorageKeys.vehicleRegistration);
      await LocalStorage.remove(StorageKeys.driverServiceDetails);
      debugPrint('🗑️ Local registration data cleared');
    } catch (e) {
      debugPrint('⚠️ Failed to clear local data: $e');
    }
  }
}

/// Internal class to hold all registration data.
class _RegistrationData {
  final String driverName;
  final String vehicleType;
  final Map<String, dynamic> personal;
  final Map<String, dynamic>? licence;
  final Map<String, dynamic>? identification;
  final Map<String, dynamic>? vehicle;
  final Map<String, dynamic>? serviceDetails;

  _RegistrationData({
    required this.driverName,
    required this.vehicleType,
    required this.personal,
    this.licence,
    this.identification,
    this.vehicle,
    this.serviceDetails,
  });
}
