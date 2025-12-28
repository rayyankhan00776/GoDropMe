import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/features/DriverSide/driverHome/models/driver_active_service.dart';
import 'package:godropme/services/appwrite/active_service_service.dart';
import 'package:godropme/services/appwrite/driver_service.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/database_constants.dart';
import 'package:godropme/utils/schools_loader.dart';

class DriverActiveServicesController extends GetxController {
  final RxList<DriverActiveService> services = <DriverActiveService>[].obs;
  final isLoading = false.obs;
  final isEndingService = false.obs;
  final driverId = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadDriverId();
    await loadActiveServices();
  }

  Future<void> _loadDriverId() async {
    try {
      final result = await DriverService.instance.getDriver();
      if (result.success && result.driverId != null) {
        driverId.value = result.driverId;
      }
    } catch (e) {
      debugPrint('❌ Load driver ID error: $e');
    }
  }

  /// Clean location strings by removing plus codes (e.g., "2HCQ+R88, ")
  String _cleanLocation(String location) {
    return location.replaceFirst(RegExp(r'^[A-Z0-9]+\+[A-Z0-9]+,\s*'), '');
  }

  /// Load active services from backend
  Future<void> loadActiveServices() async {
    if (driverId.value == null) {
      // No driver ID - show empty state
      services.clear();
      return;
    }

    isLoading.value = true;
    try {
      final result = await ActiveServiceService.instance.getDriverActiveServices(
        driverId: driverId.value!,
      );

      if (result.success) {
        // Enrich services with parent, child, and school data
        final enrichedServices = <DriverActiveService>[];
        
        for (final service in result.services) {
          final enriched = Map<String, dynamic>.from(service);
          
          // Ensure monthlyFee is mapped correctly (DB has 'monthlyFee', model expects 'monthlyFeePkr')
          if (service['monthlyFee'] != null && enriched['monthlyFeePkr'] == null) {
            enriched['monthlyFeePkr'] = service['monthlyFee'];
          }
          
          // Fetch parent data
          if (service['parentId'] != null) {
            try {
              final tablesDB = AppwriteClient.tablesDBService();
              final parentResult = await tablesDB.getRow(
                databaseId: AppwriteConfig.databaseId,
                tableId: Collections.parents,
                rowId: service['parentId'],
              );
              
              enriched['parentName'] = parentResult.data['fullName'];
              enriched['parentPhone'] = parentResult.data['phone'];
              enriched['parentPhotoUrl'] = parentResult.data['profilePhotoUrl'];
            } catch (e) {
              debugPrint('⚠️ Error fetching parent data: $e');
            }
          }
          
          // Fetch child data
          if (service['childId'] != null) {
            try {
              final tablesDB = AppwriteClient.tablesDBService();
              final childResult = await tablesDB.getRow(
                databaseId: AppwriteConfig.databaseId,
                tableId: Collections.children,
                rowId: service['childId'],
              );
              
              // Get school name
              final schoolId = childResult.data['schoolId'];
              String schoolName = 'School';
              if (schoolId != null) {
                try {
                  final school = await SchoolsLoader.getById(schoolId);
                  schoolName = school?.name ?? 'School';
                } catch (e) {
                  debugPrint('⚠️ Error fetching school: $e');
                }
              }
              
              enriched['childName'] = childResult.data['name'];
              enriched['childAge'] = childResult.data['age'];
              enriched['schoolName'] = schoolName;
              enriched['pickPoint'] = _cleanLocation(childResult.data['pickPoint'] ?? '');
              enriched['dropPoint'] = _cleanLocation(childResult.data['dropPoint'] ?? '');
            } catch (e) {
              debugPrint('⚠️ Error fetching child data: $e');
            }
          }
          
          // Get vehicle info
          if (driverId.value != null) {
            try {
              final tablesDB = AppwriteClient.tablesDBService();
              final vehicleResult = await tablesDB.listRows(
                databaseId: AppwriteConfig.databaseId,
                tableId: Collections.vehicles,
                queries: [Query.equal('driverId', driverId.value!)],
              );
              
              if (vehicleResult.rows.isNotEmpty) {
                final vehicle = vehicleResult.rows.first.data;
                final color = vehicle['color'] ?? '';
                final brand = vehicle['brand'] ?? '';
                final model = vehicle['model'] ?? '';
                enriched['vehicleInfo'] = '$color $brand $model'.trim();
                
                // Capitalize vehicle type
                String vehicleType = vehicle['vehicleType']?.toString() ?? 'car';
                vehicleType = vehicleType.isEmpty 
                    ? 'Car' 
                    : vehicleType[0].toUpperCase() + vehicleType.substring(1).toLowerCase();
                enriched['vehicleType'] = vehicleType;
              }
            } catch (e) {
              debugPrint('⚠️ Error fetching vehicle data: $e');
            }
          }
          
          enrichedServices.add(DriverActiveService.fromJson(enriched));
        }
        
        services.assignAll(enrichedServices);
        debugPrint('✅ Loaded ${services.length} active services (enriched)');
      } else {
        // Failed to load - show empty state
        services.clear();
      }
    } catch (e) {
      debugPrint('❌ Load active services error: $e');
      services.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh services
  @override
  Future<void> refresh() => loadActiveServices();

  /// End an active service
  Future<bool> endService(String serviceId) async {
    if (isEndingService.value) return false;
    
    isEndingService.value = true;
    try {
      final result = await ActiveServiceService.instance.endService(
        serviceId: serviceId,
      );
      
      if (result.success) {
        services.removeWhere((s) => s.id == serviceId);
        Get.snackbar('Success', 'Service ended successfully');
        return true;
      } else {
        Get.snackbar('Error', result.message);
        return false;
      }
    } catch (e) {
      debugPrint('❌ End service error: $e');
      Get.snackbar('Error', 'Failed to end service');
      return false;
    } finally {
      isEndingService.value = false;
    }
  }

  int get activeCount => services.where((s) => s.status == 'active').length;
}
