import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:godropme/features/DriverSide/driverRegistration/models/service_details.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/database_constants.dart';

/// Result wrapper for driver service config operations.
class DriverConfigResult {
  final bool success;
  final String? configId;
  final ServiceDetails? config;
  final String? message;

  const DriverConfigResult({
    required this.success,
    this.configId,
    this.config,
    this.message,
  });

  factory DriverConfigResult.success({
    required String configId,
    required ServiceDetails config,
    String? message,
  }) =>
      DriverConfigResult(
        success: true,
        configId: configId,
        config: config,
        message: message,
      );

  factory DriverConfigResult.failure(String message) =>
      DriverConfigResult(success: false, message: message);
}

/// Service for driver service configuration CRUD operations (driver_services table).
///
/// This service manages the driver's service area, schools served, and pricing.
/// Uses TablesDB API (not deprecated Databases).
class DriverConfigService {
  static DriverConfigService? _instance;
  static DriverConfigService get instance => _instance ??= DriverConfigService._();
  
  final TablesDB _tablesDB = AppwriteClient.tablesDBService();
  
  DriverConfigService._();

  // ═══════════════════════════════════════════════════════════════════════════
  // CREATE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Create a new driver service configuration.
  ///
  /// [driverId] - The driver's ID (foreign key to drivers table)
  /// [serviceDetails] - The service configuration details
  Future<DriverConfigResult> createServiceConfig({
    required String driverId,
    required ServiceDetails serviceDetails,
  }) async {
    try {
      // Build row data
      final data = {
        'driverId': driverId,
        ...serviceDetails.toAppwriteJson(),
      };

      // Create row in driver_services table
      final row = await _tablesDB.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.driverServices,
        rowId: ID.unique(),
        data: data,
      );

      debugPrint('✅ Driver service config created: ${row.$id}');

      // Parse response
      final config = _parseServiceDetails(row.data);
      return DriverConfigResult.success(
        configId: row.$id,
        config: config,
        message: 'Service configuration created successfully',
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Create service config error: ${e.message}');
      return DriverConfigResult.failure(
        'Failed to create service config: ${e.message}',
      );
    } catch (e) {
      debugPrint('❌ Create service config error: $e');
      return DriverConfigResult.failure(
        'Unexpected error creating service config: $e',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // READ
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get driver service configuration by config ID.
  Future<DriverConfigResult> getServiceConfig(String configId) async {
    try {
      final row = await _tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.driverServices,
        rowId: configId,
      );

      debugPrint('✅ Service config loaded: $configId');

      final config = _parseServiceDetails(row.data);
      return DriverConfigResult.success(
        configId: row.$id,
        config: config,
      );
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        return DriverConfigResult.failure('Service configuration not found');
      }
      debugPrint('❌ Get service config error: ${e.message}');
      return DriverConfigResult.failure(
        'Failed to get service config: ${e.message}',
      );
    } catch (e) {
      debugPrint('❌ Get service config error: $e');
      return DriverConfigResult.failure(
        'Unexpected error getting service config: $e',
      );
    }
  }

  /// Get service configuration by driver ID.
  Future<DriverConfigResult> getServiceConfigByDriverId(String driverId) async {
    try {
      final result = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.driverServices,
        queries: [Query.equal('driverId', driverId), Query.limit(1)],
      );

      if (result.rows.isEmpty) {
        debugPrint('ℹ️ No service config found for driver: $driverId');
        return DriverConfigResult.failure(
          'Service configuration not found for driver',
        );
      }

      final row = result.rows.first;
      debugPrint('✅ Service config loaded for driver: $driverId');
      
      final config = _parseServiceDetails(row.data);
      return DriverConfigResult.success(
        configId: row.$id,
        config: config,
      );
    } on AppwriteException catch (e) {
      debugPrint('❌ Get service config by driver ID error: ${e.message}');
      return DriverConfigResult.failure(
        'Failed to get service config by driver ID: ${e.message}',
      );
    } catch (e) {
      debugPrint('❌ Get service config by driver ID error: $e');
      return DriverConfigResult.failure(
        'Unexpected error getting service config: $e',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UPDATE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Update driver service configuration.
  ///
  /// Only provided fields will be updated.
  Future<DriverConfigResult> updateServiceConfig({
    required String configId,
    List<String>? schoolIds,
    String? serviceCategory,
    List<double>? serviceAreaCenter,
    double? serviceAreaRadiusKm,
    List<List<List<double>>>? serviceAreaPolygon,
    String? serviceAreaAddress,
    int? monthlyPricePkr,
    String? extraNotes,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (schoolIds != null) data['schoolIds'] = schoolIds;
      if (serviceCategory != null) data['serviceCategory'] = serviceCategory;
      if (serviceAreaCenter != null) data['serviceAreaCenter'] = serviceAreaCenter;
      if (serviceAreaRadiusKm != null) data['serviceAreaRadiusKm'] = serviceAreaRadiusKm;
      if (serviceAreaPolygon != null) data['serviceAreaPolygon'] = serviceAreaPolygon;
      if (serviceAreaAddress != null) data['serviceAreaAddress'] = serviceAreaAddress;
      if (monthlyPricePkr != null) data['monthlyPricePkr'] = monthlyPricePkr;
      if (extraNotes != null) data['extraNotes'] = extraNotes;

      if (data.isEmpty) {
        return DriverConfigResult.failure('No fields to update');
      }

      final row = await _tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.driverServices,
        rowId: configId,
        data: data,
      );

      debugPrint('✅ Service config updated: $configId');

      final config = _parseServiceDetails(row.data);
      return DriverConfigResult.success(
        configId: row.$id,
        config: config,
        message: 'Service configuration updated successfully',
      );
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        return DriverConfigResult.failure('Service configuration not found');
      }
      debugPrint('❌ Update service config error: ${e.message}');
      return DriverConfigResult.failure(
        'Failed to update service config: ${e.message}',
      );
    } catch (e) {
      debugPrint('❌ Update service config error: $e');
      return DriverConfigResult.failure(
        'Unexpected error updating service config: $e',
      );
    }
  }

  /// Update schools (schoolIds foreign keys).
  Future<DriverConfigResult> updateSchools({
    required String configId,
    required List<String> schoolIds,
  }) async {
    return updateServiceConfig(configId: configId, schoolIds: schoolIds);
  }

  /// Update service area (center point and polygon).
  Future<DriverConfigResult> updateServiceArea({
    required String configId,
    List<double>? serviceAreaCenter,
    double? serviceAreaRadiusKm,
    List<List<List<double>>>? serviceAreaPolygon,
    String? serviceAreaAddress,
  }) async {
    return updateServiceConfig(
      configId: configId,
      serviceAreaCenter: serviceAreaCenter,
      serviceAreaRadiusKm: serviceAreaRadiusKm,
      serviceAreaPolygon: serviceAreaPolygon,
      serviceAreaAddress: serviceAreaAddress,
    );
  }

  /// Update pricing.
  Future<DriverConfigResult> updatePricing({
    required String configId,
    required int monthlyPricePkr,
  }) async {
    return updateServiceConfig(
      configId: configId,
      monthlyPricePkr: monthlyPricePkr,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DELETE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Delete service configuration.
  Future<DriverConfigResult> deleteServiceConfig(String configId) async {
    try {
      await _tablesDB.deleteRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.driverServices,
        rowId: configId,
      );

      debugPrint('✅ Service config deleted: $configId');

      return DriverConfigResult.success(
        configId: configId,
        config: const ServiceDetails(schoolIds: []),
        message: 'Service configuration deleted successfully',
      );
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        return DriverConfigResult.failure('Service configuration not found');
      }
      debugPrint('❌ Delete service config error: ${e.message}');
      return DriverConfigResult.failure(
        'Failed to delete service config: ${e.message}',
      );
    } catch (e) {
      debugPrint('❌ Delete service config error: $e');
      return DriverConfigResult.failure(
        'Unexpected error deleting service config: $e',
      );
    }
  }

  /// Delete service configuration by driver ID.
  Future<DriverConfigResult> deleteServiceConfigByDriverId(
    String driverId,
  ) async {
    try {
      // Find config by driver ID first
      final result = await getServiceConfigByDriverId(driverId);
      if (!result.success || result.configId == null) {
        return DriverConfigResult.failure(
          'Service configuration not found for driver',
        );
      }

      // Delete by config ID
      return deleteServiceConfig(result.configId!);
    } catch (e) {
      debugPrint('❌ Delete service config by driver ID error: $e');
      return DriverConfigResult.failure(
        'Unexpected error deleting service config: $e',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Parse ServiceDetails from row data.
  ServiceDetails _parseServiceDetails(Map<String, dynamic> data) {
    return ServiceDetails.fromJson(data);
  }

  /// Check if driver has service configuration.
  Future<bool> hasServiceConfig(String driverId) async {
    try {
      final result = await _tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: Collections.driverServices,
        queries: [Query.equal('driverId', driverId), Query.limit(1)],
      );
      return result.rows.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Check service config error: $e');
      return false;
    }
  }

  /// Create or update service configuration (upsert).
  ///
  /// If config exists for driver, updates it. Otherwise creates new.
  Future<DriverConfigResult> upsertServiceConfig({
    required String driverId,
    required ServiceDetails serviceDetails,
  }) async {
    try {
      // Check if config exists
      final existing = await getServiceConfigByDriverId(driverId);
      
      if (existing.success && existing.configId != null) {
        // Update existing
        debugPrint('ℹ️ Updating existing service config for driver: $driverId');
        return updateServiceConfig(
          configId: existing.configId!,
          schoolIds: serviceDetails.schoolIds,
          serviceCategory: serviceDetails.serviceCategory,
          serviceAreaCenter: serviceDetails.serviceAreaCenter,
          serviceAreaRadiusKm: serviceDetails.serviceAreaRadiusKm,
          serviceAreaPolygon: serviceDetails.serviceAreaPolygon,
          serviceAreaAddress: serviceDetails.serviceAreaAddress,
          monthlyPricePkr: serviceDetails.monthlyPricePkr,
          extraNotes: serviceDetails.extraNotes,
        );
      } else {
        // Create new
        debugPrint('ℹ️ Creating new service config for driver: $driverId');
        return createServiceConfig(
          driverId: driverId,
          serviceDetails: serviceDetails,
        );
      }
    } catch (e) {
      debugPrint('❌ Upsert service config error: $e');
      return DriverConfigResult.failure(
        'Unexpected error upserting service config: $e',
      );
    }
  }
}
