import 'package:get/get.dart';
import 'package:godropme/features/driverSide/driverChat/controllers/driver_chat_controller.dart';

class DriverChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverChatController>(() => DriverChatController());
  }
}
