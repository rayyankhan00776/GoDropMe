import 'package:get/get.dart';

/// Shared controller for driver drawer state across all driver pages
/// This ensures drawer closes when navigating between bottom nav tabs
class DriverDrawerController extends GetxController {
  static DriverDrawerController get instance => Get.find<DriverDrawerController>();
  
  final RxBool isOpen = false.obs;
  
  void toggle() => isOpen.value = !isOpen.value;
  
  void open() => isOpen.value = true;
  
  void close() => isOpen.value = false;
  
  /// Call this when bottom nav tab changes to close any open drawer
  void onTabChange() => close();
}
