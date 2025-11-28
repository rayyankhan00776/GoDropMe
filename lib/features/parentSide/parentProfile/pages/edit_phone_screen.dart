import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:godropme/regix/pakistan_number_formatter.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';

class EditPhoneScreen extends StatefulWidget {
  const EditPhoneScreen({super.key});

  @override
  State<EditPhoneScreen> createState() => _EditPhoneScreenState();
}

class _EditPhoneScreenState extends State<EditPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _isValid = true.obs; // Phone is optional, so valid by default

  @override
  void initState() {
    super.initState();
    _loadCurrentPhone();
    _phoneController.addListener(_validatePhone);
  }

  Future<void> _loadCurrentPhone() async {
    final phone = await LocalStorage.getString(StorageKeys.parentPhone);
    if (phone != null && phone.isNotEmpty) {
      _phoneController.text = phone;
      _validatePhone();
    }
  }

  void _validatePhone() {
    final phone = _phoneController.text.trim();
    // Phone is optional - if empty, it's valid
    // If not empty, must be at least 10 digits (basic validation)
    if (phone.isEmpty) {
      _isValid.value = true;
    } else {
      // Remove non-digit characters for validation
      final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
      _isValid.value = digitsOnly.length >= 10;
    }
  }

  Future<void> _savePhone() async {
    if (_formKey.currentState?.validate() ?? false) {
      final phone = _phoneController.text.trim();
      await LocalStorage.setString(StorageKeys.parentPhone, phone);
      // Hide keyboard before navigating back to avoid overflow
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      await Future.delayed(const Duration(milliseconds: 100));
      Get.back(result: phone);
      Get.snackbar(
        'Success',
        phone.isEmpty ? 'Phone removed' : 'Phone updated successfully',
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
    _phoneController.dispose();
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
                Text(
                  'Edit Phone',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your phone number (optional)',
                  style: AppTypography.helperSmall.copyWith(
                    color: AppColors.darkGray,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                _PhoneInputField(
                  controller: _phoneController,
                  onClear: () {
                    _phoneController.clear();
                    _validatePhone();
                  },
                ),
                const SizedBox(height: 8),
                Obx(() => _isValid.value
                    ? Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          'Phone number is optional',
                          style: AppTypography.helperSmall.copyWith(
                            color: AppColors.darkGray,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          'Enter a valid phone number (at least 10 digits)',
                          style: AppTypography.errorSmall,
                        ),
                      )),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: Responsive.scaleClamped(context, 64, 48, 80),
                  child: Obx(() => ElevatedButton(
                        onPressed: _isValid.value ? _savePhone : null,
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

class _PhoneInputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onClear;

  const _PhoneInputField({
    required this.controller,
    required this.onClear,
  });

  @override
  State<_PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<_PhoneInputField> {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.phone_outlined, color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          Text(
            '+92',
            style: AppTypography.optionLineSecondary.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: widget.controller,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                PakistanPhoneNumberFormatter(),
              ],
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
                hintText: 'Phone Number',
                hintStyle: AppTypography.optionTerms.copyWith(
                  color: AppColors.darkGray,
                ),
              ),
              validator: (value) {
                // Phone is optional - no validation error for empty
                if (value == null || value.trim().isEmpty) {
                  return null;
                }
                // If not empty, validate format
                final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
                if (digitsOnly.length < 10) {
                  return 'Enter a valid phone number';
                }
                return null;
              },
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
            ),
          ),
          if (widget.controller.text.isNotEmpty)
            IconButton(
              tooltip: 'Clear phone',
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
