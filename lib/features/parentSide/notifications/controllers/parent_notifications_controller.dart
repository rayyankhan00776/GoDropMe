import 'package:get/get.dart';
import 'package:godropme/features/parentSide/notifications/models/parent_notification.dart';

class ParentNotificationsController extends GetxController {
  final notifications = <ParentNotificationItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Seed with demo data for now
    notifications.assignAll(ParentNotificationItem.demo());
  }
}
