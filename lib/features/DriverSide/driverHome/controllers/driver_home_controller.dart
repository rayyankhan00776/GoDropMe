import 'package:get/get.dart';

class DriverHomeController extends GetxController {
  final isOnline = false.obs;

  void toggleOnline(bool v) => isOnline.value = v;
}
