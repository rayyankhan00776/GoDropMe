import 'package:get/get.dart';
import 'package:godropme/features/commonFeatures/phoneAndOtpVerfication/controllers/otp_controller.dart';
import 'package:godropme/features/commonFeatures/phoneAndOtpVerfication/controllers/phone_controller.dart';

class OtpBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure OTP screen always has both controllers available.
    // PhoneController is required to display the number and actions, and using
    // fenix allows it to be recreated if the Phone screen was popped.
    Get.lazyPut<OtpController>(() => OtpController());
    Get.lazyPut<PhoneController>(() => PhoneController(), fenix: true);
  }
}
