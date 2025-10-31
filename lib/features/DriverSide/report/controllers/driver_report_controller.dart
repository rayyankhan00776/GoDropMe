import 'package:get/get.dart';

class DriverReportController extends GetxController {
  final isSending = false.obs;

  Future<bool> submitReport(String message) async {
    final text = message.trim();
    if (text.isEmpty) return false;
    isSending.value = true;
    try {
      // TODO: Integrate with backend (Appwrite or API)
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    } finally {
      isSending.value = false;
    }
  }
}
