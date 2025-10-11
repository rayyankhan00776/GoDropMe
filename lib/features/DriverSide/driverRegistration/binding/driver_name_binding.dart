import 'package:get/get.dart';
import 'package:godropme/features/DriverSide/driverRegistration/controllers/driver_name_controller.dart';

class DriverNameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverNameController>(() => DriverNameController());
  }
}
