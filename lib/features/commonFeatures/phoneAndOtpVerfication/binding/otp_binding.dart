import 'package:get/get.dart';
import 'package:godropme/features/commonFeatures/phoneAndOtpVerfication/controllers/otp_controller.dart';

class OtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpController>(() => OtpController());
  }
}
