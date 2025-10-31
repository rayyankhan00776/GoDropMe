import 'package:get/get.dart';
import 'package:godropme/features/driverSide/driverHome/models/driver_request.dart';
import 'package:godropme/features/driverSide/driverHome/controllers/driver_orders_controller.dart';
import 'package:godropme/features/driverSide/driverHome/models/driver_order.dart';

class DriverRequestsController extends GetxController {
  final RxList<DriverRequest> requests = <DriverRequest>[].obs;
  final isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load initial demo data; replace with backend fetch later
    requests.assignAll(DriverRequest.demo());
  }

  Future<void> accept(String id) async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    try {
      // TODO: Hook: call backend accept endpoint
      await Future.delayed(const Duration(milliseconds: 250));
      final idx = requests.indexWhere((r) => r.id == id);
      if (idx != -1) {
        final r = requests[idx];
        // Add to orders if controller available
        if (Get.isRegistered<DriverOrdersController>()) {
          final ordersCtrl = Get.find<DriverOrdersController>();
          ordersCtrl.addOrder(
            DriverOrder.fromRequest(
              id: 'ord_${r.id}',
              parentName: r.parentName,
              avatarUrl: r.avatarUrl,
              schoolName: r.schoolName,
              pickPoint: r.pickPoint,
              dropPoint: r.dropPoint,
            ),
          );
        }
        requests.removeAt(idx);
      }
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> reject(String id) async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    try {
      // TODO: Hook: call backend reject endpoint
      await Future.delayed(const Duration(milliseconds: 250));
      requests.removeWhere((r) => r.id == id);
    } finally {
      isProcessing.value = false;
    }
  }
}
