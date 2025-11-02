import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/features/driverSide/driverRegistration/models/vehicle_selection.dart';

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

  Future<void> saveSelection() async {
    await LocalStorage.setString(
      StorageKeys.vehicleSelection,
      selected.value ?? '',
    );
  }

  Future<void> loadSelection() async {
    final v = await LocalStorage.getString(StorageKeys.vehicleSelection);
    if (v != null && v.isNotEmpty) selected.value = v;
  }

  /// Typed view over the current selection. Storage remains a raw string.
  VehicleSelection? get model =>
      selected.value == null || selected.value!.isEmpty
      ? null
      : VehicleSelection(type: VehicleTypeCodec.parse(selected.value!));
}
