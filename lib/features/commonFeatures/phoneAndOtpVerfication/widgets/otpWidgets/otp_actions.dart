import 'package:flutter/material.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/common%20widgets/custom_button.dart';
import 'package:godropme/constants/app_strings.dart';

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
        GestureDetector(
          onTap: onNext,
          child: Opacity(
            opacity: enabled ? 1.0 : 0.55,
            child: CustomButton(
              text: AppStrings.otpverify,
              onTap: enabled ? onNext : onNext,
              height: height,
              width: double.infinity,
              borderRadius: BorderRadius.circular(12),
              textColor: Colors.white,
            ),
          ),
        ),
        SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),
      ],
    );
  }
}
