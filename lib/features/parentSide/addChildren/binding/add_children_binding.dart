import 'package:get/get.dart';
import 'package:godropme/features/parentSide/addChildren/controllers/add_children_controller.dart';

class AddChildrenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddChildrenController>(() => AddChildrenController());
  }
}
