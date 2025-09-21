import 'package:flutter/material.dart';
import 'package:godropme/core/utlis/app_assets.dart';
import 'package:godropme/core/widgets/custom_button.dart';
import 'package:godropme/core/widgets/google_button.dart';
import 'package:godropme/core/utlis/app_strings.dart';

class OptionActions extends StatelessWidget {
  final VoidCallback? onContinuePhone;
  final VoidCallback? onContinueGoogle;

  const OptionActions({this.onContinuePhone, this.onContinueGoogle, super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
      child: Column(
        children: [
          CustomButton(
            text: AppStrings.continueWithPhone,
            onTap: onContinuePhone,
            height: 58,
            width: screenWidth,
          ),
          const SizedBox(height: 12),
          GoogleButton(
            text: AppStrings.continueWithGoogle,
            onTap: onContinueGoogle,
            height: 58,
            width: screenWidth,
            leading: Image.asset(AppAssets.google, width: 40, height: 40),
          ),
        ],
      ),
    );
  }
}
