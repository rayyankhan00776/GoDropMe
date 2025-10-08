// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/core/routes/routes.dart';
import 'package:godropme/core/theme/colors.dart';
import 'package:godropme/core/utils/app_strings.dart';
import 'package:godropme/core/utils/app_typography.dart';
import 'package:godropme/core/utils/app_assets.dart';
import 'package:godropme/core/widgets/custom_Appbar.dart';
import 'package:godropme/core/utils/responsive.dart';
import 'package:godropme/features/DriverSide/driverDataCollection/widgets/personalinfo/personalinfo_help_screen.dart';
import 'package:godropme/core/widgets/progress_next_bar.dart';
import 'package:godropme/features/DriverSide/driverDataCollection/widgets/personalInfo/personalinfo_image.dart';
import 'package:godropme/features/DriverSide/driverDataCollection/widgets/personalInfo/personalinfo_form.dart';
import 'package:godropme/features/DriverSide/driverDataCollection/controllers/personal_info_controller.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _surNameController = TextEditingController();
  String? _selectedImagePath;
  bool _submitted = false;
  bool _showGlobalError = false;
  late final PersonalInfoController _piController;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _surNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // obtain the controller from the binding
    _piController = Get.find<PersonalInfoController>();
    _submitted = false;
    _showGlobalError = false;

    // Per latest UX requirement: do NOT prefill fields from SharedPreferences.
    // Keep local controllers empty so the user always types fresh data.
    _firstNameController.text = '';
    _surNameController.text = '';
    _lastNameController.text = '';
    _selectedImagePath = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // keep bottom action stable when keyboard appears
      resizeToAvoidBottomInset: false,
      appBar: const CustomBlurAppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: SingleChildScrollView(
              // ensure the scroll view accounts for the keyboard inset
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon-only back button under appbar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () =>
                                Get.offNamed(AppRoutes.vehicleSelection),
                            icon: const Icon(
                              Icons.close,
                              size: 29,
                              weight: 800,
                              color: AppColors.darkGray,
                            ),
                            splashRadius: 20,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              AppStrings.help,
                              style: AppTypography.helpButton,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: Responsive.scaleClamped(context, 8, 6, 12),
                    ),

                    // Title (shifted slightly to the right)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        AppStrings.personalInfoTitle,
                        style: AppTypography.optionHeading,
                      ),
                    ),

                    SizedBox(
                      height: Responsive.scaleClamped(context, 18, 12, 24),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: PersonalinfoImage(
                        imagePath: _selectedImagePath,
                        onTap: () async {
                          final result = await Get.to(
                            () => PersonalinfoHelpScreen(
                              imagePath: AppAssets.samplePerson,
                            ),
                          );

                          if (result is String && mounted) {
                            setState(() {
                              _selectedImagePath = result;
                            });
                            _piController.setImagePath(result);
                          }
                        },
                        showError: _submitted && _selectedImagePath == null,
                      ),
                    ),

                    SizedBox(
                      height: Responsive.scaleClamped(context, 8, 6, 12),
                    ),
                    // CNIC note above the form
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
                      child: Text(
                        AppStrings.personalInfoCnicNote,
                        style: AppTypography.optionTerms,
                      ),
                    ),
                    // Form fields for personal info (first name optional, last name required)
                    PersonalinfoForm(
                      formKey: _formKey,
                      firstNameController: _firstNameController,
                      surNameController: _surNameController,
                      lastNameController: _lastNameController,
                      showSubmittedErrors: _submitted,
                      showGlobalError: _showGlobalError,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Reusable progress + next bar pinned to bottom with 20px padding
          SafeArea(
            top: false,
            left: false,
            right: false,
            bottom: true,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: ProgressNextBar(
                currentStep: 1,
                totalSteps: 4,
                onNext: () async {
                  setState(() {
                    _submitted = true;
                    _showGlobalError = false;
                  });

                  final bool formValid =
                      _formKey.currentState?.validate() ?? false;
                  final bool hasImage = _selectedImagePath != null;
                  if (!formValid || !hasImage) {
                    setState(() => _showGlobalError = true);
                    return;
                  }

                  // Sync values into the controller and save (stub)
                  _piController.setFirstName(_firstNameController.text.trim());
                  _piController.setSurName(_surNameController.text.trim());
                  _piController.setLastName(_lastNameController.text.trim());
                  _piController.setImagePath(_selectedImagePath);
                  await _piController.savePersonalInfo();

                  // Navigate to next screen
                  Get.toNamed(AppRoutes.driverLicence);
                },
                onPrevious: null,
                previousBackgroundColor: Colors.grey.shade100,
                previousIconColor: Colors.grey.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
