import 'package:get/get.dart';

/// Shared controller for parent drawer state
/// This ensures drawer closes properly when navigating
class ParentDrawerController extends GetxController {
  static ParentDrawerController get instance => Get.find<ParentDrawerController>();
  
  final RxBool isOpen = false.obs;
  
  void toggle() => isOpen.value = !isOpen.value;
  
  void open() => isOpen.value = true;
  
  void close() => isOpen.value = false;
}
