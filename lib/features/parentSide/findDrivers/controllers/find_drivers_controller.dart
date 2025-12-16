import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart';
import 'package:godropme/features/parentSide/addChildren/models/child.dart';
import 'package:godropme/features/parentSide/findDrivers/models/driver_listing.dart';
import 'package:godropme/features/parentSide/findDrivers/models/active_service.dart';
import 'package:godropme/services/appwrite/child_service.dart';
import 'package:godropme/services/appwrite/parent_service.dart';
import 'package:godropme/services/appwrite/service_request_service.dart';
import 'package:godropme/services/appwrite/active_service_service.dart';
import 'package:godropme/services/appwrite/driver_service.dart';
import 'package:godropme/services/appwrite/vehicle_service.dart';
import 'package:godropme/services/appwrite/database_constants.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/utils/schools_loader.dart';

/// Controller for the FindDriversScreen
/// 
/// Manages:
/// - Children list for the parent
/// - Selected child for service requests
/// - Available drivers (Find tab)
/// - Pending requests (Requested tab)
/// - Active services (Active tab)
class FindDriversController extends GetxController {
  // ═══════════════════════════════════════════════════════════════════════════
  // OBSERVABLES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Cache for schoolId -> schoolName lookups
  final Map<String, String> _schoolNameCache = {};
  
  /// Parent ID (fetched on init)
  final parentId = Rxn<String>();
  
  /// List of parent's children
  final children = <ChildModel>[].obs;
  
  /// Currently selected child for service requests
  final selectedChildId = Rxn<String>();
  
  /// Available drivers list (Find tab)
  final availableDrivers = <DriverListing>[].obs;
  
  /// Pending service requests (Requested tab)
  final pendingRequests = <Map<String, dynamic>>[].obs;
  
  /// Active services (Active tab)
  final activeServices = <ActiveService>[].obs;
  
  /// Loading states
  final isLoadingChildren = false.obs;
  final isLoadingDrivers = false.obs;
  final isLoadingRequests = false.obs;
  final isLoadingActiveServices = false.obs;
  final isSendingRequest = false.obs;
  final isEndingService = false.obs;
  
  /// Error message (if any)
  final errorMessage = Rxn<String>();
  
  // ═══════════════════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ═══════════════════════════════════════════════════════════════════════════
  
  @override
  void onInit() {
    super.onInit();
    _initialize();
  }
  
