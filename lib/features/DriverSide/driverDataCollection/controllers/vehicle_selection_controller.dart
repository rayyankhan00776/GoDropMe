import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class VehicleSelectionController extends GetxController {
  // 'car' or 'rikshaw' or null
  final selected = RxnString();

  void select(String v) => selected.value = v;

  Future<void> submitSelection() async {
    // Dummy function for now; backend integration left for later.
    debugPrint(
      'VehicleSelectionController: selected vehicle = ${selected.value}',
    );
    await Future.delayed(const Duration(milliseconds: 300));
    // Return or navigate later; currently a placeholder
  }
}
