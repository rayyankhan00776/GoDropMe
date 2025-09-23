import 'package:flutter/material.dart';
import 'package:godropme/core/widgets/custom_button.dart';
import 'package:godropme/core/utils/app_strings.dart';

class PhoneActions extends StatelessWidget {
  final VoidCallback onNext;
  final double height;

  const PhoneActions({required this.onNext, this.height = 64, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          text: AppStrings.onboardButton,
          onTap: onNext,
          height: height,
          width: double.infinity,
          borderRadius: BorderRadius.circular(12),
          textColor: Colors.white,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
