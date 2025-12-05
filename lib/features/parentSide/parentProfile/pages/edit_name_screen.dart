import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/features/parentSide/parentProfile/controllers/parent_profile_controller.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';

class EditNameScreen extends StatefulWidget {
  const EditNameScreen({super.key});

  @override
  State<EditNameScreen> createState() => _EditNameScreenState();
}

class _EditNameScreenState extends State<EditNameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _isValid = false.obs;
  final _isSyncing = false.obs;

  @override
  void initState() {
    super.initState();
    _loadCurrentName();
    _nameController.addListener(_validateName);
  }

  Future<void> _loadCurrentName() async {
    final name = await LocalStorage.getString(StorageKeys.parentName);
    if (name != null && name.isNotEmpty) {
      _nameController.text = name;
      _validateName();
    }
  }

  void _validateName() {
    final name = _nameController.text.trim();
    _isValid.value = name.length >= 2;
  }

  Future<void> _saveName() async {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      
      _isSyncing.value = true;
      
      try {
        // Use ParentProfileController to update and sync with Appwrite
        final controller = Get.find<ParentProfileController>();
        await controller.updateName(name);
      } catch (e) {
        debugPrint('⚠️ Error updating name: $e');
        // Fallback: save locally only
        // await LocalStorage.setString(StorageKeys.parentName, name);
      } finally {
        _isSyncing.value = false;
      }
      
      // Hide keyboard before navigating back to avoid overflow
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      await Future.delayed(const Duration(milliseconds: 100));
      Get.back(result: name);
      Get.snackbar(
        'Success',
        'Name updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary.withValues(alpha: 0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black, size: 28),
          onPressed: () {
            FocusScope.of(context).unfocus();
            Get.back();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.scaleClamped(context, 16, 12, 24),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Name',
                        style: AppTypography.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your full name as you\'d like it to appear',
                        style: AppTypography.helperSmall.copyWith(
                          color: AppColors.darkGray,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _NameInputField(
                        controller: _nameController,
                        onClear: () {
                          _nameController.clear();
                          _validateName();
                        },
                      ),
                      const SizedBox(height: 8),
                      Obx(() => _isValid.value
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                'Name must be at least 2 characters',
                                style: AppTypography.helperSmall.copyWith(
                                  color: AppColors.darkGray,
                                ),
                              ),
                            )),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: Responsive.scaleClamped(context, 64, 48, 80),
                  child: Obx(() => ElevatedButton(
                        onPressed: _isValid.value ? _saveName : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Save',
                          style: AppTypography.onboardButton,
                        ),
                      )),
                ),
                SizedBox(height: Responsive.scaleClamped(context, 24, 16, 32)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NameInputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onClear;

  const _NameInputField({
    required this.controller,
    required this.onClear,
  });

  @override
  State<_NameInputField> createState() => _NameInputFieldState();
}

class _NameInputFieldState extends State<_NameInputField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final baseHeight = Responsive.scaleClamped(context, 66, 48, 72);
    return Container(
      height: baseHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              style: AppTypography.optionLineSecondary.copyWith(
                color: AppColors.black,
              ),
              cursorHeight:
                  (AppTypography.optionLineSecondary.fontSize ?? 16) * 1.2,
              cursorWidth: 2,
              textAlignVertical: TextAlignVertical.center,
              minLines: 1,
              maxLines: 1,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                isCollapsed: true,
                hintText: 'Full Name',
                hintStyle: AppTypography.optionTerms.copyWith(
                  color: AppColors.darkGray,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
            ),
          ),
          if (widget.controller.text.isNotEmpty)
            IconButton(
              tooltip: 'Clear name',
              splashRadius: 20,
              icon: const Icon(
                Icons.close,
                size: 22,
                color: AppColors.darkGray,
              ),
              onPressed: widget.onClear,
            ),
        ],
      ),
    );
  }
}
