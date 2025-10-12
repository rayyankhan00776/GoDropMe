// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/common%20widgets/custom_Appbar.dart';
import 'package:godropme/common%20widgets/progress_next_bar.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/features/driverSide/driverRegistration/widgets/vehicleRegistration/vehicle_images_row.dart';
import 'package:godropme/features/driverSide/driverRegistration/widgets/vehicleRegistration/vehicle_registration_form.dart';
import 'package:godropme/utils/app_assets.dart';
import 'package:godropme/features/driverSide/driverRegistration/widgets/vehicleRegistration/vehicle_photo_help_screen.dart';
import 'package:godropme/features/driverSide/driverRegistration/widgets/vehicleRegistration/vehicle_cert_front_help_screen.dart';
import 'package:godropme/features/driverSide/driverRegistration/widgets/vehicleRegistration/vehicle_cert_back_help_screen.dart';
import 'package:godropme/features/driverSide/driverRegistration/controllers/vehicle_registration_controller.dart';

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
  final _seatCapacityController = TextEditingController();

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
    _seatCapacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Controller is provided via route binding; do not register here.
    final VehicleRegistrationController controller = Get.find();
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
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        bottom: 6.0,
                        top: 10.0,
                      ),
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
                      seatCapacityController: _seatCapacityController,
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

                  // Validate text fields with validators (year, plate, seat capacity)
                  final valid = _formKey.currentState?.validate() ?? false;
                  // Validate dropdown selections
                  final dropdownsValid =
                      _brandController.text.trim().isNotEmpty &&
                      _modelController.text.trim().isNotEmpty &&
                      _colorController.text.trim().isNotEmpty;
                  final hasImages =
                      _vehiclePhotoPath != null &&
                      _certFrontPath != null &&
                      _certBackPath != null;
                  if (!valid || !dropdownsValid || !hasImages) {
                    setState(() => _showGlobalError = true);
                    // SnackBars removed as requested; rely on the form-level error banner.
                    return;
                  }

                  // Persist the section locally via controller (logic preserved)
                  await controller.saveVehicleRegistrationSection(
                    brand: _brandController.text.trim(),
                    model: _modelController.text.trim(),
                    color: _colorController.text.trim(),
                    year: _yearController.text.trim(),
                    plate: _plateController.text.trim(),
                    seatCapacity:
                        int.tryParse(_seatCapacityController.text.trim()) ?? 0,
                    vehiclePhotoPath: _vehiclePhotoPath,
                    certFrontPath: _certFrontPath,
                    certBackPath: _certBackPath,
                  );

                  // Fetch and print aggregated onboarding data for debugging.
                  try {
                    final driverName = await LocalStorage.getString(
                      StorageKeys.driverName,
                    );
                    final vehicleSelection = await LocalStorage.getString(
                      StorageKeys.vehicleSelection,
                    );
                    final personal = await LocalStorage.getJson(
                      StorageKeys.personalInfo,
                    );
                    final licence = await LocalStorage.getJson(
                      StorageKeys.driverLicence,
                    );
                    final identification = await LocalStorage.getJson(
                      StorageKeys.driverIdentification,
                    );
                    final vehicle = await LocalStorage.getJson(
                      StorageKeys.vehicleRegistration,
                    );

                    // Print in a compact, readable form to the debug console.
                    // This data will later be sent to the backend.
                    // ignore: avoid_print
                    print('--- Onboarding cached data ---');
                    // ignore: avoid_print
                    print('driverName: $driverName');
                    // ignore: avoid_print
                    print('vehicleSelection: $vehicleSelection');
                    // ignore: avoid_print
                    print('personalInfo: ${personal ?? {}}');
                    // ignore: avoid_print
                    print('driverLicence: ${licence ?? {}}');
                    // ignore: avoid_print
                    print('driverIdentification: ${identification ?? {}}');
                    // ignore: avoid_print
                    print('vehicleRegistration: ${vehicle ?? {}}');
                    // ignore: avoid_print
                    print('--- end onboarding data ---');
                  } catch (e) {
                    // ignore: avoid_print
                    print('Failed to print onboarding data: $e');
                  }

                  // TODO: Send to backend in future
                  // Success SnackBar removed as requested.
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
