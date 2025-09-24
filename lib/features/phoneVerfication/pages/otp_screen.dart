import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/core/routes/routes.dart';
import 'package:godropme/core/utils/responsive.dart';
import 'package:godropme/features/phoneVerfication/widgets/otpWidgets/otp_actions.dart';
import 'package:godropme/features/phoneVerfication/widgets/otpWidgets/otp_header.dart';
import 'package:godropme/features/phoneVerfication/widgets/otpWidgets/otp_text_field.dart';
import 'package:godropme/features/phoneVerfication/widgets/otpWidgets/otp_error_dialog.dart';

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
    final allFilled = _codeControllers.every((c) => c.text.trim().isNotEmpty);

    if (allFilled) {
      Get.offNamed(AppRoutes.dopOption);
      return;
    }

    showDialog(
      context: context,
      builder:
          (_) => const OtpErrorDialog(
            title: 'Invalid code',
            message: 'Please enter the 6-digit verification code.',
            buttonText: 'OK',
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
              OtpHeader(),
              const SizedBox(height: 24),

              // OTP input row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (i) => OtpTextField(
                    controller: _codeControllers[i],
                    autoFocus: i == 0,
                    focusNode: _focusNodes[i],
                    fieldNumber: i,
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                ),
              ),

              const Spacer(),
              OtpActions(
                onNext: _submitOtp,
                height: Responsive.scaleClamped(context, 64, 48, 80),
                enabled: _codeControllers.every(
                  (c) => c.text.trim().length == 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
