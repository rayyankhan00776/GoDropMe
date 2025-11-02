import 'package:get/get.dart';
import 'package:godropme/features/driverSide/driverChat/models/chat_contact.dart';

class DriverChatController extends GetxController {
  final contacts = <DriverChatContact>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Seed with accepted requests only (demo)
    contacts.assignAll(DriverChatContact.demoAccepted());
  }
}
