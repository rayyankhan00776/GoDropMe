import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/features/DriverSide/driverHome/models/driver_request.dart';
import 'package:godropme/features/DriverSide/driverHome/controllers/driver_orders_controller.dart';
import 'package:godropme/features/DriverSide/driverHome/models/driver_order.dart';
import 'package:godropme/services/appwrite/service_request_service.dart';
import 'package:godropme/services/appwrite/active_service_service.dart';
import 'package:godropme/services/appwrite/driver_service.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/database_constants.dart';
import 'package:godropme/utils/schools_loader.dart';

class DriverRequestsController extends GetxController {
  final RxList<DriverRequest> requests = <DriverRequest>[].obs;
  final isProcessing = false.obs;
  final isLoading = false.obs;
  final driverId = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadDriverId();
    await loadRequests();
  }

  /// Clean location strings by removing plus codes (e.g., "2HCQ+R88, ")
  String _cleanLocation(String location) {
    return location.replaceFirst(RegExp(r'^[A-Z0-9]+\+[A-Z0-9]+,\s*'), '');
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

  /// Load pending requests from backend
  Future<void> loadRequests() async {
    if (driverId.value == null) {
      // Fallback to demo data if driver ID not available
      requests.assignAll(DriverRequest.demo());
      return;
    }

    isLoading.value = true;
    try {
      final result = await ServiceRequestService.instance.getDriverPendingRequests(
        driverId: driverId.value!,
      );

      if (result.success) {
        // Enrich requests with parent, child, and school data
        final enrichedRequests = <DriverRequest>[];
        
        for (final request in result.requests) {
          final enriched = Map<String, dynamic>.from(request);
          
          // Fetch parent data
          if (request['parentId'] != null) {
            try {
              final tablesDB = AppwriteClient.tablesDBService();
              final parentResult = await tablesDB.getRow(
                databaseId: AppwriteConfig.databaseId,
                tableId: Collections.parents,
                rowId: request['parentId'],
              );
              
              enriched['parentRef'] = {
                'fullName': parentResult.data['fullName'],
                'profilePhotoUrl': parentResult.data['profilePhotoUrl'],
              };
            } catch (e) {
              debugPrint('⚠️ Error fetching parent data: $e');
            }
          }
          
          // Fetch child data
          if (request['childId'] != null) {
            try {
              final tablesDB = AppwriteClient.tablesDBService();
              final childResult = await tablesDB.getRow(
                databaseId: AppwriteConfig.databaseId,
                tableId: Collections.children,
                rowId: request['childId'],
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
              
              enriched['childRef'] = {
                'name': childResult.data['name'],
                'age': childResult.data['age'],
                'gender': childResult.data['gender'],
                'pickPoint': _cleanLocation(childResult.data['pickPoint'] ?? ''),
                'dropPoint': _cleanLocation(childResult.data['dropPoint'] ?? ''),
              };
              enriched['schoolName'] = schoolName;
            } catch (e) {
              debugPrint('⚠️ Error fetching child data: $e');
            }
          }
          
          enrichedRequests.add(DriverRequest.fromJson(enriched));
        }
        
        requests.assignAll(enrichedRequests);
        debugPrint('✅ Loaded ${requests.length} pending requests (enriched)');
      } else {
        // Fallback to demo data
        requests.assignAll(DriverRequest.demo());
      }
    } catch (e) {
      debugPrint('❌ Load requests error: $e');
      requests.assignAll(DriverRequest.demo());
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh requests
  Future<void> refresh() => loadRequests();

  Future<void> accept(String id, {double? monthlyFee}) async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    try {
      // Accept request in backend
      final acceptResult = await ServiceRequestService.instance.acceptRequest(
        requestId: id,
        responseMessage: 'Request accepted',
      );

      if (!acceptResult.success) {
        Get.snackbar('Error', acceptResult.message);
        return;
      }

      // Get the request data for creating active service
      final requestIndex = requests.indexWhere((r) => r.id == id);
      if (requestIndex == -1) return;
      final request = requests[requestIndex];

      // Create active service from the accepted request
      final serviceResult = await ActiveServiceService.instance.createActiveService(
        parentId: request.parentId,
        driverId: driverId.value!,
        childId: request.childId,
        monthlyFee: monthlyFee ?? request.proposedPrice?.toDouble() ?? 0.0,
      );

      if (serviceResult.success) {
        // Add to orders if controller available
        if (Get.isRegistered<DriverOrdersController>()) {
          final ordersCtrl = Get.find<DriverOrdersController>();
          ordersCtrl.addOrder(
            DriverOrder.fromRequest(
              id: serviceResult.serviceId ?? 'ord_$id',
              parentId: request.parentId,
              childId: request.childId,
              parentName: request.parentName,
              childName: request.childName,
              avatarUrl: request.avatarUrl,
              schoolName: request.schoolName,
              pickPoint: request.pickPoint,
              dropPoint: request.dropPoint,
            ),
          );
        }

        // Remove from requests list
        requests.removeAt(requestIndex);

        Get.snackbar('Success', 'Request accepted! Service is now active.');
      } else {
        Get.snackbar('Error', serviceResult.message);
      }
    } catch (e) {
      debugPrint('❌ Accept request error: $e');
      Get.snackbar('Error', 'Failed to accept request');
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> reject(String id, {String? reason}) async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    try {
      final result = await ServiceRequestService.instance.rejectRequest(
        requestId: id,
        responseMessage: reason ?? 'Request rejected',
      );

      if (result.success) {
        requests.removeWhere((r) => r.id == id);
        Get.snackbar('Success', 'Request rejected');
      } else {
        Get.snackbar('Error', result.message);
      }
    } catch (e) {
      debugPrint('❌ Reject request error: $e');
      Get.snackbar('Error', 'Failed to reject request');
    } finally {
      isProcessing.value = false;
    }
  }
}
