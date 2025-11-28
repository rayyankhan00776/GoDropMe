import 'package:godropme/models/value_objects.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';

/// Parent profile model matching Appwrite `parents` collection.
class ParentProfile {
  final String? id; // parents.$id
  final String? userId; // Reference to auth user $id
  final String fullName;
  final PhoneNumber phone;
  final String? email;
  final String? profilePhotoFileId; // Storage file ID (for Appwrite)
  final String? profilePhotoPath; // Local file path (before upload)

  const ParentProfile({
    this.id,
    this.userId,
    required this.fullName,
    required this.phone,
    this.email,
    this.profilePhotoFileId,
    this.profilePhotoPath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'fullName': fullName,
    'phone': phone.e164, // Store as E.164 string for Appwrite
    'email': email,
    'profilePhotoFileId': profilePhotoFileId,
  };

  /// Convert to Appwrite document format
  Map<String, dynamic> toAppwriteJson() => {
    'userId': userId,
    'fullName': fullName,
    'phone': phone.e164,
    'email': email,
    'profilePhotoFileId': profilePhotoFileId,
  };

  factory ParentProfile.fromJson(Map<String, dynamic> json) {
    // Parse phone from various formats
    PhoneNumber parsedPhone;
    if (json['phone'] is Map<String, dynamic>) {
      parsedPhone = PhoneNumber.fromJson(json['phone'] as Map<String, dynamic>);
    } else {
      final phoneStr = (json['phone'] ?? '').toString();
      // Strip +92 prefix if present
      final national = phoneStr.startsWith('+92') 
          ? phoneStr.substring(3) 
          : phoneStr;
      parsedPhone = PhoneNumber(national: national);
    }
    
    return ParentProfile(
      id: json['\$id']?.toString() ?? json['id']?.toString(),
      userId: json['userId']?.toString(),
      fullName: (json['fullName'] ?? '').toString(),
      phone: parsedPhone,
      email: json['email']?.toString(),
      profilePhotoFileId: json['profilePhotoFileId']?.toString(),
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
      phone: PhoneNumber(national: phoneDigits),
      email: email,
    );
  }
}
