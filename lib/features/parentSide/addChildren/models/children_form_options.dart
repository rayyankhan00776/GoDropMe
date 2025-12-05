import 'package:godropme/models/school.dart';

/// Options for child registration form.
/// Data should be loaded from JSON via ChildrenFormOptionsLoader.
class ChildrenFormOptions {
  final List<String> ages;
  final List<String> genders;
  final List<School> schools;
  final List<String> relations;

  const ChildrenFormOptions({
    required this.ages,
    required this.genders,
    required this.schools,
    required this.relations,
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
  
  /// Get school ID by name (for saving to database)
  String? getSchoolId(String name) {
    return getSchoolByName(name)?.id;
  }

  /// Empty fallback - should only be used if loading fails
  static const ChildrenFormOptions empty = ChildrenFormOptions(
    ages: [],
    genders: [],
    schools: [],
    relations: [],
  );

  /// Check if options are loaded
  bool get isLoaded => ages.isNotEmpty && genders.isNotEmpty;
}
