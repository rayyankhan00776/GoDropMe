import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/common%20widgets/custom_Appbar.dart';
import 'package:godropme/common%20widgets/progress_next_bar.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/features/driverSide/driverRegistration/widgets/driverIdentification/driver_identification_image_row.dart';
import 'package:godropme/features/driverSide/driverRegistration/widgets/driverIdentification/driver_identification_form.dart';
import 'package:godropme/features/driverSide/driverRegistration/widgets/driverIdentification/identification_image_help_screen.dart';
import 'package:godropme/utils/app_assets.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/features/driverSide/driverRegistration/controllers/driver_identification_controller.dart';

class DriverIdentificationScreen extends StatefulWidget {
  const DriverIdentificationScreen({super.key});

  @override
  State<DriverIdentificationScreen> createState() =>
      _DriverIdentificationScreenState();
}

class _DriverIdentificationScreenState
    extends State<DriverIdentificationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  String? _frontImagePath;
  String? _backImagePath;
  bool _submitted = false;
  bool _showGlobalError = false;

  @override
  void initState() {
    super.initState();
    // Ensure previous screen's validation flags don't bleed into this screen
    _submitted = false;
    _showGlobalError = false;
    // Optionally, we can pre-load persisted data here if desired
    // (Controller load would require controller instance; skipping for now
    // as this screen manages local state for image paths and form fields.)
  }

  @override
  void dispose() {
    _cnicController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Keep bottom progress bar stable when keyboard appears (do not resize body)
      resizeToAvoidBottomInset: false,
      appBar: const CustomBlurAppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: SingleChildScrollView(
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
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: Icon(Icons.arrow_back, color: Colors.black),
                        ),
                        SizedBox(
                          width: Responsive.scaleClamped(context, 8, 6, 12),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: Responsive.scaleClamped(context, 8, 6, 12),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        AppStrings.driverIdentificationTitle,
                        style: AppTypography.optionHeading,
                      ),
                    ),

                    SizedBox(
                      height: Responsive.scaleClamped(context, 18, 12, 24),
                    ),

                    DriverIdentificationImageRow(
                      frontImagePath: _frontImagePath,
                      backImagePath: _backImagePath,
                      onFrontTap: () async {
                        final res = await Get.to(
                          () => IdentificationImageHelpScreen(
                            imagePath: _frontImagePath ?? AppAssets.cnicFront,
                            title: AppStrings.idFrontTitle,
                          ),
                        );
                        if (res is String && mounted) {
                          setState(() => _frontImagePath = res);
                        }
                      },
                      onBackTap: () async {
                        final res = await Get.to(
                          () => IdentificationImageHelpScreen(
                            imagePath: _backImagePath ?? AppAssets.cnicBack,
                            title: AppStrings.idBackTitle,
                          ),
                        );
                        if (res is String && mounted) {
                          setState(() => _backImagePath = res);
                        }
                      },
                    ),

                    SizedBox(
                      height: Responsive.scaleClamped(context, 12, 8, 18),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
                      child: Text(
                        AppStrings.driverIdentificationNote,
                        style: AppTypography.optionTerms,
                      ),
                    ),

                    DriverIdentificationForm(
                      formKey: _formKey,
                      cnicController: _cnicController,
                      expiryController: _expiryController,
                      showSubmittedErrors: _submitted,
                      showGlobalError: _showGlobalError,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            top: false,
            left: false,
            right: false,
            bottom: true,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: ProgressNextBar(
                currentStep: 3,
                totalSteps: 5,
                onNext: () async {
                  setState(() {
                    _submitted = true;
                    _showGlobalError = false;
                  });

                  final bool formValid =
                      _formKey.currentState?.validate() ?? false;
                  final bool hasImages =
                      _frontImagePath != null && _backImagePath != null;
                  if (!formValid || !hasImages) {
                    setState(() => _showGlobalError = true);
                    return;
                  }

                  // Optionally persist to SharedPrefs via controller (lightweight cache)
                  try {
                    final c = Get.find<DriverIdentificationController>();
                    c
                      ..setCnicNumber(_cnicController.text.trim())
                      ..setExpiryDate(_expiryController.text.trim())
                      ..setFrontImagePath(_frontImagePath)
                      ..setBackImagePath(_backImagePath);
                    await c.saveDriverIdentification();
                  } catch (_) {}

                  // Navigate to vehicle registration after successful identification
                  Get.toNamed(AppRoutes.vehicleRegistration);
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
