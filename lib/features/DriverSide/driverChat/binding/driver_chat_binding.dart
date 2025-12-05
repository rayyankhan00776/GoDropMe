import 'package:get/get.dart';
import 'package:godropme/features/DriverSide/driverChat/controllers/driver_chat_controller.dart';

class DriverChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverChatController>(() => DriverChatController());
  }
}
