import 'package:flutter/material.dart';

/// Helper methods for deriving formatted display values from a child data map.
String childTitle(Map<String, dynamic> data) {
  final raw = data['name']?.toString() ?? '';
  return raw.isNotEmpty ? raw : 'Child';
}

String childInitial(String title) =>
    title.isNotEmpty ? title[0].toUpperCase() : 'C';

String childGender(Map<String, dynamic> data) =>
    (data['gender']?.toString() ?? '').trim();

String childAge(Map<String, dynamic> data) =>
    (data['age']?.toString() ?? '').trim();

String formattedAge(String age) => age.isEmpty ? '' : '${age}y';

/// Simple pill used for gender & age badges.
class ChildInfoPill extends StatelessWidget {
  final String text;
  const ChildInfoPill({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(
          0xFF0066FF,
        ).withValues(alpha: 0.12), // matches AppColors.primary with opacity
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0066FF),
        ),
      ),
    );
  }
}
