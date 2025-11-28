import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:godropme/models/school.dart';
import 'package:godropme/utils/app_assets.dart';

/// Centralized loader for schools data.
/// 
/// This is the single source of truth for all school data in the app.
/// Both parent-side and driver-side features should use this loader
/// to get the list of schools.
/// 
/// Data source: assets/json/schools.json
class SchoolsLoader {
  static List<School>? _cachedSchools;

  /// Load schools from JSON (with caching)
  static Future<List<School>> load() async {
    // Return cached if available
    if (_cachedSchools != null) {
      return _cachedSchools!;
    }

    try {
      final jsonStr = await rootBundle.loadString(AppAssets.schoolsJson);
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      
      final schools = (data['schools'] as List)
          .map((e) => School.fromJson(e as Map<String, dynamic>))
          .toList();
      
      // Cache for future use
      _cachedSchools = schools;
      return schools;
    } catch (e) {
      // Log error in debug mode
      assert(() {
        // ignore: avoid_print
        print('SchoolsLoader error: $e');
        return true;
      }());
      return [];
    }
  }

  /// Get school by name
  static Future<School?> getByName(String name) async {
    final schools = await load();
    try {
      return schools.firstWhere((s) => s.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Get school names only (for dropdowns)
  static Future<List<String>> getSchoolNames() async {
    final schools = await load();
    return schools.map((s) => s.name).toList();
  }

  /// Clear cache (useful for hot reload during development)
  static void clearCache() {
    _cachedSchools = null;
  }
}
