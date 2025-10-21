import 'package:get/get.dart';

/// Empty controller for Parent Home/Map screen.
/// Add observables and actions here as backend/location features are integrated.
class ParentMapController extends GetxController {
  // Example placeholder state (can be expanded later)
  final isMapReady = false.obs;

  void setMapReady(bool v) => isMapReady.value = v;
}
