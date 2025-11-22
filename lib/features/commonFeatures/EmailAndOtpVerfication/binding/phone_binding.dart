import 'package:get/get.dart';
import 'package:godropme/features/commonFeatures/EmailAndOtpVerfication/controllers/email_controller.dart';

class PhoneBinding extends Bindings {
  @override
  void dependencies() {
    // Instantiate EmailController (renamed from PhoneController) under existing binding.
    Get.lazyPut<EmailController>(() => EmailController());
  }
}
