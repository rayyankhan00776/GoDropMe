import 'package:get/get.dart';
import 'package:godropme/features/DriverSide/notifications/controllers/driver_notifications_controller.dart';

class DriverNotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverNotificationsController>(
      () => DriverNotificationsController(),
    );
  }
}
