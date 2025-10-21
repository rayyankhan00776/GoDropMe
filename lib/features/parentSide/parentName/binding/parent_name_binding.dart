import 'package:get/get.dart';
import 'package:godropme/features/parentSide/parentName/controller/parent_name_controller.dart';

class ParentNameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentNameController>(() => ParentNameController());
  }
}
