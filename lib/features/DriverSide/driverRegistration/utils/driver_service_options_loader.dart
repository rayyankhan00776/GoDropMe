import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:godropme/features/DriverSide/driverRegistration/models/driver_service_options.dart';
import 'package:godropme/utils/schools_loader.dart';
import 'package:godropme/utils/app_assets.dart';

/// Loads driver service options from:
/// - assets/json/schools.json (schools - via SchoolsLoader)
/// - assets/json/driver_details.json (serviceCategories)
class DriverServiceOptionsLoader {
  static Future<DriverServiceOptions> load() async {
    try {
      // Load schools from centralized schools.json
      final schools = await SchoolsLoader.load();
      
      // Load service categories from driver_details.json
      final jsonStr = await rootBundle.loadString(AppAssets.driverDetailsJson);
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final categories = (data['serviceCategories'] as List?)
          ?.map((e) => e.toString())
          .toList() ?? ['Male', 'Female', 'Both'];

      return DriverServiceOptions(
        schools: schools,
        serviceCategories: categories,
      );
    } catch (e) {
      // Log error in debug mode
      assert(() {
        // ignore: avoid_print
        print('DriverServiceOptionsLoader error: $e');
        return true;
      }());
      return DriverServiceOptions.empty;
    }
  }
}
