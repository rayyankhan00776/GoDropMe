import 'package:get/get.dart';
import 'package:godropme/features/parentSide/parentHome/controllers/parent_map_controller.dart';

class ParentMapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentMapController>(() => ParentMapController());
  }
}
