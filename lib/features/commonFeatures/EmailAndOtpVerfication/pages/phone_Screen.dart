// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/common%20widgets/custom_text_field.dart';
import 'package:godropme/features/commonFeatures/EmailAndOtpVerfication/controllers/email_controller.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late final EmailController _emailController;
  late final bool _isUpdateMode;
  late final String _role; // 'driver' | 'parent' | ''

  @override
  void initState() {
    super.initState();
    // Initialize once to avoid re-initialization during rebuilds.
    _emailController = Get.find<EmailController>();
    final args = Get.arguments;
    if (args is Map) {
      _isUpdateMode = args['mode'] == 'update-phone';
      _role = (args['role'] as String?) ?? '';
    } else {
      _isUpdateMode = false;
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

  void _onNextPressed() {
    _emailController.markSubmitted();
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    _emailController.setEmail(_controller.text.trim());
    if (!_isUpdateMode) {
      // Reuse existing storage key to avoid downstream changes.
      LocalStorage.setString(StorageKeys.parentPhone, _controller.text.trim());
    }
    Get.toNamed(
      AppRoutes.otpScreen,
      arguments: {
        if (_isUpdateMode) 'mode': 'update-phone',
        if (_role.isNotEmpty) 'role': _role,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
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
                _isUpdateMode
                    ? AppStrings.updateEmailTitle
                    : AppStrings.emailTitle,
                style: AppTypography.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _isUpdateMode
                    ? AppStrings.updateEmailSubtitle
                    : AppStrings.emailSubtitle,
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
                      CustomTextField(
                        controller: _controller,
                        hintText: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: _emailValidator,
                        height: Responsive.scaleClamped(context, 66, 44, 66),
                      ),
                      SizedBox(
                        height: Responsive.scaleClamped(context, 6, 4, 12),
                      ),
                      SizedBox(
                        height: 18,
                        child: Align(
                          alignment: Alignment.centerLeft,
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
                child: ElevatedButton(
                  onPressed: _onNextPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isUpdateMode
                        ? AppStrings.updateEmailButton
                        : AppStrings.onboardButton,
                    style: AppTypography.onboardButton,
                  ),
                ),
              ),
              SizedBox(height: Responsive.scaleClamped(context, 24, 16, 32)),
            ],
          ),
        ),
      ),
    );
  }
}
