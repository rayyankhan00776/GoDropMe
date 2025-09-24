import 'package:flutter/material.dart';
import 'package:godropme/core/widgets/custom_button.dart';
import 'package:godropme/core/utils/app_strings.dart';

class OtpActions extends StatelessWidget {
  final VoidCallback onNext;
  final double height;
  final bool enabled;

  const OtpActions({
    required this.onNext,
    this.height = 64,
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          text: AppStrings.otpverify,
          onTap: enabled ? onNext : null,
          height: height,
          width: double.infinity,
          borderRadius: BorderRadius.circular(12),
          textColor: Colors.white,
          // Visually indicate disabled state
          gradient: enabled ? null : null,
          // Optionally, you can add opacity or color change for disabled
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
