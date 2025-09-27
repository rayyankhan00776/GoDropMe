import 'package:flutter/material.dart';
import 'package:godropme/core/utils/app_assets.dart';
import 'package:godropme/core/widgets/custom_button.dart';
import 'package:godropme/core/widgets/google_button.dart';
import 'package:godropme/core/utils/app_strings.dart';
import 'package:godropme/core/utils/responsive.dart';

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
          SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),
          GoogleButton(
            text: AppStrings.continueWithGoogle,
            onTap: onContinueGoogle,
            height: buttonHeight,
            width: buttonWidth,
            leading: Image.asset(
              AppAssets.google,
              width: buttonHeight - 18,
              height: buttonHeight - 18,
            ),
          ),
        ],
      ),
    );
  }
}
