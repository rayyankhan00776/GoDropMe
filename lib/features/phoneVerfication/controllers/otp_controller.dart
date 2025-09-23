import 'package:get/get.dart';

class OtpController extends GetxController {
  // TODO: add OTP submission and verification logic
  final code = ''.obs;

  void setCode(String value) => code.value = value;

  Future<void> verifyOtp() async {
    // Implement backend verification later
  }
}
