import 'package:get/get.dart';
import 'package:godropme/features/parentSide/parentChat/controllers/parent_chat_controller.dart';

class ParentChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentChatController>(() => ParentChatController());
  }
}
