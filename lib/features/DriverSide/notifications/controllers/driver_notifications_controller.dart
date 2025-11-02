import 'package:get/get.dart';
import 'package:godropme/features/driverSide/notifications/models/driver_notification.dart';

class DriverNotificationsController extends GetxController {
  final notifications = <DriverNotificationItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    notifications.assignAll(DriverNotificationItem.demo());
  }
}
