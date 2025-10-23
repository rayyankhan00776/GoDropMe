import 'package:get/get.dart';
import 'package:godropme/features/driverSide/driverRegistration/controllers/service_details_controller.dart';

class ServiceDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServiceDetailsController>(() => ServiceDetailsController());
  }
}
