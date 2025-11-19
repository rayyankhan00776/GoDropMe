import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/features/commonFeatures/phoneAndOtpVerfication/widgets/otpWidgets/otp_actions.dart';
import 'package:godropme/features/commonFeatures/phoneAndOtpVerfication/widgets/otpWidgets/otp_header.dart';
import 'package:godropme/features/commonFeatures/phoneAndOtpVerfication/widgets/otpWidgets/otp_text_field.dart';
import 'package:godropme/features/commonFeatures/phoneAndOtpVerfication/widgets/otpWidgets/otp_error_dialog.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/features/commonFeatures/phoneAndOtpVerfication/controllers/otp_controller.dart';
import 'package:godropme/features/commonFeatures/phoneAndOtpVerfication/controllers/phone_controller.dart';
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
  late final PhoneController _phoneController;
  late final bool _isUpdateMode;
  late final String _role; // 'driver' | 'parent' | ''

  @override
  void initState() {
    super.initState();
    // Initialize once to avoid reassigning a late final during rebuilds.
    _otpController = Get.find<OtpController>();
    _phoneController = Get.find<PhoneController>();
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
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _submitOtp() {
    // For now skip backend verification. If all fields are filled, navigate
    // to the DOP option screen. The button is already enabled only when
    // each field has one character, so this is a safe local bypass.
    if (_otpController.allFilled.value) {
      if (_isUpdateMode) {
        // Persist updated phone after successful OTP entry
        final rawNational = _phoneController.phone.value.trim();
        if (_role == 'driver') {
          LocalStorage.setString(StorageKeys.driverPhone, rawNational);
        } else if (_role == 'parent') {
          LocalStorage.setString(StorageKeys.parentPhone, rawNational);
        } else {
          // Default fallback: parent key (original behavior)
          LocalStorage.setString(StorageKeys.parentPhone, rawNational);
        }
        Get.snackbar(
          'Phone Updated',
          'Your phone number has been updated successfully.',
          snackPosition: SnackPosition.BOTTOM,
        );
        // Navigate back to appropriate settings screen.
        final targetRoute = _role == 'driver'
            ? AppRoutes.driverSettings
            : AppRoutes.parentSettings;
        Get.offAllNamed(targetRoute);
      } else {
        Get.toNamed(AppRoutes.dopOption);
      }
      return;
    }

    showDialog(
      context: context,
      builder: (_) => const OtpErrorDialog(
        title: AppStrings.error,
        message: 'Please enter the 6-digit verification code.',
        buttonText: AppStrings.ok,
      ),
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
              OtpHeader(
                title: _isUpdateMode ? AppStrings.updateOtpTitle : null,
                subtitle: _isUpdateMode ? AppStrings.updateOtpSubtitle : null,
              ),
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

              const Spacer(),
              // Beneath OTP form: show the number and a change action
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    Obx(() {
                      final raw = _phoneController.phone.value;
                      if (raw.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      // Normalize to exactly one +92 prefix for display
                      String national = raw;
                      if (national.startsWith('+92')) {
                        national = national.substring(3);
                      } else if (national.startsWith('92')) {
                        national = national.substring(2);
                      }
                      final display = '+92 $national';
                      return Text(
                        display,
                        style: AppTypography.helperSmall.copyWith(
                          color: AppColors.darkGray,
                          fontSize: 14, // +2 from helperSmall (12 -> 14)
                        ),
                      );
                    }),
                    TextButton(
                      onPressed: () {
                        // Reset submission state and go back to phone screen for editing
                        _phoneController.submitted.value = false;
                        // Pop back through the stack until the phone screen is on top.
                        // This avoids issues if an extra OTP was stacked earlier.
                        Get.until(
                          (route) =>
                              route.settings.name == AppRoutes.phoneScreen,
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppStrings.changeNumber,
                        style: AppTypography.helperSmall.copyWith(
                          color: AppColors.primary,
                          fontSize: 14, // +2 from helperSmall (12 -> 14)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => OtpActions(
                  onNext: _submitOtp,
                  height: Responsive.scaleClamped(context, 64, 48, 80),
                  enabled: _otpController.allFilled.value,
                  buttonText: _isUpdateMode
                      ? AppStrings.updateOtpVerify
                      : AppStrings.otpverify,
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
