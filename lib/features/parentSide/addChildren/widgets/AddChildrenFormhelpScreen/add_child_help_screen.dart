// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/features/parentSide/addChildren/widgets/AddChildrenFormhelpScreen/add_child_form.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/common_widgets/custom_button.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/constants/button_dimensions.dart';
import 'package:godropme/features/parentSide/addChildren/controllers/add_children_controller.dart';

class AddChildHelpScreen extends StatefulWidget {
  const AddChildHelpScreen({super.key});

  @override
  State<AddChildHelpScreen> createState() => _AddChildHelpScreenState();
}

class _AddChildHelpScreenState extends State<AddChildHelpScreen> {
  // Use a typed GlobalKey so we can call submitForm safely.
  final GlobalKey<AddChildFormState> _formKey = GlobalKey<AddChildFormState>();
  bool _isSaving = false;
  
  // Edit mode properties
  Map<String, dynamic>? _editChildData;
  int? _editIndex;
  bool get _isEditMode => _editChildData != null;

  @override
  void initState() {
    super.initState();
    // Check for edit arguments
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      _editChildData = args['childData'] as Map<String, dynamic>?;
      _editIndex = args['index'] as int?;
    }
  }

  void _onSave(Map<String, dynamic> data) {
    debugPrint('Saved child: $data');
    // Sync to Appwrite and save locally
    if (_isEditMode) {
      _updateChildWithSync(data);
    } else {
      _saveChildWithSync(data);
    }
  }

  Future<void> _updateChildWithSync(Map<String, dynamic> data) async {
    if (!mounted || _editIndex == null) return;
    
    setState(() => _isSaving = true);
    
    try {
      final ctrl = Get.find<AddChildrenController>();
      
      // Get photo file if exists (and it's a new/changed photo)
      File? photoFile;
      final photoPath = data['photoPath']?.toString();
      if (photoPath != null && photoPath.isNotEmpty) {
        // Only use photo if it's different from the existing one
        final existingPhotoPath = _editChildData?['photoPath']?.toString();
        if (photoPath != existingPhotoPath) {
          final file = File(photoPath);
          if (file.existsSync()) {
            photoFile = file;
          }
        }
      }
      
      // Update in Appwrite
      final success = await ctrl.updateChildWithSync(_editIndex!, data, photo: photoFile);
      
      if (!mounted) return;
      
      if (success) {
        debugPrint('✅ Child updated in Appwrite successfully');
        Navigator.of(context).pop();
      } else {
        // Show error but still update locally as fallback
        await ctrl.updateChild(_editIndex!, data);
        debugPrint('⚠️ Appwrite update failed, saved locally: ${ctrl.errorMessage.value}');
        
        Get.snackbar(
          'Saved Offline',
          'Changes saved locally. Will sync when online.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.warning,
          colorText: AppColors.black,
          duration: const Duration(seconds: 3),
        );
        
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('❌ Update child error: $e');
      
      // Fallback to local update
      final ctrl = Get.find<AddChildrenController>();
      await ctrl.updateChild(_editIndex!, data);
      
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _saveChildWithSync(Map<String, dynamic> data) async {
    if (!mounted) return;
    
    setState(() => _isSaving = true);
    
    try {
      final ctrl = Get.find<AddChildrenController>();
      
      // Get photo file if exists
      File? photoFile;
      final photoPath = data['photoPath']?.toString();
      if (photoPath != null && photoPath.isNotEmpty) {
        final file = File(photoPath);
        if (file.existsSync()) {
          photoFile = file;
        }
      }
      
      // Sync to Appwrite (this also saves locally)
      final success = await ctrl.addChildWithSync(data, photo: photoFile);
      
      if (!mounted) return;
      
      if (success) {
        debugPrint('✅ Child synced to Appwrite successfully');
        Navigator.of(context).pop();
      } else {
        // Show error but still save locally as fallback
        await ctrl.addChild(data);
        debugPrint('⚠️ Appwrite sync failed, saved locally: ${ctrl.errorMessage.value}');
        
        Get.snackbar(
          'Saved Offline',
          'Child saved locally. Will sync when online.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.warning,
          colorText: AppColors.black,
          duration: const Duration(seconds: 3),
        );
        
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('❌ Save child error: $e');
      
      // Fallback to local save
      final ctrl = Get.find<AddChildrenController>();
      await ctrl.addChild(data);
      
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _handleSave() {
    if (_isSaving) return;
    
    // Trigger the form's submit using the typed key.
    final state = _formKey.currentState;
    if (state != null) {
      state.submitForm();
    } else {
      // No UI toast requested; silently ignore when form state is unavailable
      debugPrint('AddChildHelpScreen: form state unavailable, cannot submit');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          // Mirror driver-side screens horizontal/vertical padding
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button consistent with driver-side screens
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 28,
                    color: AppColors.black,
                  ),
                  splashRadius: 20,
                ),
              ),

              SizedBox(height: Responsive.scaleClamped(context, 8, 6, 12)),

              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  _isEditMode ? 'Edit Child' : AppStrings.addChildTitle,
                  style: AppTypography.optionHeading,
                ),
              ),

              SizedBox(height: Responsive.scaleClamped(context, 18, 12, 24)),

              // Provide the GlobalKey to the AddChildForm
              Expanded(
                child: AddChildForm(
                  key: _formKey, 
                  onSave: _onSave,
                  initialData: _editChildData,
                ),
              ),
            ],
          ),
        ),
      ),
      // Pin the save button to the bottom so it doesn't move with fields/dropdowns/map
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: CustomButton(
            text: _isSaving 
                ? (_isEditMode ? 'Updating...' : 'Saving...') 
                : (_isEditMode ? 'Update Child' : AppStrings.addChildSave),
            onTap: _isSaving ? null : _handleSave,
            height: Responsive.scaleClamped(context, 64, 48, 80),
            width: double.infinity,
            borderRadius: BorderRadius.circular(
              AppButtonDimensions.borderRadius,
            ),
            textColor: AppColors.white,
            leading: _isSaving 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
