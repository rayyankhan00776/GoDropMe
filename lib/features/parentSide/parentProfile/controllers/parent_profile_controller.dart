import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/features/parentSide/parentProfile/models/parent_profile.dart';
import 'package:godropme/services/appwrite/parent_service.dart';

class ParentProfileController extends GetxController {
  final Rx<ParentProfile?> profile = Rx<ParentProfile?>(null);
  final RxString profileImagePath = ''.obs;
  final RxString profileImageUrl = ''.obs; // Appwrite storage URL
  final RxBool isLoading = false.obs;
  final RxBool isSyncing = false.obs;
  final RxString errorMessage = ''.obs;
  
  /// Parent document ID from Appwrite
  String? _parentId;
  String? get parentId => _parentId;
  
  /// Profile photo URL from Appwrite storage
  String? _photoUrl;
  String? get photoUrl => _photoUrl;
  
  final ImagePicker _picker = ImagePicker();
  
  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }
  
  /// Load profile from Appwrite backend, fallback to local storage
  Future<void> loadProfile() async {
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      // Try to load from Appwrite first
      final result = await ParentService.instance.getParent();
      
      if (result.success && result.parent != null) {
        profile.value = result.parent;
        _parentId = result.parent!.id;
        _photoUrl = result.parent!.profilePhotoUrl;
        
        // Set profile photo URL directly from Appwrite
        if (_photoUrl != null && _photoUrl!.isNotEmpty) {
          profileImageUrl.value = _photoUrl!;
          debugPrint('📷 Profile photo URL: ${profileImageUrl.value}');
        }
        
        // Sync to local storage for offline access
        await LocalStorage.setString(StorageKeys.parentName, result.parent!.fullName);
        if (result.parent!.phone != null) {
          await LocalStorage.setString(StorageKeys.parentPhone, result.parent!.phone!.national);
        }
        if (result.parent!.email != null) {
          await LocalStorage.setString(StorageKeys.parentEmail, result.parent!.email!);
        }
        
        debugPrint('✅ Loaded parent profile from Appwrite: $_parentId');
        return;
      }
      
      // Fallback: Load from local storage (offline mode)
      final loadedProfile = await ParentProfile.loadFromLocal();
      profile.value = loadedProfile;
      
      // Load local profile image path for offline
      final imagePath = await LocalStorage.getString(StorageKeys.parentProfileImage);
      if (imagePath != null && imagePath.isNotEmpty) {
        profileImagePath.value = imagePath;
      }
      debugPrint('📱 Loaded parent profile from local storage');
      
    } catch (e) {
      debugPrint('❌ Error loading profile: $e');
      // Fallback to local storage on error
      final loadedProfile = await ParentProfile.loadFromLocal();
      profile.value = loadedProfile;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Pick image and upload to Appwrite
  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        profileImagePath.value = image.path;
        await LocalStorage.setString(StorageKeys.parentProfileImage, image.path);
        
        // Sync to Appwrite if we have a parent ID
        if (_parentId != null) {
          await _uploadProfilePhoto(File(image.path));
        }
      }
    } catch (e) {
      debugPrint('❌ Pick image error: $e');
      Get.snackbar(
        'Error',
        'Failed to pick image. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  /// Take photo and upload to Appwrite
  Future<void> takeProfilePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        profileImagePath.value = image.path;
        await LocalStorage.setString(StorageKeys.parentProfileImage, image.path);
        
        // Sync to Appwrite if we have a parent ID
        if (_parentId != null) {
          await _uploadProfilePhoto(File(image.path));
        }
      }
    } catch (e) {
      debugPrint('❌ Take photo error: $e');
      Get.snackbar(
        'Error',
        'Failed to take photo. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  /// Upload profile photo to Appwrite and update parent document
  Future<void> _uploadProfilePhoto(File photo) async {
    if (_parentId == null) return;
    
    isSyncing.value = true;
    try {
      final result = await ParentService.instance.updateProfilePhoto(
        parentId: _parentId!,
        photo: photo,
        oldPhotoUrl: _photoUrl,
      );
      
      if (result.success && result.parent != null) {
        _photoUrl = result.parent!.profilePhotoUrl;
        if (_photoUrl != null && _photoUrl!.isNotEmpty) {
          profileImageUrl.value = _photoUrl!;
        }
        debugPrint('✅ Profile photo uploaded to Appwrite');
      } else {
        debugPrint('⚠️ Photo upload failed: ${result.message}');
      }
    } catch (e) {
      debugPrint('❌ Upload photo error: $e');
    } finally {
      isSyncing.value = false;
    }
  }
  
  Future<void> updateName(String name) async {
    await LocalStorage.setString(StorageKeys.parentName, name);
    
    // Sync to Appwrite
    if (_parentId != null) {
      isSyncing.value = true;
      final result = await ParentService.instance.updateParent(
        parentId: _parentId!,
        fullName: name,
      );
      isSyncing.value = false;
      if (!result.success) {
        debugPrint('⚠️ Name update failed: ${result.message}');
      }
    }
    
    await loadProfile();
  }
  
  Future<void> updatePhone(String phone) async {
    await LocalStorage.setString(StorageKeys.parentPhone, phone);
    
    // Sync to Appwrite
    if (_parentId != null) {
      isSyncing.value = true;
      final result = await ParentService.instance.updateParent(
        parentId: _parentId!,
        phone: phone.isEmpty ? null : phone,
      );
      isSyncing.value = false;
      if (!result.success) {
        debugPrint('⚠️ Phone update failed: ${result.message}');
      }
    }
    
    await loadProfile();
  }
  
  Future<void> updateEmail(String email) async {
    await LocalStorage.setString(StorageKeys.parentEmail, email);
    
    // Sync to Appwrite
    if (_parentId != null) {
      isSyncing.value = true;
      final result = await ParentService.instance.updateParent(
        parentId: _parentId!,
        email: email,
      );
      isSyncing.value = false;
      if (!result.success) {
        debugPrint('⚠️ Email update failed: ${result.message}');
      }
    }
    
    await loadProfile();
  }
  
  /// Check if profile image is available (either from Appwrite URL or local file)
  bool get hasProfileImage {
    // Check Appwrite URL first
    if (profileImageUrl.value.isNotEmpty) return true;
    // Fallback to local file
    if (profileImagePath.value.isEmpty) return false;
    return File(profileImagePath.value).existsSync();
  }
  
  /// Get profile image file (local only - for fallback)
  File? get profileImageFile {
    if (profileImagePath.value.isEmpty) return null;
    final file = File(profileImagePath.value);
    return file.existsSync() ? file : null;
  }
  
  /// Get the best available image source (URL or local path)
  /// Returns null if no image is available
  String? get bestImageSource {
    if (profileImageUrl.value.isNotEmpty) return profileImageUrl.value;
    if (profileImagePath.value.isNotEmpty && File(profileImagePath.value).existsSync()) {
      return profileImagePath.value;
    }
    return null;
  }
  
  /// Check if the image source is a URL (vs local file)
  bool get isImageFromUrl => profileImageUrl.value.isNotEmpty;
}
