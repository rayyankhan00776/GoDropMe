import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_assets.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/common%20widgets/custom_Appbar.dart';
import 'package:godropme/common%20widgets/progress_next_bar.dart';
// ...existing widget imports moved to modular widgets
import 'package:godropme/features/driverSide/driverRegistration/widgets/driverLicense/licence_image_row.dart';
import 'package:godropme/features/driverSide/driverRegistration/widgets/driverLicense/driverlicence_form.dart';
import 'package:godropme/features/driverSide/driverRegistration/controllers/driver_licence_controller.dart';
import 'package:godropme/features/driverSide/driverRegistration/widgets/driverLicense/licence_image_help_screen.dart';
import 'package:godropme/features/driverSide/driverRegistration/widgets/driverLicense/selfie_with_licence_help_screen.dart';

class DriverLicenceScreen extends StatefulWidget {
  const DriverLicenceScreen({super.key});

  @override
  State<DriverLicenceScreen> createState() => _DriverLicenceScreenState();
}

class _DriverLicenceScreenState extends State<DriverLicenceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final DriverLicenceController _dlController;
  final TextEditingController _licenceNumberController =
      TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  String? _licenceImagePath;
  String? _selfieImagePath;
  bool _submitted = false;
  bool _showGlobalError = false;

  @override
  void initState() {
    super.initState();
    _dlController = Get.find<DriverLicenceController>();
    // Reset local flags when entering this screen
    _submitted = false;
    _showGlobalError = false;
    // Per latest UX requirement: do NOT prefill fields from SharedPreferences.
    _licenceNumberController.text = '';
    _expiryDateController.text = '';
    _licenceImagePath = null;
    _selfieImagePath = null;
  }

  @override
  void dispose() {
    _licenceNumberController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomBlurAppBar(),
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
                            onPressed: () => Get.back(),
                            icon: const Icon(
                              Icons.close,
                              size: 29,
                              weight: 800,
                              color: AppColors.darkGray,
                            ),
                            splashRadius: 20,
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
                        AppStrings.driverLicenceTitle,
                        style: AppTypography.optionHeading,
                      ),
                    ),

                    SizedBox(
                      height: Responsive.scaleClamped(context, 18, 12, 24),
                    ),

                    LicenceImageRow(
                      licenceImagePath: _licenceImagePath,
                      selfieImagePath: _selfieImagePath,
                      onLicenceTap: () async {
                        final result = await Get.to(
                          () => LicenceImageHelpScreen(
                            imagePath:
                                _licenceImagePath ?? AppAssets.driverLicense,
                          ),
                        );

                        if (result is String && mounted) {
                          setState(() => _licenceImagePath = result);
                          _dlController.setLicenceImagePath(result);
                        }
                      },
                      onSelfieTap: () async {
                        final result = await Get.to(
                          () => SelfieWithLicenceHelpScreen(
                            imagePath:
                                _selfieImagePath ??
                                AppAssets.selfieWithDrivingLicense,
                          ),
                        );

                        if (result is String && mounted) {
                          setState(() => _selfieImagePath = result);
                          _dlController.setSelfieWithLicencePath(result);
                        }
                      },
                    ),

                    SizedBox(
                      height: Responsive.scaleClamped(context, 8, 6, 12),
                    ),

                    // Note explaining the images
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
                      child: Text(
                        AppStrings.driverLicenseNote,
                        style: AppTypography.optionTerms,
                      ),
                    ),

                    DriverLicenceForm(
                      formKey: _formKey,
                      licenceNumberController: _licenceNumberController,
                      expiryDateController: _expiryDateController,
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
                currentStep: 2,
                totalSteps: 5,
                onNext: () async {
                  setState(() {
                    _submitted = true;
                    _showGlobalError = false;
                  });

                  final bool formValid =
                      _formKey.currentState?.validate() ?? false;
                  final bool hasImages =
                      _licenceImagePath != null && _selfieImagePath != null;
                  if (!formValid || !hasImages) {
                    setState(() => _showGlobalError = true);
                    return;
                  }

                  // persist into controller
                  _dlController.setLicenceNumber(
                    _licenceNumberController.text.trim(),
                  );
                  _dlController.setExpiryDate(
                    _expiryDateController.text.trim(),
                  );
                  _dlController.setLicenceImagePath(_licenceImagePath);
                  _dlController.setSelfieWithLicencePath(_selfieImagePath);
                  await _dlController.saveDriverLicence();

                  // Navigate to next step (vehicle selection)
                  Get.toNamed(AppRoutes.driverIdentification);
                },
                onPrevious: () {
                  Get.back();
                },
                previousBackgroundColor: Colors.grey.shade300,
                previousIconColor: Colors.grey.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
