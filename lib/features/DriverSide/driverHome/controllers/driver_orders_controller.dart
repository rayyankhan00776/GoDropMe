import 'package:get/get.dart';
import 'package:godropme/features/DriverSide/driverHome/models/driver_order.dart';

class DriverOrdersController extends GetxController {
  /// All trips for today (both morning and afternoon)
  final RxList<DriverOrder> _allOrders = <DriverOrder>[].obs;
  
  /// Filtered orders based on current time window
  final RxList<DriverOrder> orders = <DriverOrder>[].obs;
  
  final isProcessing = false.obs;
  
  /// Current active window: 'morning' or 'afternoon' (observable)
  final RxString currentWindow = 'morning'.obs;
  
  /// Calculate and update current window based on time
  void _updateCurrentWindow() {
    final hour = DateTime.now().hour;
    // Morning window: 5 AM - 10:59 AM
    // Afternoon window: 11 AM - 4 PM
    // Off hours: 4 PM - 5 AM (show next available)
    if (hour >= 5 && hour < 11) {
      currentWindow.value = 'morning';
    } else if (hour >= 11 && hour < 16) {
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
    _loadDemoOrders();
    _filterOrdersByWindow();
  }
  
  void _loadDemoOrders() {
    // Demo: one morning and one afternoon trip
    _allOrders.assignAll([
      DriverOrder(
        id: 'trip_morning_1',
        activeServiceId: 'svc_1',
        parentId: 'parent_1',
        childId: 'child_1',
        parentName: 'Sara Ahmed',
        childName: 'Ali',
        schoolName: 'Allied School',
        pickPoint: 'Block A-3, Gulberg',  // Home
        dropPoint: 'Allied School Gate 1', // School
        tripDirection: 'home_to_school',
        tripType: 'morning',
        status: DriverOrderStatus.scheduled,
        windowStartTime: '05:00',
        windowEndTime: '09:00',
      ),
      DriverOrder(
        id: 'trip_afternoon_1',
        activeServiceId: 'svc_1',
        parentId: 'parent_1',
        childId: 'child_1',
        parentName: 'Sara Ahmed',
        childName: 'Ali',
        schoolName: 'Allied School',
        pickPoint: 'Allied School Gate 1', // School
        dropPoint: 'Block A-3, Gulberg',   // Home
        tripDirection: 'school_to_home',
        tripType: 'afternoon',
        status: DriverOrderStatus.scheduled,
        windowStartTime: '11:00',
        windowEndTime: '15:00',
      ),
    ]);
  }
  
  /// Filter orders to show only current window's trips
  void _filterOrdersByWindow() {
    final window = currentWindow.value;
    orders.assignAll(
      _allOrders.where((o) => o.tripType == window).toList(),
    );
  }
  
  /// Refresh and re-filter (call when time window changes)
  void refreshOrders() {
    _updateCurrentWindow();
    _filterOrdersByWindow();
  }

  void addOrder(DriverOrder order) {
    _allOrders.add(order);
    _filterOrdersByWindow();
  }

  Future<void> markPicked(String id) async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    try {
      // TODO: backend call to mark picked
      await Future.delayed(const Duration(milliseconds: 250));
      // Update in _allOrders (source of truth)
      final allIdx = _allOrders.indexWhere((o) => o.id == id);
      if (allIdx != -1) {
        _allOrders[allIdx].status = DriverOrderStatus.picked;
      }
      // Update in filtered orders
      final idx = orders.indexWhere((o) => o.id == id);
      if (idx != -1) {
        orders[idx].status = DriverOrderStatus.picked;
        orders.refresh();
      }
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> markDropped(String id) async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    try {
      // TODO: backend call to mark dropped
      await Future.delayed(const Duration(milliseconds: 250));
      // Update in _allOrders (source of truth)
      final allIdx = _allOrders.indexWhere((o) => o.id == id);
      if (allIdx != -1) {
        _allOrders[allIdx].status = DriverOrderStatus.dropped;
      }
      // Update in filtered orders
      final idx = orders.indexWhere((o) => o.id == id);
      if (idx != -1) {
        orders[idx].status = DriverOrderStatus.dropped;
        orders.refresh();
      }
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> markAbsent(String id) async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    try {
      // TODO: backend call to mark child absent
      await Future.delayed(const Duration(milliseconds: 250));
      // Update in _allOrders (source of truth)
      final allIdx = _allOrders.indexWhere((o) => o.id == id);
      if (allIdx != -1) {
        _allOrders[allIdx].status = DriverOrderStatus.absent;
      }
      // Update in filtered orders
      final idx = orders.indexWhere((o) => o.id == id);
      if (idx != -1) {
        orders[idx].status = DriverOrderStatus.absent;
        orders.refresh();
      }
    } finally {
      isProcessing.value = false;
    }
  }
}
