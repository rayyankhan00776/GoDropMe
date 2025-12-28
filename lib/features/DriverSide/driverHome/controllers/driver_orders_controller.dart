import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/features/DriverSide/driverHome/models/driver_order.dart';
import 'package:godropme/services/appwrite/trip_service.dart';
import 'package:godropme/services/appwrite/driver_service.dart';
import 'package:godropme/services/appwrite/child_service.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/database_constants.dart';
import 'package:godropme/utils/schools_loader.dart';

class DriverOrdersController extends GetxController {
  /// All trips for today (both morning and afternoon)
  final RxList<DriverOrder> _allOrders = <DriverOrder>[].obs;

  /// Filtered orders based on current time window
  final RxList<DriverOrder> orders = <DriverOrder>[].obs;

  final isProcessing = false.obs;
  final isLoading = false.obs;
  final errorMessage = Rxn<String>();

  /// Driver ID (fetched on init)
  final driverId = Rxn<String>();

  /// Current active window: 'morning' or 'afternoon' (observable)
  final RxString currentWindow = 'morning'.obs;

  /// Driver online/offline status
  /// When online: trips change from 'scheduled' to 'driver_enroute'
  /// When offline: driver is not actively picking up children
  final RxBool isOnline = false.obs;

  /// Calculate and update current window based on time
  void _updateCurrentWindow() {
    final hour = DateTime.now().hour;
    // Morning window: 5 AM - 9 AM
    // Afternoon window: 11 AM - 3 PM
    // Off hours: 3 PM - 5 AM (show next available)
    if (hour >= 5 && hour < 9) {
      currentWindow.value = 'morning';
    } else if (hour >= 11 && hour < 15) {
      currentWindow.value = 'afternoon';
    } else {
      // Off hours - show morning for next day prep
      currentWindow.value = 'morning';
    }
  }

  @override
  void onInit() {
    super.onInit();
    _updateCurrentWindow();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadDriverId();
    await loadTodayTrips();
  }

  /// Load driver ID from DriverService
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

  /// Load today's trips from backend
  Future<void> loadTodayTrips() async {
    if (driverId.value == null) {
      // No driver ID - show empty state
      _allOrders.clear();
      _filterOrdersByWindow();
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await TripService.instance.getTodayTrips(
        driverId: driverId.value!,
      );

      if (result.success) {
        // Enrich trips with child/parent names and school names
        final enrichedOrders = <DriverOrder>[];

        for (final trip in result.trips) {
          final enriched = await _enrichTripData(trip);
          enrichedOrders.add(DriverOrder.fromJson(enriched));
        }

        _allOrders.assignAll(enrichedOrders);
        _filterOrdersByWindow();
        debugPrint('✅ Loaded ${_allOrders.length} trips from backend');
      } else {
        errorMessage.value = result.message;
        // Failed to load - show empty state
        _allOrders.clear();
        _filterOrdersByWindow();
      }
    } catch (e) {
      debugPrint('❌ Load trips error: $e');
      errorMessage.value = 'Failed to load trips';
      // Error - show empty state
      _allOrders.clear();
      _filterOrdersByWindow();
    } finally {
      isLoading.value = false;
    }
  }

