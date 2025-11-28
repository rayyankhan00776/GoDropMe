import 'package:get/get.dart';
import 'package:godropme/features/DriverSide/driverChat/models/chat_message.dart';

class DriverConversationController extends GetxController {
  final String chatRoomId;
  final String currentDriverId;
  final messages = <DriverChatMessage>[].obs;

  DriverConversationController(this.chatRoomId, {this.currentDriverId = 'driver_1'});

  @override
  void onInit() {
    super.onInit();
    messages.assignAll(DriverChatMessage.demoFor(chatRoomId));
  }

  void send(String text) {
    if (text.trim().isEmpty) return;
    messages.add(
      DriverChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        chatRoomId: chatRoomId,
        senderId: currentDriverId,
        senderRole: 'driver',
        text: text.trim(),
        time: DateTime.now(),
      ),
    );
  }
}
