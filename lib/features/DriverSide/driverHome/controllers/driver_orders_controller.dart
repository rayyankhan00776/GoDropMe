import 'package:get/get.dart';
import 'package:godropme/features/driverSide/driverHome/models/driver_order.dart';

class DriverOrdersController extends GetxController {
  final RxList<DriverOrder> orders = <DriverOrder>[].obs;
  final isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Seed with one demo order
    orders.assignAll(DriverOrder.demo());
  }

  void addOrder(DriverOrder order) => orders.add(order);

  Future<void> markPicked(String id) async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    try {
      // TODO: backend call to mark picked
      await Future.delayed(const Duration(milliseconds: 250));
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
      final idx = orders.indexWhere((o) => o.id == id);
      if (idx != -1) {
        orders[idx].status = DriverOrderStatus.dropped;
        orders.refresh();
      }
    } finally {
      isProcessing.value = false;
    }
  }
}
