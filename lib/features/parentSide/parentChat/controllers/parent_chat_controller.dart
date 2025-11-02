import 'package:get/get.dart';
import 'package:godropme/features/parentSide/parentChat/models/chat_contact.dart';

class ParentChatController extends GetxController {
  final contacts = <ParentChatContact>[].obs;

  @override
  void onInit() {
    super.onInit();
    contacts.assignAll(ParentChatContact.demo());
  }
}
