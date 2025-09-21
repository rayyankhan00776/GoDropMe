import 'package:get/get.dart';
import 'package:godropme/features/Reg-option/controllers/option_controller.dart';

class OptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OptionController>(() => OptionController());
  }
}
