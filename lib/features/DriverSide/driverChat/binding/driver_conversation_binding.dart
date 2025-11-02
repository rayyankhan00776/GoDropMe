import 'package:get/get.dart';
import 'package:godropme/features/driverSide/driverChat/controllers/driver_conversation_controller.dart';

class DriverConversationBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.parameters;
    String contactId = '';
    if (Get.arguments is Map &&
        (Get.arguments as Map).containsKey('contactId')) {
      contactId = (Get.arguments as Map)['contactId'].toString();
    } else if (args.containsKey('contactId')) {
      contactId = args['contactId'] ?? '';
    }
    Get.lazyPut<DriverConversationController>(
      () => DriverConversationController(contactId),
    );
  }
}
