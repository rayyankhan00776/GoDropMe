import 'package:get/get.dart';
import 'package:godropme/features/commonFeatures/EmailAndOtpVerfication/controllers/otp_controller.dart';
import 'package:godropme/features/commonFeatures/EmailAndOtpVerfication/controllers/email_controller.dart';

class OtpBinding extends Bindings {
  @override
  void dependencies() {
    // Provide OTP + Email controllers. EmailController (formerly PhoneController)
    // kept with fenix for recreation after navigation pop.
    Get.lazyPut<OtpController>(() => OtpController());
    Get.lazyPut<EmailController>(() => EmailController(), fenix: true);
  }
}
