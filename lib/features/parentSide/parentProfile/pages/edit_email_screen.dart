import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/features/parentSide/parentProfile/controllers/parent_profile_controller.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';

class EditEmailScreen extends StatefulWidget {
  const EditEmailScreen({super.key});

  @override
  State<EditEmailScreen> createState() => _EditEmailScreenState();
}

class _EditEmailScreenState extends State<EditEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _isValid = false.obs;
  final _isSyncing = false.obs;

  @override
  void initState() {
    super.initState();
    _loadCurrentEmail();
    _emailController.addListener(_validateEmail);
  }

  Future<void> _loadCurrentEmail() async {
    final email = await LocalStorage.getString(StorageKeys.parentEmail);
    if (email != null && email.isNotEmpty) {
      _emailController.text = email;
      _validateEmail();
    }
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    _isValid.value = GetUtils.isEmail(email);
  }

  Future<void> _saveEmail() async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      
      _isSyncing.value = true;
      
      try {
        // Use ParentProfileController to update and sync with Appwrite
        final controller = Get.find<ParentProfileController>();
        await controller.updateEmail(email);
      } catch (e) {
        debugPrint('⚠️ Error updating email: $e');
        // Fallback: save locally only
        await LocalStorage.setString(StorageKeys.parentEmail, email);
      } finally {
        _isSyncing.value = false;
      }
      
      // Hide keyboard before navigating back
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      await Future.delayed(const Duration(milliseconds: 100));
      Get.back(result: email);
      Get.snackbar(
        'Success',
        'Email updated successfully',
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
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
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
                        'Edit Email',
                        style: AppTypography.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Update your email address',
                        style: AppTypography.helperSmall.copyWith(
                          color: AppColors.darkGray,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _EmailInputField(
                        controller: _emailController,
                        onClear: () {
                          _emailController.clear();
                          _validateEmail();
                        },
                      ),
                      const SizedBox(height: 8),
                      Obx(() => _isValid.value
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                'Enter a valid email address',
                                style: AppTypography.helperSmall.copyWith(
                                  color: AppColors.darkGray,
                                ),
                              ),
                            )),
                    ],
                  ),
                ),
                SizedBox(
                  height: Responsive.scaleClamped(context, 64, 48, 80),
                  width: double.infinity,
                  child: Obx(() => ElevatedButton(
                        onPressed: _isValid.value ? _saveEmail : null,
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

class _EmailInputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onClear;

  const _EmailInputField({
    required this.controller,
    required this.onClear,
  });

  @override
  State<_EmailInputField> createState() => _EmailInputFieldState();
}

class _EmailInputFieldState extends State<_EmailInputField> {
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
          const Icon(Icons.email_outlined, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              keyboardType: TextInputType.emailAddress,
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
                hintText: 'you@example.com',
                hintStyle: AppTypography.optionTerms.copyWith(
                  color: AppColors.darkGray,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter email';
                }
                if (!GetUtils.isEmail(value.trim())) {
                  return 'Enter a valid email';
                }
                return null;
              },
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
            ),
          ),
          if (widget.controller.text.isNotEmpty)
            IconButton(
              tooltip: 'Clear email',
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
