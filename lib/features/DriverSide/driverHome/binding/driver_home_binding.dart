import 'package:get/get.dart';
import 'package:godropme/features/driverSide/driverHome/controllers/driver_home_controller.dart';
import 'package:godropme/features/driverSide/driverHome/controllers/driver_requests_controller.dart';
import 'package:godropme/features/driverSide/driverHome/controllers/driver_orders_controller.dart';

class DriverMapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverHomeController>(() => DriverHomeController());
    // Provide requests controller for the Requests tab; recreated when needed.
    Get.lazyPut<DriverRequestsController>(
      () => DriverRequestsController(),
      fenix: true,
    );
    // Provide orders controller for the Orders tab; recreated when needed.
    Get.lazyPut<DriverOrdersController>(
      () => DriverOrdersController(),
      fenix: true,
    );
  }
}
