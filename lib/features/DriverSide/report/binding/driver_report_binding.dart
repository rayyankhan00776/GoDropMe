import 'package:get/get.dart';
import 'package:godropme/features/driverSide/report/controllers/driver_report_controller.dart';

class DriverReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverReportController>(() => DriverReportController());
  }
}
