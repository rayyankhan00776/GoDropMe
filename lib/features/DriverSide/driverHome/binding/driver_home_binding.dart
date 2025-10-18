import 'package:get/get.dart';
import 'package:godropme/features/driverSide/driverHome/controllers/driver_home_controller.dart';

class DriverMapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverHomeController>(() => DriverHomeController());
  }
}
