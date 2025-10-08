// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/core/widgets/custom_Appbar.dart';
import 'package:godropme/core/widgets/progress_next_bar.dart';
import 'package:godropme/core/utils/app_strings.dart';
import 'package:godropme/core/utils/app_typography.dart';
import 'package:godropme/core/utils/responsive.dart';
import 'package:godropme/core/theme/colors.dart';
import 'package:godropme/features/DriverSide/driverDataCollection/widgets/vehicleRegistration/vehicle_images_row.dart';
import 'package:godropme/features/DriverSide/driverDataCollection/widgets/vehicleRegistration/vehicle_registration_form.dart';
import 'package:godropme/core/utils/app_assets.dart';
import 'package:godropme/features/DriverSide/driverDataCollection/widgets/vehicleRegistration/vehicle_photo_help_screen.dart';
import 'package:godropme/features/DriverSide/driverDataCollection/widgets/vehicleRegistration/vehicle_cert_front_help_screen.dart';
import 'package:godropme/features/DriverSide/driverDataCollection/widgets/vehicleRegistration/vehicle_cert_back_help_screen.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  const VehicleRegistrationScreen({super.key});

  @override
  State<VehicleRegistrationScreen> createState() =>
      _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _yearController = TextEditingController();
  final _plateController = TextEditingController();

  String? _vehiclePhotoPath;
  String? _certFrontPath;
  String? _certBackPath;
  bool _submitted = false;
  bool _showGlobalError = false;

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Get.back(),
                            icon: const Icon(
                              Icons.arrow_back,
                              size: 28,
                              color: AppColors.black,
                            ),
                            splashRadius: 20,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: Responsive.scaleClamped(context, 8, 6, 12),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        AppStrings.vehicleRegistrationTitle,
                        style: AppTypography.optionHeading,
                      ),
                    ),

                    SizedBox(
                      height: Responsive.scaleClamped(context, 18, 12, 24),
                    ),

                    VehicleImagesRow(
                      photoPath: _vehiclePhotoPath,
                      certFrontPath: _certFrontPath,
                      certBackPath: _certBackPath,
                      onPhotoTap: () async {
                        final res = await Get.to(
                          () => VehiclePhotoHelpScreen(
                            imagePath:
                                _vehiclePhotoPath ?? AppAssets.vehiclePhoto,
                          ),
                        );
                        if (res is String && mounted) {
                          setState(() => _vehiclePhotoPath = res);
                        }
                      },
                      onCertFrontTap: () async {
                        final res = await Get.to(
                          () => VehicleCertFrontHelpScreen(
                            imagePath:
                                _certFrontPath ?? AppAssets.vehicleCertFront,
                          ),
                        );
                        if (res is String && mounted) {
                          setState(() => _certFrontPath = res);
                        }
                      },
                      onCertBackTap: () async {
                        final res = await Get.to(
                          () => VehicleCertBackHelpScreen(
                            imagePath:
                                _certBackPath ?? AppAssets.vehicleCertBack,
                          ),
                        );
                        if (res is String && mounted) {
                          setState(() => _certBackPath = res);
                        }
                      },
                      photoLabel: AppStrings.vehiclePhotoLabel,
                      certFrontLabel: AppStrings.vehicleCertFrontLabel,
                      certBackLabel: AppStrings.vehicleCertBackLabel,
                    ),

                    SizedBox(
                      height: Responsive.scaleClamped(context, 12, 8, 18),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
                      child: Text(
                        AppStrings.vehicleDetailsNote,
                        style: AppTypography.optionTerms,
                      ),
                    ),

                    VehicleRegistrationForm(
                      formKey: _formKey,
                      brandController: _brandController,
                      modelController: _modelController,
                      colorController: _colorController,
                      yearController: _yearController,
                      plateController: _plateController,
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
                currentStep: 4,
                totalSteps: 4,
                onNext: () async {
                  setState(() {
                    _submitted = true;
                    _showGlobalError = false;
                  });

                  final valid = _formKey.currentState?.validate() ?? false;
                  final hasImages =
                      _vehiclePhotoPath != null &&
                      _certFrontPath != null &&
                      _certBackPath != null;
                  if (!valid || !hasImages) {
                    setState(() => _showGlobalError = true);
                    return;
                  }

                  // TODO: Persist data or send to backend
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(AppStrings.vehicleDetailsSaved),
                      ),
                    );
                  }
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
