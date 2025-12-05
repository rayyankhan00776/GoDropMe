// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/utils/responsive.dart';
// Do NOT use the shared CustomTextField here because we need
// a one-off prefix (email icon) and a conditional clear suffix.
// Requirement: This styling change must remain local to the email screen.
import 'package:godropme/features/commonFeatures/EmailAndOtpVerfication/controllers/email_controller.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final EmailController _emailController;
  late final String _role; // 'driver' | 'parent' | ''

  @override
  void initState() {
    super.initState();
    // Initialize once to avoid re-initialization during rebuilds.
    _emailController = Get.find<EmailController>();
    // Rebuild to show / hide clear (X) suffix icon dynamically.
    _controller.addListener(() => setState(() {}));
    final args = Get.arguments;
    if (args is Map) {
      _role = (args['role'] as String?) ?? '';
    } else {
      _role = '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _emailValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter email';
    if (!GetUtils.isEmail(v)) return 'Enter a valid email';
    return null;
  }

  void _onNextPressed() async {
    _emailController.markSubmitted();
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    _emailController.setEmail(_controller.text.trim());
    
    // Send OTP via Appwrite
    final success = await _emailController.sendOtp();
    if (success) {
      Get.toNamed(
        AppRoutes.otpScreen,
        arguments: {
          if (_role.isNotEmpty) 'role': _role,
        },
      );
    } else {
      // Show error snackbar
      Get.snackbar(
        'Error',
        _emailController.errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, size: 28),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.scaleClamped(context, 16, 12, 24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Simple header (text-only) replacing phone-specific header.
              Text(
                'Enter your Email',
                style: AppTypography.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'We will send a verification code to this email',
                style: AppTypography.helperSmall.copyWith(
                  color: AppColors.darkGray,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Obx(() {
                  final showError = _emailController.submitted.value;
                  final error = showError
                      ? _emailValidator(_controller.text)
                      : null;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _EmailInputField(
                        controller: _controller,
                        hintText: 'you@example.com',
                        showError: showError,
                        validator: _emailValidator,
                      ),
                      SizedBox(
                        height: Responsive.scaleClamped(context, 6, 4, 12),
                      ),
                      SizedBox(
                        height: 18,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            error ?? '',
                            style: AppTypography.helperSmall.copyWith(
                              color: error != null
                                  ? AppColors.accent
                                  : Colors.transparent,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const Spacer(),
              SizedBox(
                height: Responsive.scaleClamped(context, 64, 48, 80),
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: _emailController.isLoading.value ? null : _onNextPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _emailController.isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          AppStrings.onboardButton,
                          style: AppTypography.onboardButton,
                        ),
                )),
              ),
              SizedBox(height: Responsive.scaleClamped(context, 24, 16, 32)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Private one-off email input widget with prefix email icon and
/// conditional clear (X) suffix. This is intentionally local so other
/// text fields in the app remain unaffected.
class _EmailInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool showError;
  final String? Function(String?)? validator;

  const _EmailInputField({
    required this.controller,
    required this.hintText,
    required this.showError,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final baseHeight = Responsive.scaleClamped(context, 66, 48, 72);
    return Container(
      height: baseHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: showError && (validator?.call(controller.text) != null)
              ? AppColors.accent
              : AppColors.primary,
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
              controller: controller,
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
                hintText: hintText,
                hintStyle: AppTypography.optionTerms.copyWith(
                  color: AppColors.darkGray,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                errorStyle: const TextStyle(
                  height: 0,
                  color: Colors.transparent,
                  fontSize: 0,
                ),
              ),
              validator: validator,
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              autovalidateMode: AutovalidateMode.disabled,
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              tooltip: 'Clear email',
              splashRadius: 20,
              icon: const Icon(
                Icons.close,
                size: 22,
                color: AppColors.darkGray,
              ),
              onPressed: () {
                controller.clear();
              },
            ),
        ],
      ),
    );
  }
}
