import 'package:get/get.dart';
import 'package:godropme/features/commonFeatures/registrationOption/controllers/option_controller.dart';

class OptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OptionController>(() => OptionController());
  }
}
