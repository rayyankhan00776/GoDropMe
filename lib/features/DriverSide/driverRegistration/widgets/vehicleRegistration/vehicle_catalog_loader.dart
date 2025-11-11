import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:godropme/utils/app_assets.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';

/// Data object representing loaded vehicle catalog + derived seat capacity max.
class VehicleCatalog {
  final List<String> brands;
  final Map<String, List<String>> modelsByBrand;
  final List<String> colors;
  final int seatMax;
  VehicleCatalog({
    required this.brands,
    required this.modelsByBrand,
    required this.colors,
    required this.seatMax,
  });
}

/// Loads vehicle catalog based on saved selection (car vs rickshaw) and
/// derives seat capacity cap. Mirrors original logic exactly.
Future<VehicleCatalog> loadVehicleCatalog() async {
  final selection = (await LocalStorage.getString(
    StorageKeys.vehicleSelection,
  ))?.trim().toLowerCase();
  final assetPath = (selection == 'rikshaw' || selection == 'rickshaw')
      ? AppAssets.rikshawcarJsonData
      : AppAssets.carcarJsonData;
  final jsonStr = await rootBundle.loadString(assetPath);
  final data = json.decode(jsonStr) as Map<String, dynamic>;
  final brands = (data['vehicleBrands'] as List<dynamic>).cast<String>();
  final models = (data['vehicleModels'] as Map<String, dynamic>).map(
    (k, v) => MapEntry(k, (v as List<dynamic>).cast<String>()),
  );
  final colors = (data['vehicleColors'] as List<dynamic>).cast<String>();

  int cap;
  final sel = selection;
  if (sel == 'car') {
    cap = 9;
  } else if (sel == 'rikshaw' || sel == 'rickshaw') {
    cap = 4;
  } else {
    cap = 12;
  }

  return VehicleCatalog(
    brands: brands,
    modelsByBrand: models,
    colors: colors,
    seatMax: cap,
  );
}
