import 'package:get/get.dart';
import 'package:godropme/features/driverSide/notifications/controllers/driver_notifications_controller.dart';

class DriverNotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverNotificationsController>(
      () => DriverNotificationsController(),
    );
  }
}
