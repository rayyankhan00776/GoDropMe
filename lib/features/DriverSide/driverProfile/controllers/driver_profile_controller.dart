import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/services/appwrite/driver_service.dart';
import 'package:godropme/theme/colors.dart';

/// Driver Profile Controller - Manages driver profile data with Appwrite backend
/// 
/// Similar to ParentProfileController, this loads from Appwrite and syncs to local storage.
class DriverProfileController extends GetxController {
  // Profile data
  final RxMap<String, dynamic> profile = RxMap<String, dynamic>({});
  final RxString profileImagePath = ''.obs;
  final RxString profileImageUrl = ''.obs; // Appwrite storage URL
  final RxString displayName = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSyncing = false.obs;
  final RxString errorMessage = ''.obs;
  
  /// Driver document ID from Appwrite
  String? _driverId;
  String? get driverId => _driverId;
  
  /// Profile photo URL from Appwrite storage
  String? _photoUrl;
  String? get photoUrl => _photoUrl;
  
  final ImagePicker _picker = ImagePicker();
  
  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }
  
  /// Load driver profile from Appwrite backend, fallback to local storage
  Future<void> loadProfile() async {
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      // Try to load from Appwrite first
      final result = await DriverService.instance.getDriver();
      
      if (result.success && result.driver != null) {
        profile.value = Map<String, dynamic>.from(result.driver!);
        _driverId = result.driverId;
        _photoUrl = result.driver!['profilePhotoUrl'] as String?;
        
        // Set profile photo URL directly from Appwrite
        if (_photoUrl != null && _photoUrl!.isNotEmpty) {
          profileImageUrl.value = _photoUrl!;
          debugPrint('📷 Driver profile photo URL: ${profileImageUrl.value}');
        }
        
        // Set display name
        final fullName = (result.driver!['fullName'] ?? '').toString().trim();
        displayName.value = fullName;
        
        // Sync to local storage for offline access
        await _syncToLocalStorage(result.driver!);
        
        debugPrint('✅ Loaded driver profile from Appwrite: $_driverId');
        return;
      }
      
      // Fallback: Load from local storage (offline mode)
      await _loadFromLocalStorage();
      debugPrint('📱 Loaded driver profile from local storage');
      
    } catch (e) {
      debugPrint('❌ Error loading driver profile: $e');
      // Fallback to local storage on error
      await _loadFromLocalStorage();
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Sync Appwrite data to local storage for offline access
  Future<void> _syncToLocalStorage(Map<String, dynamic> driver) async {
    await LocalStorage.setString(StorageKeys.driverName, driver['fullName'] ?? '');
    await LocalStorage.setString(StorageKeys.driverPhone, driver['phone'] ?? '');
    await LocalStorage.setString(StorageKeys.driverEmail, driver['email'] ?? '');
    
    // Save personal info for profile screen
    final personalInfo = {
      'firstName': driver['firstName'],
      'surName': driver['surname'],
      'lastName': driver['lastName'],
    };
    await LocalStorage.setJson(StorageKeys.personalInfo, personalInfo);
    
    // Save licence info
    final licence = {
      'licenseNumber': driver['licenseNumber'],
      'licenseExpiry': driver['licenseExpiry'],
      'licensePhotoUrl': driver['licensePhotoUrl'],
      'selfieWithLicenseUrl': driver['selfieWithLicenseUrl'],
    };
    await LocalStorage.setJson(StorageKeys.driverLicence, licence);
    
    // Save identification info
    final identification = {
      'cnicNumber': driver['cnicNumber'],
      'cnicExpiry': driver['cnicExpiry'],
      'cnicFrontUrl': driver['cnicFrontUrl'],
      'cnicBackUrl': driver['cnicBackUrl'],
    };
    await LocalStorage.setJson(StorageKeys.driverIdentification, identification);
  }
  
  /// Load from local storage (offline fallback)
  Future<void> _loadFromLocalStorage() async {
    // Load profile image path
    final imagePath = await LocalStorage.getString(StorageKeys.driverProfileImage);
    if (imagePath != null && imagePath.isNotEmpty) {
      profileImagePath.value = imagePath;
    }
    
    // Load display name from KYC personal info (priority) or fallback to driverName
    final personalInfo = await LocalStorage.getJson(StorageKeys.personalInfo);
    final kycName = _getFullNameFromPersonalInfo(personalInfo);
    
    if (kycName.isNotEmpty) {
      displayName.value = kycName;
    } else {
      // Fallback to registration name
      final regName = await LocalStorage.getString(StorageKeys.driverName);
      displayName.value = regName ?? '';
    }
    
    // Build profile from local data
    final licence = await LocalStorage.getJson(StorageKeys.driverLicence);
    final identification = await LocalStorage.getJson(StorageKeys.driverIdentification);
    final email = await LocalStorage.getString(StorageKeys.driverEmail);
    final phone = await LocalStorage.getString(StorageKeys.driverPhone);
    
    profile.value = {
      'fullName': displayName.value,
      'email': email,
      'phone': phone,
      ...?personalInfo,
      ...?licence,
      ...?identification,
    };
  }
  
  /// Extract full name from KYC personal info
  String _getFullNameFromPersonalInfo(Map<String, dynamic>? personalInfo) {
    if (personalInfo == null) return '';
    final f = (personalInfo['firstName'] ?? '').toString().trim();
    final s = (personalInfo['surName'] ?? '').toString().trim();
    final l = (personalInfo['lastName'] ?? '').toString().trim();
    return [f, s, l].where((e) => e.isNotEmpty).join(' ');
  }
  
  /// Pick image from gallery and upload to Appwrite
  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        await _uploadProfilePhoto(File(image.path));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image. Please try again.',
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }
  
  /// Take photo with camera and upload to Appwrite
  Future<void> takeProfilePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        await _uploadProfilePhoto(File(image.path));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take photo. Please try again.',
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }
  
  /// Upload profile photo to Appwrite
  Future<void> _uploadProfilePhoto(File imageFile) async {
    if (_driverId == null) {
      // Offline mode: save locally only
      profileImagePath.value = imageFile.path;
      await LocalStorage.setString(StorageKeys.driverProfileImage, imageFile.path);
      Get.snackbar(
        'Saved Locally',
        'Photo saved. Will upload when online.',
        backgroundColor: AppColors.primary.withValues(alpha: 0.9),
        colorText: AppColors.white,
      );
      return;
    }
    
    isSyncing.value = true;
    
    try {
      final result = await DriverService.instance.updateProfilePhoto(
        driverId: _driverId!,
        profilePhoto: imageFile,
        existingPhotoUrl: _photoUrl,
      );
      
      if (result.success && result.driver != null) {
        _photoUrl = result.driver!['profilePhotoUrl'] as String?;
        if (_photoUrl != null) {
          profileImageUrl.value = _photoUrl!;
        }
        // Also save locally
        profileImagePath.value = imageFile.path;
        await LocalStorage.setString(StorageKeys.driverProfileImage, imageFile.path);
        
        Get.snackbar(
          'Success',
          'Profile photo updated',
          backgroundColor: AppColors.primary.withValues(alpha: 0.9),
          colorText: AppColors.white,
        );
      } else {
        throw Exception(result.message);
      }
    } catch (e) {
      debugPrint('❌ Upload profile photo error: $e');
      // Save locally as fallback
      profileImagePath.value = imageFile.path;
      await LocalStorage.setString(StorageKeys.driverProfileImage, imageFile.path);
      Get.snackbar(
        'Saved Locally',
        'Could not upload. Photo saved locally.',
        backgroundColor: Colors.amber.withValues(alpha: 0.9),
        colorText: Colors.black,
      );
    } finally {
      isSyncing.value = false;
    }
  }
  
  /// Check if has Appwrite profile photo
  bool get hasAppwritePhoto => profileImageUrl.value.isNotEmpty;
  
  /// Check if profile image file exists locally
  bool get hasProfileImage {
    if (profileImagePath.value.isEmpty) return false;
    return File(profileImagePath.value).existsSync();
  }
  
  /// Get profile image file
  File? get profileImageFile {
    if (!hasProfileImage) return null;
    return File(profileImagePath.value);
  }
}
