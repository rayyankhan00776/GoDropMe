import 'package:get/get.dart';

/// Controller previously used for phone number collection now repurposed
/// for email capture. Renamed logically (class only) to reflect new input
/// semantics while keeping the same file and binding names to avoid
/// widespread route / binding churn.
class EmailController extends GetxController {
  final email = ''.obs; // captured user email
  final submitted = false.obs; // form submit attempt flag

  void setEmail(String value) => email.value = value;
  void markSubmitted() => submitted.value = true;

  // Placeholder for sending OTP (email-based token dispatch) – unchanged.
  Future<void> sendOtp() async {}
}
