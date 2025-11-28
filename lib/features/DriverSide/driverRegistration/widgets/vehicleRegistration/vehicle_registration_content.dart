import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/common_widgets/progress_next_bar.dart';
import 'package:godropme/features/DriverSide/driverRegistration/controllers/vehicle_registration_controller.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/utils/app_assets.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/theme/colors.dart';
import 'vehicle_registration_form.dart';
import 'vehicle_images_row.dart';
import 'vehicle_photo_help_screen.dart';
import 'vehicle_cert_front_help_screen.dart';
import 'vehicle_cert_back_help_screen.dart';

/// Value object containing collected vehicle registration data.
class VehicleRegistrationCollectedData {
  final String brand;
  final String model;
  final String color;
  final String year;
  final String plate;
  final int seatCapacity;
  final String? vehiclePhotoPath;
  final String? certFrontPath;
  final String? certBackPath;

  VehicleRegistrationCollectedData({
    required this.brand,
    required this.model,
    required this.color,
    required this.year,
    required this.plate,
    required this.seatCapacity,
    required this.vehiclePhotoPath,
    required this.certFrontPath,
    required this.certBackPath,
  });
}

/// Composite content widget for the Vehicle Registration step.
/// Encapsulates images selection, note, and form fields.
class VehicleRegistrationContent extends StatefulWidget {
  const VehicleRegistrationContent({super.key});

  @override
  State<VehicleRegistrationContent> createState() =>
      _VehicleRegistrationContentState();
}

class _VehicleRegistrationContentState
    extends State<VehicleRegistrationContent> {
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

  /// Validates all inputs & returns collected data when valid; otherwise null.
  VehicleRegistrationCollectedData? validateAndCollect() {
    setState(() {
      _submitted = true;
      _showGlobalError = false;
    });
    final validForm = _formKey.currentState?.validate() ?? false;
    final dropdownsValid =
        _brandController.text.trim().isNotEmpty &&
        _modelController.text.trim().isNotEmpty &&
        _colorController.text.trim().isNotEmpty;
    final hasImages =
        _vehiclePhotoPath != null &&
        _certFrontPath != null &&
        _certBackPath != null;
    final allValid = validForm && dropdownsValid && hasImages;
    if (!allValid) {
      setState(() => _showGlobalError = true);
      return null;
    }
    return VehicleRegistrationCollectedData(
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      color: _colorController.text.trim(),
      year: _yearController.text.trim(),
      plate: _plateController.text.trim(),
      seatCapacity: int.tryParse(_seatCapacityController.text.trim()) ?? 0,
      vehiclePhotoPath: _vehiclePhotoPath,
      certFrontPath: _certFrontPath,
      certBackPath: _certBackPath,
    );
  }

  @override
  Widget build(BuildContext context) {
    final VehicleRegistrationController controller = Get.find();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  SizedBox(height: Responsive.scaleClamped(context, 8, 6, 12)),
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
                          imagePath: _certBackPath ?? AppAssets.vehicleCertBack,
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
                  SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),
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
              totalSteps: 5,
              onNext: () async {
                final data = validateAndCollect();
                if (data == null) return;
                await controller.saveVehicleRegistrationSection(
                  brand: data.brand,
                  model: data.model,
                  color: data.color,
                  year: data.year,
                  plate: data.plate,
                  seatCapacity: data.seatCapacity,
                  vehiclePhotoPath: data.vehiclePhotoPath,
                  certFrontPath: data.certFrontPath,
                  certBackPath: data.certBackPath,
                );
                Get.toNamed(AppRoutes.driverServiceDetails);
              },
              onPrevious: () => Get.back(),
              previousBackgroundColor: Colors.grey.shade300,
              previousIconColor: Colors.grey.shade900,
            ),
          ),
        ),
      ],
    );
  }
}
