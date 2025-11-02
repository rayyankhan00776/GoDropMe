import 'package:get/get.dart';
import 'package:godropme/features/parentSide/notifications/controllers/parent_notifications_controller.dart';

class ParentNotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentNotificationsController>(
      () => ParentNotificationsController(),
    );
  }
}
