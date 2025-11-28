String fullNameFromPersonalInfo(
  Map<String, dynamic>? personalInfo,
  String? fallback,
) {
  final f = (personalInfo?['firstName'] ?? '').toString().trim();
  final s = (personalInfo?['surName'] ?? '').toString().trim();
  final l = (personalInfo?['lastName'] ?? '').toString().trim();
  final combined = [f, s, l].where((e) => e.isNotEmpty).join(' ');
  if (combined.isNotEmpty) return combined;
  return (fallback ?? '').trim();
}

String maskCnic(String? cnic) {
  if (cnic == null || cnic.trim().isEmpty) return 'Not set';
  final digits = cnic.replaceAll(RegExp(r'\D'), '');
  if (digits.length <= 5) return '*****$digits';
  return '*****${digits.substring(digits.length - 5)}';
}

String joinSchools(dynamic schools) {
  if (schools is List) {
    final names = <String>[];
    for (final item in schools) {
      if (item is String && item.trim().isNotEmpty) {
        // New format: flat string array (Appwrite compatible)
        names.add(item.trim());
      } else if (item is Map<String, dynamic>) {
        // Legacy format: list of school objects with 'name' key
        final name = item['name']?.toString().trim() ?? '';
        if (name.isNotEmpty) names.add(name);
      }
    }
    if (names.isEmpty) return 'Not set';
    return names.join(', ');
  }
  return 'Not set';
}