  /// Enrich trip data with child name, parent name, and school name
  Future<Map<String, dynamic>> _enrichTripData(
    Map<String, dynamic> trip,
  ) async {
    final enriched = Map<String, dynamic>.from(trip);

    // Fetch child data
    if (trip['childId'] != null) {
      try {
        final childResult = await ChildService.instance.getChild(
          trip['childId'],
        );
        if (childResult.success && childResult.child != null) {
          enriched['childName'] = childResult.child!.name;
          enriched['childAvatarUrl'] = childResult.child!.photoUrl;
          enriched['pickPoint'] = trip['tripDirection'] == 'home_to_school'
              ? childResult.child!.pickPoint
              : childResult.child!.dropPoint;
          enriched['dropPoint'] = trip['tripDirection'] == 'home_to_school'
              ? childResult.child!.dropPoint
              : childResult.child!.pickPoint;

          // Get school name
          if (childResult.child!.schoolId.isNotEmpty) {
            final school = await SchoolsLoader.getById(
              childResult.child!.schoolId,
            );
            enriched['schoolName'] = school?.name ?? 'School';
          }
        }
      } catch (e) {
        debugPrint('⚠️ Error fetching child data: $e');
      }
    }

    // Fetch parent data
    if (trip['parentId'] != null) {
      try {
        final tablesDB = AppwriteClient.tablesDBService();
        final parentRow = await tablesDB.getRow(
          databaseId: AppwriteConfig.databaseId,
          tableId: Collections.parents,
          rowId: trip['parentId'],
        );
        enriched['parentName'] = parentRow.data['fullName'] ?? 'Parent';
        enriched['avatarUrl'] = parentRow.data['profilePhotoUrl'];
      } catch (e) {
        debugPrint('⚠️ Error fetching parent data: $e');
        enriched['parentName'] = 'Parent';
      }
    }

    return enriched;
  }

  /// Filter orders to show only current window's trips
  void _filterOrdersByWindow() {
    final window = currentWindow.value;
    orders.assignAll(_allOrders.where((o) => o.tripType == window).toList());
    
    // Update online status based on current window's orders
    _checkOnlineStatus();
  }
  
  /// Check if any trips in current window are in driver_enroute status
  void _checkOnlineStatus() {
    final hasActiveTrips = orders.any(
      (o) => o.status == DriverOrderStatus.driverEnroute ||
             o.status == DriverOrderStatus.arrived ||
             o.status == DriverOrderStatus.picked ||
             o.status == DriverOrderStatus.inTransit,
    );
    isOnline.value = hasActiveTrips;
  }

