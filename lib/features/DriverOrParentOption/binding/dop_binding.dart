import 'package:get/get.dart';
import 'package:godropme/features/DriverOrParentOption/controllers/dop_controller.dart';

class DopBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DopOptionController>(() => DopOptionController());
  }
}
