import 'package:get/get.dart';
import 'package:godropme/features/commonFeatures/phoneAndOtpVerfication/controllers/phone_controller.dart';

class PhoneBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PhoneController>(() => PhoneController());
  }
}
