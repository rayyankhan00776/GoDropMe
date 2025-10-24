import 'package:get/get.dart';

class PhoneController extends GetxController {
  // TODO: add phone verification logic (send code, validate number)
  final phone = ''.obs;
  final submitted = false.obs;

  void setPhone(String value) => phone.value = value;
  void markSubmitted() => submitted.value = true;

  // Placeholder for sending OTP
  Future<void> sendOtp() async {
    // Implement backend call later
  }
}
