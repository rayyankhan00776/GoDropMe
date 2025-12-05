import 'package:flutter/material.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/common_widgets/custom_button.dart';
import 'package:godropme/constants/app_strings.dart';

class EmailActions extends StatelessWidget {
  final VoidCallback onNext;
  final double height;
  final String? buttonText;

  const EmailActions({
    required this.onNext,
    this.height = 64,
    this.buttonText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          text: buttonText ?? AppStrings.onboardButton,
          onTap: onNext,
          height: height,
          width: double.infinity,
          borderRadius: BorderRadius.circular(12),
          textColor: Colors.white,
        ),
        SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),
      ],
    );
  }
}
