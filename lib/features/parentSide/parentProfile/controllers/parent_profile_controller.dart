import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/models/parent_profile.dart';

class ParentProfileController extends GetxController {
  final Rx<ParentProfile?> profile = Rx<ParentProfile?>(null);
  final RxString profileImagePath = ''.obs;
  final RxBool isLoading = false.obs;
  
  final ImagePicker _picker = ImagePicker();
  
  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }
  
  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final loadedProfile = await ParentProfile.loadFromLocal();
      profile.value = loadedProfile;
      
      // Load profile image path
      final imagePath = await LocalStorage.getString(StorageKeys.parentProfileImage);
      if (imagePath != null && imagePath.isNotEmpty) {
        profileImagePath.value = imagePath;
      }
    } finally {
      isLoading.value = false;
    }
  }
  
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
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
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
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take photo. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  Future<void> updateName(String name) async {
    await LocalStorage.setString(StorageKeys.parentName, name);
    await loadProfile();
  }
  
  Future<void> updatePhone(String phone) async {
    await LocalStorage.setString(StorageKeys.parentPhone, phone);
    await loadProfile();
  }
  
  Future<void> updateEmail(String email) async {
    await LocalStorage.setString(StorageKeys.parentEmail, email);
    await loadProfile();
  }
  
  /// Check if profile image file exists
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
