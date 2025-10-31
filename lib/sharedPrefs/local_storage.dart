import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Keys used for persisting driver onboarding data in SharedPreferences.
class StorageKeys {
  StorageKeys._();

  static const driverName = 'driver_name';
  static const vehicleSelection = 'vehicle_selection'; // e.g., Car/Rikshaw

  static const personalInfo = 'personal_info'; // JSON blob
  static const driverLicence = 'driver_licence'; // JSON blob
  static const driverIdentification = 'driver_identification'; // JSON blob
  static const vehicleRegistration = 'vehicle_registration'; // JSON blob
  static const driverServiceDetails = 'driver_service_details'; // JSON blob

  // Parent: children list stored as JSON array of child maps
  static const childrenList = 'children_list';
  // Parent: store parent name similar to driver name for parity
  static const parentName = 'parent_name';
  // Parent: phone number (national digits, e.g., 3XXXXXXXXX)
  static const parentPhone = 'parent_phone';
  // Driver: phone number (national digits, e.g., 3XXXXXXXXX)
  static const driverPhone = 'driver_phone';
}

/// A very small wrapper around SharedPreferences tailored for this app's
/// onboarding flow. Stores sections as JSON maps where needed.
class LocalStorage {
  LocalStorage._();

  static Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  // Primitive helpers
  static Future<void> setString(String key, String value) async {
    final p = await _prefs();
    await p.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final p = await _prefs();
    return p.getString(key);
  }

  static Future<void> remove(String key) async {
    final p = await _prefs();
    await p.remove(key);
  }

  // JSON section helpers
  static Future<void> setJson(String key, Map<String, dynamic> map) async {
    await setString(key, jsonEncode(map));
  }

  static Future<Map<String, dynamic>?> getJson(String key) async {
    final s = await getString(key);
    if (s == null) return null;
    try {
      final decoded = jsonDecode(s);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }

  // JSON list helpers
  static Future<void> setJsonList(
    String key,
    List<Map<String, dynamic>> list,
  ) async {
    // Write atomically by encoding first
    final payload = jsonEncode(list);
    await setString(key, payload);
  }

  /// Replace the entire JSON list atomically.
  static Future<void> replaceJsonList(
    String key,
    List<Map<String, dynamic>> list,
  ) async {
    await setJsonList(key, list);
  }

  static Future<List<Map<String, dynamic>>> getJsonList(String key) async {
    final s = await getString(key);
    if (s == null) return <Map<String, dynamic>>[];
    try {
      final decoded = jsonDecode(s);
      if (decoded is List) {
        return decoded
            .map((e) {
              if (e is Map) {
                // Ensure we get a proper Map<String, dynamic>
                return Map<String, dynamic>.from(
                  e.map((k, v) => MapEntry(k.toString(), v)),
                );
              }
              return <String, dynamic>{};
            })
            .where((m) => m.isNotEmpty)
            .toList();
      }
    } catch (_) {}
    return <Map<String, dynamic>>[];
  }

  /// Clear all onboarding-related keys. Used when the user explicitly cancels
  /// onboarding (tapping Close in the app bar) so that any in-progress
  /// cached data is removed.
  static Future<void> clearOnboardingData() async {
    final keys = [
      StorageKeys.driverName,
      StorageKeys.vehicleSelection,
      StorageKeys.personalInfo,
      StorageKeys.driverLicence,
      StorageKeys.driverIdentification,
      StorageKeys.vehicleRegistration,
      StorageKeys.driverServiceDetails,
    ];
    final p = await _prefs();
    for (final k in keys) {
      await p.remove(k);
    }
  }
}