  Future<void> _initialize() async {
    await _loadParentAndChildren();
    
    // Auto-select first child if available
    if (children.isNotEmpty && selectedChildId.value == null) {
      selectedChildId.value = children.first.id;
    }
    
    // Load initial data for all tabs
    await Future.wait([
      loadAvailableDrivers(),
      loadPendingRequests(),
      loadActiveServices(),
    ]);
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // LOAD CHILDREN
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Refresh children list (public method for UI)
  Future<void> refreshChildren() async {
    await _loadParentAndChildren();
    
    // If previously selected child no longer exists, select first available
    if (selectedChildId.value != null && 
        !children.any((c) => c.id == selectedChildId.value)) {
      selectedChildId.value = children.isNotEmpty ? children.first.id : null;
    }
    
    // Auto-select first child if none selected and children available
    if (selectedChildId.value == null && children.isNotEmpty) {
      selectedChildId.value = children.first.id;
    }
    
    // Reload driver data for new/updated child
    if (selectedChildId.value != null) {
      await loadAvailableDrivers();
    }
  }
  
  /// Load parent profile and children
  Future<void> _loadParentAndChildren() async {
    isLoadingChildren.value = true;
    errorMessage.value = null;
    
    try {
      // Get parent profile
      final parentResult = await ParentService.instance.getParent();
      if (!parentResult.success || parentResult.parent == null) {
        errorMessage.value = 'Could not load parent profile';
        return;
      }
      parentId.value = parentResult.parent!.id;
      
      // Load children
      final childResult = await ChildService.instance.getChildren(
        parentId: parentId.value,
      );
      
      if (childResult.success) {
        children.assignAll(childResult.children);
        debugPrint('✅ Loaded ${children.length} children');
      } else {
        errorMessage.value = childResult.message;
      }
    } catch (e) {
      debugPrint('❌ Load children error: $e');
      errorMessage.value = 'Failed to load children';
    } finally {
      isLoadingChildren.value = false;
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // FIND TAB - Available Drivers
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Load available drivers for the selected child's pickup location
  /// 
  /// Calls Appwrite function `match-drivers` which:
  /// 1. Performs geo-query: serviceAreaPolygon contains child's pickup location
  /// 2. Filters by school: driver serves child's school
  /// 3. Filters by service category: matches child's gender or "Both"
  /// 4. Returns only active drivers with vehicle details
  Future<void> loadAvailableDrivers() async {
    if (selectedChildId.value == null) {
      availableDrivers.clear();
      return;
    }
    
    isLoadingDrivers.value = true;
    errorMessage.value = null;
    
    try {
      // Get selected child
      final child = selectedChild;
      if (child == null) {
        availableDrivers.clear();
        return;
      }
      
      // Validate child has required data
      if (child.pickLocation == null || 
          child.pickLocation!.isEmpty || 
          child.pickLocation!.length != 2) {
        debugPrint('⚠️ Child ${child.id} has no valid pickup location');
        errorMessage.value = 'Please set pickup location for this child';
        availableDrivers.clear();
        return;
      }
      
      if (child.schoolId.isEmpty) {
        debugPrint('⚠️ Child ${child.id} has no school assigned');
        errorMessage.value = 'Please assign a school to this child';
        availableDrivers.clear();
        return;
      }
      
      debugPrint('🔍 Calling match-drivers function for child ${child.id}');
      debugPrint('   Pickup: ${child.pickLocation}');
      debugPrint('   School: ${child.schoolId}');
      debugPrint('   Gender: ${child.gender}');
      
      // Call Appwrite function: match-drivers
      final functions = AppwriteClient.functionsService();
      
      final execution = await functions.createExecution(
        functionId: 'match-drivers',
        body: jsonEncode({
          'childId': child.id,
          'pickupPoint': child.pickLocation, // [lng, lat]
          'schoolId': child.schoolId,
          'gender': child.gender,
        }),
        xasync: false, // Wait for response synchronously
      );
      
      debugPrint('✅ Function execution: ${execution.status} (${execution.responseStatusCode})');
      
      // Check execution status
      if (execution.responseStatusCode != 200) {
        final errorBody = execution.responseBody.isNotEmpty 
            ? execution.responseBody 
            : 'Function returned status ${execution.responseStatusCode}';
        throw Exception(errorBody);
      }
      
      // Parse function response
      final response = jsonDecode(execution.responseBody) as Map<String, dynamic>;
      
      if (response['success'] != true) {
        final message = response['message'] ?? 'Function returned error';
        debugPrint('❌ Function error: $message');
        errorMessage.value = message;
        availableDrivers.clear();
        return;
      }
      
      final driversData = (response['drivers'] as List<dynamic>?) ?? [];
      debugPrint('📦 Received ${driversData.length} drivers from function');
      
      // Convert to DriverListing models
      final drivers = <DriverListing>[];
      
      for (final data in driversData) {
        try {
          final driverMap = data as Map<String, dynamic>;
          final vehicle = driverMap['vehicle'] as Map<String, dynamic>?;
          
          drivers.add(DriverListing(
            driverId: driverMap['driverId'] ?? '',
            name: driverMap['name'] ?? 'Driver',
            vehicle: vehicle != null 
                ? '${vehicle['brand'] ?? ''} ${vehicle['model'] ?? ''}'.trim()
                : 'Vehicle',
            vehicleColor: vehicle?['color'] ?? '',
            type: _capitalizeFirst(vehicle?['type'] ?? 'car'),
            seatsAvailable: (driverMap['availableSeats'] as num?)?.toInt() ?? 0,
            serving: driverMap['schoolNames'] ?? '',
            serviceArea: driverMap['serviceAreaAddress'] ?? '',
            serviceCategory: driverMap['serviceCategory'] ?? 'Both',
            monthlyPricePkr: (driverMap['monthlyPricePkr'] as num?)?.toInt() ?? 0,
            extraNotes: driverMap['extraNotes'] ?? '',
            photoAsset: '',
            profilePhotoFileId: driverMap['profilePhotoUrl'],
            rating: (driverMap['rating'] as num?)?.toDouble() ?? 0.0,
            totalTrips: (driverMap['totalTrips'] as num?)?.toInt() ?? 0,
          ));
        } catch (e) {
          debugPrint('⚠️ Error parsing driver data: $e');
        }
      }
      
      availableDrivers.assignAll(drivers);
      
      if (drivers.isEmpty) {
        errorMessage.value = response['message'] ?? 'No drivers found in your area';
      }
      
      debugPrint('✅ Loaded ${availableDrivers.length} matched drivers');
      
    } catch (e) {
      debugPrint('❌ Load drivers error: $e');
      errorMessage.value = 'Failed to load drivers: ${e.toString()}';
      availableDrivers.clear();
    } finally {
      isLoadingDrivers.value = false;
    }
  }
  
  /// Capitalize first letter
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // REQUESTED TAB - Pending Requests
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Load pending service requests for the parent
  Future<void> loadPendingRequests() async {
    if (parentId.value == null) return;
    
    isLoadingRequests.value = true;
    
    try {
      final result = await ServiceRequestService.instance.getParentRequests(
        parentId: parentId.value!,
        status: CollectionEnums.requestPending,
      );
      
      if (result.success) {
        // Enrich requests with driver, vehicle, and service data
        final enrichedRequests = <Map<String, dynamic>>[];
        
        for (final request in result.requests) {
          final enriched = Map<String, dynamic>.from(request);
          
          // Fetch driver data
          if (request['driverId'] != null) {
            try {
              final driverResult = await DriverService.instance.getDriverById(request['driverId']);
              if (driverResult.success && driverResult.driver != null) {
                final driver = driverResult.driver!;
                enriched['driverRef'] = {
                  'fullName': '${driver['firstName'] ?? ''} ${driver['surname'] ?? ''} ${driver['lastName'] ?? ''}'.trim(),
                  'profilePhotoUrl': driver['profilePhotoUrl'],
                  'rating': driver['rating'],
                  'totalTrips': driver['totalTrips'],
                  'phone': driver['phone'],
                };
                
                // Fetch vehicle data by driverId
                final tablesDB = AppwriteClient.tablesDBService();
                final vehicleResult = await tablesDB.listRows(
                  databaseId: AppwriteConfig.databaseId,
                  tableId: Collections.vehicles,
                  queries: [Query.equal('driverId', request['driverId'])],
                );
                
                if (vehicleResult.rows.isNotEmpty) {
                  final vehicle = vehicleResult.rows.first.data;
                  enriched['driverRef']['vehicle'] = {
                    'brand': vehicle['brand'],
                    'model': vehicle['model'],
                    'color': vehicle['color'],
                    'vehicleType': vehicle['vehicleType'],
                    'seatCapacity': vehicle['seatCapacity'],
                  };
                }
              }
            } catch (e) {
              debugPrint('⚠️ Error fetching driver data: $e');
            }
          }
          
          // Fetch driver service config (for schools, service area, etc.)
          if (request['driverId'] != null) {
            try {
              // Use driver_services collection to get service config
              final tablesDB = AppwriteClient.tablesDBService();
              final serviceResult = await tablesDB.listRows(
                databaseId: AppwriteConfig.databaseId,
                tableId: Collections.driverServices,
                queries: [Query.equal('driverId', request['driverId'])],
              );
              
              if (serviceResult.rows.isNotEmpty) {
                final serviceData = serviceResult.rows.first.data;
                
                // Get school names from IDs
                final schoolIds = serviceData['schoolIds'] as List<dynamic>?;
                String schoolNames = '';
                if (schoolIds != null && schoolIds.isNotEmpty) {
                  final names = <String>[];
                  for (final id in schoolIds) {
                    final name = await getSchoolName(id.toString());
                    if (name != 'School') names.add(name);
                  }
                  schoolNames = names.join(', ');
                }
                
                enriched['serviceRef'] = {
                  'schoolNames': schoolNames,
                  'serviceAreaAddress': serviceData['serviceAreaAddress'],
                  'serviceCategory': serviceData['serviceCategory'],
                  'monthlyPricePkr': serviceData['monthlyPricePkr'],
                  'extraNotes': serviceData['extraNotes'],
                };
              }
            } catch (e) {
              debugPrint('⚠️ Error fetching service data: $e');
            }
          }
          
          enrichedRequests.add(enriched);
        }
        
        pendingRequests.assignAll(enrichedRequests);
        debugPrint('✅ Loaded ${pendingRequests.length} pending requests (enriched)');
      }
    } catch (e) {
      debugPrint('❌ Load requests error: $e');
    } finally {
      isLoadingRequests.value = false;
    }
  }
  
  /// Send a service request to a driver
  Future<bool> sendRequest({
    required String driverId,
    double? proposedPrice,
  }) async {
    if (parentId.value == null || selectedChildId.value == null) {
      Get.snackbar('Error', 'Please select a child first');
      return false;
    }
    
    // Check if child already has an active service
    final hasActive = await ServiceRequestService.instance.childHasActiveService(
      selectedChildId.value!,
    );
    if (hasActive) {
      Get.snackbar('Error', 'This child already has an active service');
      return false;
    }
    
    // Check if there's already a pending request
    final hasPending = await ServiceRequestService.instance.hasPendingRequest(
      parentId: parentId.value!,
      driverId: driverId,
      childId: selectedChildId.value!,
    );
    if (hasPending) {
      Get.snackbar('Info', 'You already have a pending request with this driver');
      return false;
    }
    
    isSendingRequest.value = true;
    
    try {
      final result = await ServiceRequestService.instance.sendRequest(
        parentId: parentId.value!,
        driverId: driverId,
        childId: selectedChildId.value!,
        proposedPrice: proposedPrice,
      );
      
      if (result.success) {
        Get.snackbar('Success', 'Request sent to driver');
        
        // Refresh requests list
        await loadPendingRequests();
        
        // Optionally remove driver from available list
        availableDrivers.removeWhere((d) => d.driverId == driverId);
        
        return true;
      } else {
        Get.snackbar('Error', result.message);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Send request error: $e');
      Get.snackbar('Error', 'Failed to send request');
      return false;
    } finally {
      isSendingRequest.value = false;
    }
  }
  
  /// Cancel a pending request
  Future<bool> cancelRequest(String requestId) async {
    try {
      final result = await ServiceRequestService.instance.cancelRequest(
        requestId: requestId,
      );
      
      if (result.success) {
        Get.snackbar('Success', 'Request cancelled');
        pendingRequests.removeWhere((r) => r['id'] == requestId);
        return true;
      } else {
        Get.snackbar('Error', result.message);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Cancel request error: $e');
      Get.snackbar('Error', 'Failed to cancel request');
      return false;
    }
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // ACTIVE TAB - Active Services
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Load active services for the parent
  Future<void> loadActiveServices() async {
    if (parentId.value == null) return;
    
    isLoadingActiveServices.value = true;
    
    try {
      final result = await ActiveServiceService.instance.getParentActiveServices(
        parentId: parentId.value!,
      );
      
      if (result.success) {
        final services = <ActiveService>[];

        for (final data in result.services) {
          // Fetch child data using FK
          final childId = data['childId'] as String?;
          ChildModel? childModel;
          if (childId != null) {
            final childResult = await ChildService.instance.getChild(childId);
            if (childResult.success) {
              childModel = childResult.child;
            }
          }
          
          // Fetch driver data using FK  
          final driverId = data['driverId'] as String?;
          Map<String, dynamic>? driverData;
          if (driverId != null) {
            final driverResult = await DriverService.instance.getDriverById(driverId);
            if (driverResult.success) {
              driverData = driverResult.driver;
            }
          }
          
          // Fetch vehicle data using driver FK
          Map<String, dynamic>? vehicleData;
          if (driverId != null) {
            final vehicleResult = await VehicleService.instance.getVehicleByDriverId(driverId);
            if (vehicleResult.success) {
              vehicleData = vehicleResult.vehicle;
            }
          }
          
          final schoolName = childModel != null
              ? await getSchoolName(childModel.schoolId)
              : 'School';

          services.add(ActiveService(
            id: data['id'] ?? '',
            driverId: driverId ?? '',
            driverName: driverData?['fullName'] ?? 'Driver',
            driverPhotoUrl: driverData?['profilePhotoUrl'],
            driverPhone: driverData?['phone'],
            driverRating: (driverData?['rating'] as num?)?.toDouble(),
            childId: childId ?? '',
            childName: childModel?.name ?? 'Child',
            schoolName: schoolName,
            pickPoint: childModel?.pickPoint ?? '',
            dropPoint: childModel?.dropPoint ?? '',
            monthlyFeePkr: (data['monthlyFee'] as num?)?.toInt() ?? 0,
            vehicleType: vehicleData?['vehicleType'] ?? 'Car',
            vehicleInfo: _getVehicleInfo(vehicleData),
            startDate: DateTime.tryParse(data['startDate'] ?? ''),
            status: data['status'] ?? 'active',
          ));
        }

        activeServices.assignAll(services);
        debugPrint('✅ Loaded ${activeServices.length} active services');
      }
    } catch (e) {
      debugPrint('❌ Load active services error: $e');
    } finally {
      isLoadingActiveServices.value = false;
    }
  }
  
  /// End an active service
  Future<bool> endService(String serviceId) async {
    isEndingService.value = true;
    
    try {
      final result = await ActiveServiceService.instance.endService(
        serviceId: serviceId,
      );
      
      if (result.success) {
        Get.snackbar('Success', 'Service ended');
        activeServices.removeWhere((s) => s.id == serviceId);
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
  
  // ═══════════════════════════════════════════════════════════════════════════
  // CHILD SELECTION
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Select a child and refresh available drivers
  void selectChild(String childId) {
    if (selectedChildId.value != childId) {
      selectedChildId.value = childId;
      loadAvailableDrivers();
    }
  }
  
  /// Get currently selected child
  ChildModel? get selectedChild {
    if (selectedChildId.value == null) return null;
    return children.firstWhereOrNull((c) => c.id == selectedChildId.value);
  }
  
  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════
  
  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadAvailableDrivers(),
      loadPendingRequests(),
      loadActiveServices(),
    ]);
  }
  
  /// Get school name by ID with caching; returns 'School' when not found
  Future<String> getSchoolName(String? schoolId) async {
    if (schoolId == null || schoolId.isEmpty) return 'School';

    if (_schoolNameCache.containsKey(schoolId)) {
      return _schoolNameCache[schoolId]!;
    }

    try {
      final school = await SchoolsLoader.getById(schoolId);
      final name = school?.name ?? 'School';
      _schoolNameCache[schoolId] = name;
      return name;
    } catch (e) {
      debugPrint('⚠️ Error fetching school name: $e');
      return 'School';
    }
  }
  
  /// Get vehicle info string from vehicle data
  String _getVehicleInfo(Map<String, dynamic>? vehicleData) {
    if (vehicleData == null) return 'Vehicle';
    final color = vehicleData['color'] ?? '';
    final brand = vehicleData['brand'] ?? '';
    final model = vehicleData['model'] ?? '';
    return '$color $brand $model'.trim();
  }
}
