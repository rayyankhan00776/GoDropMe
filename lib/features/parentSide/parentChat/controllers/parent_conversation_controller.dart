import 'package:get/get.dart';
import 'package:godropme/features/parentSide/parentChat/models/chat_message.dart';

class ParentConversationController extends GetxController {
  final String chatRoomId;
  final String currentParentId;
  final messages = <ParentChatMessage>[].obs;

  ParentConversationController(this.chatRoomId, {this.currentParentId = 'parent_1'});

  @override
  void onInit() {
    super.onInit();
    messages.assignAll(ParentChatMessage.demoFor(chatRoomId));
  }

  void send(String text) {
    if (text.trim().isEmpty) return;
    messages.add(
      ParentChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        chatRoomId: chatRoomId,
        senderId: currentParentId,
        senderRole: 'parent',
        text: text.trim(),
        time: DateTime.now(),
      ),
    );
  }
}
