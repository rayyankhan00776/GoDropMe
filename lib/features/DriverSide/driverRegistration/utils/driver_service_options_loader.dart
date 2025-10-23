import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:godropme/features/driverSide/driverRegistration/models/driver_service_options.dart';
import 'package:godropme/utils/app_assets.dart';

class DriverServiceOptionsLoader {
  static Future<DriverServiceOptions> load() async {
    try {
      final jsonStr = await rootBundle.loadString(AppAssets.driverDetailsJson);
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final form = (data['serviceOptions'] as Map<String, dynamic>);
      final schools = (form['schoolNames'] as List)
          .map((e) => e.toString())
          .toList();
      final dutyTypes = (form['dutyTypes'] as List)
          .map((e) => e.toString())
          .toList();
      final operatingDays = (form['operatingDays'] as List)
          .map((e) => e.toString())
          .toList();
      final pickupRanges = (form['pickupRangeKmOptions'] as List)
          .map((e) => e.toString())
          .toList();
      return DriverServiceOptions(
        schools: schools,
        dutyTypes: dutyTypes,
        operatingDays: operatingDays,
        pickupRangeKmOptions: pickupRanges,
      );
    } catch (_) {
      return DriverServiceOptions.fallback();
    }
  }
}
