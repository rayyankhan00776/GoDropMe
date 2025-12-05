import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/features/commonFeatures/EmailAndOtpVerfication/widgets/otpWidgets/otp_actions.dart';
import 'package:godropme/features/commonFeatures/EmailAndOtpVerfication/widgets/otpWidgets/otp_header.dart';
import 'package:godropme/features/commonFeatures/EmailAndOtpVerfication/widgets/otpWidgets/otp_text_field.dart';
import 'package:godropme/features/commonFeatures/EmailAndOtpVerfication/widgets/otpWidgets/otp_error_dialog.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/features/commonFeatures/EmailAndOtpVerfication/controllers/otp_controller.dart';
import 'package:godropme/features/commonFeatures/EmailAndOtpVerfication/controllers/email_controller.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // Six controllers for a 6-digit OTP
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  late final OtpController _otpController;
  late final EmailController _emailController;

  @override
  void initState() {
    super.initState();
    // Initialize once to avoid reassigning a late final during rebuilds.
    _otpController = Get.find<OtpController>();
    _emailController = Get.find<EmailController>();
  }

  @override
  void dispose() {
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _submitOtp() async {
    if (!_otpController.allFilled.value) {
      showDialog(
        context: context,
        builder: (_) => const OtpErrorDialog(
          title: AppStrings.error,
          message: 'Please enter the 6-digit verification code.',
          buttonText: AppStrings.ok,
        ),
      );
      return;
    }

    // Verify OTP via Appwrite
    final success = await _otpController.verifyOtp();
    
    if (!success && mounted) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (_) => OtpErrorDialog(
          title: AppStrings.error,
          message: _otpController.errorMessage.value.isNotEmpty 
              ? _otpController.errorMessage.value 
              : 'Verification failed. Please try again.',
          buttonText: AppStrings.ok,
        ),
      );
    }
    // If success, navigation is handled by the controller
  }

  void _resendOtp() async {
    final email = _emailController.email.value.trim();
    if (email.isEmpty) return;
    
    // Clear current OTP fields
    for (final c in _codeControllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    
    final success = await _otpController.resendOtp(email);
    
    if (success && mounted) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('OTP sent to $email'),
      //     backgroundColor: AppColors.primary,
      //     behavior: SnackBarBehavior.floating,
      //     margin: const EdgeInsets.all(16),
      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      //   ),
      // );
      Get.snackbar(
        'Success',
        'OTP sent to $email',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        colorText: AppColors.primaryDark,
      );
    } else if (!success && mounted) {
      showDialog(
        context: context,
        builder: (_) => OtpErrorDialog(
          title: AppStrings.error,
          message: _otpController.errorMessage.value.isNotEmpty
              ? _otpController.errorMessage.value
              : 'Failed to resend OTP. Please try again.',
          buttonText: AppStrings.ok,
        ),
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
              const OtpHeader(),
              const SizedBox(height: 30),

              // OTP input row — responsive sizing to avoid overflow on small screens
              LayoutBuilder(
                builder: (context, constraints) {
                  // available width for 6 boxes and spacing between them.
                  final availableWidth = constraints.maxWidth;
                  // desired spacing between boxes
                  const gap = 8.0;
                  // compute box size so 6 boxes + gaps fit into available width
                  final totalGaps = gap * (6 - 1);
                  final boxSize = ((availableWidth - totalGaps) / 6).clamp(
                    44.0,
                    72.0,
                  );

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (i) {
                      return SizedBox(
                        width: boxSize,
                        child: OtpTextField(
                          controller: _codeControllers[i],
                          autoFocus: i == 0,
                          focusNode: _focusNodes[i],
                          fieldNumber: i,
                          size: boxSize,
                          onChanged: (val) => _otpController.setDigit(i, val),
                        ),
                      );
                    }),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Resend OTP section
              Center(
                child: Obx(() {
                  if (_otpController.canResend.value) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive OTP? ",
                          style: AppTypography.helperSmall.copyWith(
                            color: AppColors.darkGray,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: _otpController.isResending.value
                              ? null
                              : () => _resendOtp(),
                          child: Text(
                            _otpController.isResending.value ? 'Sending...' : 'Resend',
                            style: AppTypography.helperSmall.copyWith(
                              color: _otpController.isResending.value
                                  ? AppColors.darkGray
                                  : AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Text(
                      'Resend OTP in ${_otpController.resendCountdown.value}s',
                      style: AppTypography.helperSmall.copyWith(
                        color: AppColors.darkGray,
                        fontSize: 14,
                      ),
                    );
                  }
                }),
              ),

              const Spacer(),
              // Beneath OTP form: show the em and a change action
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    Obx(() {
                      final raw = _emailController.email.value;
                      if (raw.isEmpty) return const SizedBox.shrink();
                      return Text(
                        raw,
                        style: AppTypography.helperSmall.copyWith(
                          color: AppColors.darkGray,
                          fontSize: 14,
                        ),
                      );
                    }),
                    TextButton(
                      onPressed: () {
                        _emailController.submitted.value = false;
                        Get.until(
                          (route) =>
                              route.settings.name == AppRoutes.emailScreen,
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppStrings.changeEmail,
                        style: AppTypography.helperSmall.copyWith(
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => OtpActions(
                  onNext: _otpController.isLoading.value ? () {} : _submitOtp,
                  height: Responsive.scaleClamped(context, 64, 48, 80),
                  enabled: _otpController.allFilled.value && !_otpController.isLoading.value,
                  buttonText: _otpController.isLoading.value ? 'Verifying...' : AppStrings.otpverify,
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
