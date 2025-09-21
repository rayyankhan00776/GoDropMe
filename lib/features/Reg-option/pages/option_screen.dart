// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/features/Reg-option/widgets/option_content.dart';
import 'package:godropme/features/Reg-option/controllers/option_controller.dart';

class OptionScreen extends StatelessWidget {
  const OptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available via binding; find it here for callbacks
    final OptionController ctrl = Get.find();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.vertical,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                OptionContent(
                  onContinuePhone: ctrl.continueWithPhone,
                  onContinueGoogle: ctrl.continueWithGoogle,
                  onTermsTap: ctrl.openTerms,
                  onPrivacyTap: ctrl.openPrivacy,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
