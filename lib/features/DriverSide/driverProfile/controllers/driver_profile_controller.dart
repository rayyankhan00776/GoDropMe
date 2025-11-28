import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';

class DriverProfileController extends GetxController {
  final RxString profileImagePath = ''.obs;
  final RxString displayName = ''.obs;
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
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Extract full name from KYC personal info
  String _getFullNameFromPersonalInfo(Map<String, dynamic>? personalInfo) {
    if (personalInfo == null) return '';
    final f = (personalInfo['firstName'] ?? '').toString().trim();
    final s = (personalInfo['surName'] ?? '').toString().trim();
    final l = (personalInfo['lastName'] ?? '').toString().trim();
    return [f, s, l].where((e) => e.isNotEmpty).join(' ');
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
        await LocalStorage.setString(StorageKeys.driverProfileImage, image.path);
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
        await LocalStorage.setString(StorageKeys.driverProfileImage, image.path);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take photo. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
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
