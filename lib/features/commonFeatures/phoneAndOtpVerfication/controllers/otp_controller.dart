import 'package:get/get.dart';

class OtpController extends GetxController {
  // TODO: add OTP submission and verification logic
  final code = ''.obs;
  final digits = List.generate(6, (_) => '').obs;
  final allFilled = false.obs;

  void setCode(String value) => code.value = value;

  void setDigit(int index, String value) {
    if (index < 0 || index >= digits.length) return;
    digits[index] = value;
    // trigger recomputation
    allFilled.value = digits.every((d) => d.trim().length == 1);
    digits.refresh();
  }

  Future<void> verifyOtp() async {
    // Implement backend verification later
  }
}
