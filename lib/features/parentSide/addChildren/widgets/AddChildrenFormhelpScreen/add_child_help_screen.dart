// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/features/parentSide/addChildren/widgets/AddChildrenFormhelpScreen/add_child_form.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/common widgets/custom_button.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/constants/button_dimensions.dart';
import 'package:godropme/features/parentSide/addChildren/controllers/add_children_controller.dart';

class AddChildHelpScreen extends StatefulWidget {
  const AddChildHelpScreen({super.key});

  @override
  State<AddChildHelpScreen> createState() => _AddChildHelpScreenState();
}

class _AddChildHelpScreenState extends State<AddChildHelpScreen> {
  // Use a typed GlobalKey so we can call submitForm safely.
  final GlobalKey<AddChildFormState> _formKey = GlobalKey<AddChildFormState>();

  void _onSave(Map<String, dynamic> data) {
    debugPrint('Saved child: $data');
    // Append to persistent children list
    () async {
      // Use controller to manage storage/state (dummy, no backend)
      final ctrl = Get.find<AddChildrenController>();
      await ctrl.addChild(data);
      if (!mounted) return;
      // Navigate to Add Children screen after successful save
      Get.offNamed(AppRoutes.addChildren);
    }();
  }

  void _handleSave() {
    // Trigger the form's submit using the typed key.
    final state = _formKey.currentState;
    if (state != null) {
      state.submitForm();
    } else {
      // No UI toast requested; silently ignore when form state is unavailable
      debugPrint('AddChildHelpScreen: form state unavailable, cannot submit');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          // Mirror driver-side screens horizontal/vertical padding
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button consistent with driver-side screens
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Get.offNamed(AppRoutes.addChildren),
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 28,
                    color: AppColors.black,
                  ),
                  splashRadius: 20,
                ),
              ),

              SizedBox(height: Responsive.scaleClamped(context, 8, 6, 12)),

              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  AppStrings.addChildTitle,
                  style: AppTypography.optionHeading,
                ),
              ),

              SizedBox(height: Responsive.scaleClamped(context, 18, 12, 24)),

              // Provide the GlobalKey to the AddChildForm
              Expanded(
                child: AddChildForm(key: _formKey, onSave: _onSave),
              ),

              // Match driver-side pattern: spacing + action button inside body
              SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),
              SafeArea(
                top: false,
                child: CustomButton(
                  text: AppStrings.addChildSave,
                  onTap: _handleSave,
                  height: Responsive.scaleClamped(context, 64, 48, 80),
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(
                    AppButtonDimensions.borderRadius,
                  ),
                  textColor: AppColors.white,
                ),
              ),
              SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),
            ],
          ),
        ),
      ),
    );
  }
}
