/// Options used by the Add Children form (assets/json/children_details.json).
class ChildFormOptions {
  final List<int> ages;
  final List<String> genders;
  final List<String> schoolNames;
  final List<String> relationshipToChild;

  const ChildFormOptions({
    required this.ages,
    required this.genders,
    required this.schoolNames,
    required this.relationshipToChild,
  });

  factory ChildFormOptions.fromJson(Map<String, dynamic> json) {
    final root = json['childFormOptions'] as Map? ?? const {};
    return ChildFormOptions(
      ages:
          (root['age'] as List?)?.map((e) => (e as num).toInt()).toList() ??
          const <int>[],
      genders:
          (root['gender'] as List?)?.map((e) => e.toString()).toList() ??
          const <String>[],
      schoolNames:
          (root['schoolNames'] as List?)?.map((e) => e.toString()).toList() ??
          const <String>[],
      relationshipToChild:
          (root['relationshipToChild'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[],
    );
  }

  Map<String, dynamic> toJson() => {
    'childFormOptions': {
      'age': ages,
      'gender': genders,
      'schoolNames': schoolNames,
      'relationshipToChild': relationshipToChild,
    },
  };
}
