import 'package:get/get.dart';
import 'package:godropme/features/parentSide/parentChat/controllers/parent_conversation_controller.dart';

class ParentConversationBinding extends Bindings {
  @override
  void dependencies() {
    final args =
        Get.parameters; // if using named params or Get.arguments otherwise
    String contactId = '';
    if (Get.arguments is Map &&
        (Get.arguments as Map).containsKey('contactId')) {
      contactId = (Get.arguments as Map)['contactId'].toString();
    } else if (args.containsKey('contactId')) {
      contactId = args['contactId'] ?? '';
    }
    Get.lazyPut<ParentConversationController>(
      () => ParentConversationController(contactId),
    );
  }
}
