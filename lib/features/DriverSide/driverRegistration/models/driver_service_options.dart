import 'package:godropme/models/school.dart';

/// Options for driver service registration form.
/// Data should be loaded via DriverServiceOptionsLoader.
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

  /// Get school by name (for UI selection)
  School? getSchoolByName(String name) {
    try {
      return schools.firstWhere((s) => s.name == name);
    } catch (_) {
      return null;
    }
  }
  
  /// Get school by ID
  School? getSchoolById(String id) {
    try {
      return schools.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
  
  /// Get multiple schools by their IDs
  List<School> getSchoolsByIds(List<String> ids) {
    return schools.where((s) => ids.contains(s.id)).toList();
  }

  /// Empty fallback - should only be used if loading fails
  static const DriverServiceOptions empty = DriverServiceOptions(
    schools: [],
    serviceCategories: ['Male', 'Female', 'Both'],
  );

  /// Check if options are loaded
  bool get isLoaded => schools.isNotEmpty;
}
