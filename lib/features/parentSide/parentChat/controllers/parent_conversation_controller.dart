import 'package:get/get.dart';
import 'package:godropme/features/parentSide/parentChat/models/chat_message.dart';

class ParentConversationController extends GetxController {
  final String contactId;
  final messages = <ParentChatMessage>[].obs;

  ParentConversationController(this.contactId);

  @override
  void onInit() {
    super.onInit();
    messages.assignAll(ParentChatMessage.demoFor(contactId));
  }

  void send(String text) {
    if (text.trim().isEmpty) return;
    messages.add(
      ParentChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        contactId: contactId,
        text: text.trim(),
        fromMe: true,
        time: DateTime.now(),
      ),
    );
  }
}
