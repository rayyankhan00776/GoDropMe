import 'package:godropme/models/value_objects.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';

class ParentProfile {
  final String fullName;
  final PhoneNumber phone;

  const ParentProfile({required this.fullName, required this.phone});

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'phone': phone.toJson(),
  };

  factory ParentProfile.fromJson(Map<String, dynamic> json) => ParentProfile(
    fullName: (json['fullName'] ?? '').toString(),
    phone: json['phone'] is Map<String, dynamic>
        ? PhoneNumber.fromJson(json['phone'] as Map<String, dynamic>)
        : PhoneNumber(national: (json['phone'] ?? '').toString()),
  );

  /// Read-only convenience: loads a ParentProfile from the current
  /// SharedPreferences values without changing any storage keys or shapes.
  static Future<ParentProfile> loadFromLocal() async {
    final name = await LocalStorage.getString(StorageKeys.parentName) ?? '';
    final phoneDigits =
        await LocalStorage.getString(StorageKeys.parentPhone) ?? '';
    return ParentProfile(
      fullName: name,
      phone: PhoneNumber(national: phoneDigits),
    );
  }
}
