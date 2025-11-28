import 'package:get/get.dart';
import 'package:godropme/features/DriverSide/driverRegistration/controllers/driver_identification_controller.dart';

class DriverIdentificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverIdentificationController>(
      () => DriverIdentificationController(),
    );
  }
}
