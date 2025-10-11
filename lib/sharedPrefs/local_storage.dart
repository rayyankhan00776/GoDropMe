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
    ];
    final p = await _prefs();
    for (final k in keys) {
      await p.remove(k);
    }
  }
}
