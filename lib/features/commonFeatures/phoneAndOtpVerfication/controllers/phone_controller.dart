import 'package:get/get.dart';

class PhoneController extends GetxController {
  // TODO: add phone verification logic (send code, validate number)
  final phone = ''.obs;

  void setPhone(String value) => phone.value = value;

  // Placeholder for sending OTP
  Future<void> sendOtp() async {
    // Implement backend call later
  }
}
