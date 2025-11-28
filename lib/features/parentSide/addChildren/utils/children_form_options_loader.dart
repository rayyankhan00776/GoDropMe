import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:godropme/features/parentSide/addChildren/models/children_form_options.dart';
import 'package:godropme/utils/app_assets.dart';
import 'package:godropme/utils/schools_loader.dart';

/// Loads child form options from:
/// - assets/json/children_details.json (age, gender, relations)
/// - assets/json/schools.json (schools - via SchoolsLoader)
class ChildrenFormOptionsLoader {
  static Future<ChildrenFormOptions> load() async {
    try {
      // Load form options
      final jsonStr = await rootBundle.loadString(
        AppAssets.childrenDetailsJson,
      );
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final form = data['childFormOptions'] as Map<String, dynamic>;
      
      // Parse ages (convert int to string for dropdown)
      final ages = (form['age'] as List).map((e) => e.toString()).toList();
      
      // Parse genders
      final genders = (form['gender'] as List).map((e) => e.toString()).toList();
      
      // Load schools from centralized schools.json
      final schools = await SchoolsLoader.load();
      
      // Parse relationships (filter out 'Other' per requirement)
      final relations = (form['relationshipToChild'] as List)
          .map((e) => e.toString())
          .where((e) => e.trim().toLowerCase() != 'other')
          .toList();

      return ChildrenFormOptions(
        ages: ages,
        genders: genders,
        schools: schools,
        relations: relations,
      );
    } catch (e) {
      // Log error in debug mode
      assert(() {
        // ignore: avoid_print
        print('ChildrenFormOptionsLoader error: $e');
        return true;
      }());
      return ChildrenFormOptions.empty;
    }
  }
}
