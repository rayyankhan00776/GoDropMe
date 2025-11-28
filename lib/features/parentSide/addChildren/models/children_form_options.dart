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

  /// Get school by name
  School? getSchoolByName(String name) {
    try {
      return schools.firstWhere((s) => s.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Empty fallback - should only be used if JSON fails to load
  /// Actual data comes from assets/json/children_details.json
  static const ChildrenFormOptions empty = ChildrenFormOptions(
    ages: [],
    genders: [],
    schools: [],
    relations: [],
  );

  /// Check if options are loaded
  bool get isLoaded => ages.isNotEmpty && genders.isNotEmpty;
}
