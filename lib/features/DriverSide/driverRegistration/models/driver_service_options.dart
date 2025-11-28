import 'package:godropme/models/school.dart';

/// Options for driver service registration form.
/// Data should be loaded from JSON via DriverServiceOptionsLoader.
class DriverServiceOptions {
  final List<School> schools;
  /// Service categories: Male, Female, Both
  final List<String> serviceCategories;

  const DriverServiceOptions({
    required this.schools,
    required this.serviceCategories,
  });

  /// Helper to get school names for UI dropdowns
  List<String> get schoolNames => schools.map((s) => s.name).toList();

  /// Get school by name
  School? getSchoolByName(String name) {
    try {
      return schools.firstWhere((s) => s.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Empty fallback - should only be used if JSON fails to load
  /// Actual data comes from assets/json/schools.json
  static const DriverServiceOptions empty = DriverServiceOptions(
    schools: [],
    serviceCategories: ['Male', 'Female', 'Both'],
  );

  /// Check if options are loaded
  bool get isLoaded => schools.isNotEmpty;
}
