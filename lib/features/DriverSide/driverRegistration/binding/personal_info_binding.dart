import 'package:get/get.dart';
import 'package:godropme/features/DriverSide/driverRegistration/controllers/personal_info_controller.dart';

class PersonalInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PersonalInfoController>(() => PersonalInfoController());
  }
}
