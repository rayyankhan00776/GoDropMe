import 'package:get/get.dart';
import 'package:godropme/features/driverSide/driverChat/models/chat_message.dart';

class DriverConversationController extends GetxController {
  final String contactId;
  final messages = <DriverChatMessage>[].obs;

  DriverConversationController(this.contactId);

  @override
  void onInit() {
    super.onInit();
    messages.assignAll(DriverChatMessage.demoFor(contactId));
  }

  void send(String text) {
    if (text.trim().isEmpty) return;
    messages.add(
      DriverChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        contactId: contactId,
        text: text.trim(),
        fromMe: true,
        time: DateTime.now(),
      ),
    );
  }
}
