import 'package:flutter/material.dart';
import 'package:godropme/common_widgets/custom_button.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/utils/responsive.dart';

class OptionActions extends StatelessWidget {
  final VoidCallback? onContinuePhone;
  final VoidCallback? onContinueGoogle;

  const OptionActions({this.onContinuePhone, this.onContinueGoogle, super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = Responsive.screenWidth(context);
    final buttonWidth = Responsive.scaleClamped(
      context,
      screenWidth - 70,
      220,
      screenWidth - 32,
    );
    final buttonHeight = Responsive.scaleClamped(context, 58, 48, 64);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
      child: Column(
        children: [
          CustomButton(
            text: AppStrings.continueWithPhone,
            onTap: onContinuePhone,
            height: buttonHeight,
            width: buttonWidth,
          ),
          SizedBox(height: Responsive.scaleClamped(context, 7, 8, 18)),
        ],
      ),
    );
  }
}
