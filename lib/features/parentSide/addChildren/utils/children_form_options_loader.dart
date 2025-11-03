import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:godropme/features/parentSide/addChildren/models/children_form_options.dart';
import 'package:godropme/utils/app_assets.dart';

class ChildrenFormOptionsLoader {
  static Future<ChildrenFormOptions> load() async {
    try {
      final jsonStr = await rootBundle.loadString(
        AppAssets.childrenDetailsJson,
      );
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final form = (data['childFormOptions'] as Map<String, dynamic>);
      final ages = (form['age'] as List).map((e) => e.toString()).toList();
      final genders = (form['gender'] as List)
          .map((e) => e.toString())
          .toList();
      final schools = (form['schoolNames'] as List)
          .map((e) => e.toString())
          .toList();
      final relationsRaw = (form['relationshipToChild'] as List)
          .map((e) => e.toString())
          .toList();
      // Remove 'Other' from relationship options per requirement
      final relations = relationsRaw
          .where((e) => e.trim().toLowerCase() != 'other')
          .toList();
      return ChildrenFormOptions(
        ages: ages.isNotEmpty ? ages : ChildrenFormOptions.fallback().ages,
        genders: genders.isNotEmpty
            ? genders
            : ChildrenFormOptions.fallback().genders,
        schools: schools.isNotEmpty
            ? schools
            : ChildrenFormOptions.fallback().schools,
        relations: relations.isNotEmpty
            ? relations
            : ChildrenFormOptions.fallback().relations
                  .where((e) => e.trim().toLowerCase() != 'other')
                  .toList(),
      );
    } catch (_) {
      return ChildrenFormOptions.fallback();
    }
  }
}