  /// Toggle driver online/offline status
  /// When going online: starts all scheduled trips in current window (status → driver_enroute)
  /// When going offline: no action (trips remain in current state)
  /// ONLY changes trip status if within service window
  Future<void> toggleOnlineStatus() async {
    if (isProcessing.value) return;
    
    final goingOnline = !isOnline.value;
    
    if (goingOnline) {
      // Validate service window - STRICT CHECK
      final hour = DateTime.now().hour;
      final inMorningWindow = hour >= 5 && hour < 9;
      final inAfternoonWindow = hour >= 11 && hour < 15;
      final inServiceWindow = inMorningWindow || inAfternoonWindow;
      
      if (!inServiceWindow) {
        // BLOCK: Do not start trips outside service hours
        Get.snackbar(
          'Outside Service Hours',
          'Cannot start trips now. Service hours:\nMorning: 5 AM-9 AM\nAfternoon: 11 AM-3 PM',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        debugPrint('❌ Cannot go online - outside service window (hour: $hour)');
        return; // Exit without changing status
      }
      
      // Within service window - proceed to start trips
      final scheduledTrips = orders.where(
        (o) => o.status == DriverOrderStatus.scheduled,
      ).toList();
      
      debugPrint('🚗 Going online - Found ${scheduledTrips.length} scheduled trips (hour: $hour, window: ${currentWindow.value})');
      
      if (scheduledTrips.isEmpty) {
        // No scheduled trips, but still mark as online
        isOnline.value = true;
        Get.snackbar(
          'Online',
          'You are now online. No scheduled trips at the moment.',
        );
        return;
      }
      
      isProcessing.value = true;
      int successCount = 0;
      final List<String> failedTrips = [];
      
      try {
        for (final trip in scheduledTrips) {
          debugPrint('🚀 Starting trip: ${trip.id} for ${trip.childName}');
          final result = await TripService.instance.startTrip(trip.id);
          
          if (result.success) {
            _updateLocalStatus(trip.id, DriverOrderStatus.driverEnroute);
            successCount++;
            debugPrint('✅ Trip started: ${trip.id}');
          } else {
            failedTrips.add(trip.childName);
            debugPrint('❌ Failed to start trip ${trip.id}: ${result.message}');
          }
        }
        
        if (successCount > 0) {
          isOnline.value = true;
          Get.snackbar(
            'Online',
            'Started $successCount trip${successCount > 1 ? 's' : ''}. You are now enroute!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
        
        if (failedTrips.isNotEmpty) {
          Get.snackbar(
            'Some Trips Failed',
            'Could not start: ${failedTrips.join(", ")}',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
        }
      } catch (e) {
        debugPrint('❌ Toggle online error: $e');
        Get.snackbar(
          'Error',
          'Failed to go online: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isProcessing.value = false;
      }
    } else {
      // Going offline - just update local state
      // Note: We don't revert trips back to scheduled
      isOnline.value = false;
      Get.snackbar(
        'Offline',
        'You are now offline. Active trips will continue.',
      );
    }
  }

  /// Refresh and re-filter (call when time window changes)
  /// Preserves online status during refresh
  Future<void> refreshOrders() async {
    final wasOnline = isOnline.value;
    _updateCurrentWindow();
    await loadTodayTrips();
    // Restore online status if it was on before refresh
    if (wasOnline) {
      isOnline.value = true;
    }
  }

  void addOrder(DriverOrder order) {
    _allOrders.add(order);
    _filterOrdersByWindow();
  }

  /// Start a trip - Driver begins route
  Future<void> startTrip(String id) async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    try {
      final result = await TripService.instance.startTrip(id);

      if (result.success) {
        _updateLocalStatus(id, DriverOrderStatus.driverEnroute);
        Get.snackbar('Trip Started', 'You are now enroute to pickup');
      } else {
        Get.snackbar('Error', result.message);
      }
    } catch (e) {
      debugPrint('❌ Start trip error: $e');
      Get.snackbar('Error', 'Failed to start trip');
    } finally {
      isProcessing.value = false;
    }
  }

  /// Mark arrived at pickup location
  Future<void> markArrived(String id) async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    try {
      final result = await TripService.instance.markArrived(id);

      if (result.success) {
        _updateLocalStatus(id, DriverOrderStatus.arrived);
        Get.snackbar('Arrived', 'You have arrived at pickup location');
      } else {
        Get.snackbar('Error', result.message);
      }
    } catch (e) {
      debugPrint('❌ Mark arrived error: $e');
      Get.snackbar('Error', 'Failed to mark arrived');
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> markPicked(String id) async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    try {
      final result = await TripService.instance.markPicked(id);

      if (result.success) {
        _updateLocalStatus(id, DriverOrderStatus.picked);
        Get.snackbar('Picked Up', 'Child has been picked up');
      } else {
        Get.snackbar('Error', result.message);
      }
    } catch (e) {
      debugPrint('❌ Mark picked error: $e');
      Get.snackbar('Error', 'Failed to mark picked');
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> markDropped(String id) async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    try {
      final result = await TripService.instance.markDropped(id);

      if (result.success) {
        _updateLocalStatus(id, DriverOrderStatus.dropped);
        Get.snackbar('Dropped Off', 'Child has been dropped off safely');
      } else {
        Get.snackbar('Error', result.message);
      }
    } catch (e) {
      debugPrint('❌ Mark dropped error: $e');
      Get.snackbar('Error', 'Failed to mark dropped');
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> markAbsent(String id, {String? reason}) async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    try {
      final result = await TripService.instance.markAbsent(id, reason: reason);

      if (result.success) {
        _updateLocalStatus(id, DriverOrderStatus.absent);
        Get.snackbar('Marked Absent', 'Trip marked as absent');
      } else {
        Get.snackbar('Error', result.message);
      }
    } catch (e) {
      debugPrint('❌ Mark absent error: $e');
      Get.snackbar('Error', 'Failed to mark absent');
    } finally {
      isProcessing.value = false;
    }
  }

  /// Update local state after successful backend call
  void _updateLocalStatus(String id, DriverOrderStatus status) {
    // Update in _allOrders (source of truth)
    final allIdx = _allOrders.indexWhere((o) => o.id == id);
    if (allIdx != -1) {
      _allOrders[allIdx].status = status;
    }
    // Update in filtered orders
    final idx = orders.indexWhere((o) => o.id == id);
    if (idx != -1) {
      orders[idx].status = status;
      orders.refresh();
    }
  }
}
