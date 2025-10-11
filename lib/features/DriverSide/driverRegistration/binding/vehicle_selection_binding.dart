import 'package:get/get.dart';
import 'package:godropme/features/driverSide/driverRegistration/controllers/vehicle_selection_controller.dart';

class VehicleSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VehicleSelectionController>(() => VehicleSelectionController());
  }
}
