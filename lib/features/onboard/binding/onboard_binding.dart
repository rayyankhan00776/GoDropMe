import 'package:get/get.dart';
import 'package:godropme/features/onboard/controllers/onboard_controller.dart';

class OnboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardController>(() => OnboardController());
  }
}
