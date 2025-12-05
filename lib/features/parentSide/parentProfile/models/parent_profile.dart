import 'package:godropme/models/value_objects.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';

/// Parent profile model matching Appwrite `parents` collection.
class ParentProfile {
  final String? id; // parents.$id
  final String? userId; // Reference to auth user $id
  final String fullName;
  final PhoneNumber? phone; // Optional phone number
  final String? email;
  final String? profilePhotoUrl; // Storage file URL (for Appwrite)
  final String? profilePhotoPath; // Local file path (before upload)

  const ParentProfile({
    this.id,
    this.userId,
    required this.fullName,
    this.phone, // Now optional
    this.email,
    this.profilePhotoUrl,
    this.profilePhotoPath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'fullName': fullName,
    'phone': phone?.e164, // Store as E.164 string for Appwrite (optional)
    'email': email,
    'profilePhotoUrl': profilePhotoUrl,
  };

  /// Convert to Appwrite document format
  Map<String, dynamic> toAppwriteJson() => {
    'userId': userId,
    'fullName': fullName,
    'phone': phone?.e164 ?? '',
    'email': email,
    'profilePhotoUrl': profilePhotoUrl,
  };

  factory ParentProfile.fromJson(Map<String, dynamic> json) {
    // Parse phone from various formats (now optional)
    PhoneNumber? parsedPhone;
    final phoneValue = json['phone'];
    if (phoneValue != null && phoneValue.toString().isNotEmpty) {
      if (phoneValue is Map<String, dynamic>) {
        parsedPhone = PhoneNumber.fromJson(phoneValue);
      } else {
        final phoneStr = phoneValue.toString();
        // Strip +92 prefix if present
        final national = phoneStr.startsWith('+92') 
            ? phoneStr.substring(3) 
            : phoneStr;
        if (national.isNotEmpty) {
          parsedPhone = PhoneNumber(national: national);
        }
      }
    }
    
    return ParentProfile(
      id: json['\$id']?.toString() ?? json['id']?.toString(),
      userId: json['userId']?.toString(),
      fullName: (json['fullName'] ?? '').toString(),
      phone: parsedPhone,
      email: json['email']?.toString(),
      profilePhotoUrl: json['profilePhotoUrl']?.toString(),
      profilePhotoPath: json['profilePhotoPath']?.toString(),
    );
  }

  /// Read-only convenience: loads a ParentProfile from the current
  /// SharedPreferences values without changing any storage keys or shapes.
  static Future<ParentProfile> loadFromLocal() async {
    final name = await LocalStorage.getString(StorageKeys.parentName) ?? '';
    final phoneDigits =
        await LocalStorage.getString(StorageKeys.parentPhone) ?? '';
    final email = await LocalStorage.getString(StorageKeys.parentEmail);
    return ParentProfile(
      fullName: name,
      phone: phoneDigits.isNotEmpty ? PhoneNumber(national: phoneDigits) : null,
      email: email,
    );
  }
}
