import 'package:get/get.dart';
import 'package:godropme/features/parentSide/report/controllers/parent_report_controller.dart';

class ParentReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentReportController>(() => ParentReportController());
  }
}
