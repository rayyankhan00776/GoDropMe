import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/core/routes/routes.dart';
import 'package:godropme/core/theme/colors.dart';
import 'package:godropme/core/utils/app_strings.dart';
import 'package:godropme/core/utils/app_typography.dart';
import 'package:godropme/core/utils/responsive.dart';
import 'package:godropme/core/widgets/custom_Appbar.dart';
import 'package:godropme/core/widgets/progress_next_bar.dart';
import 'package:godropme/core/widgets/custom_image_container.dart';
import 'package:godropme/core/widgets/custom_text_field.dart';
import 'package:godropme/features/DriverSide/driverDataCollection/controllers/driver_licence_controller.dart';
import 'package:godropme/features/DriverSide/driverDataCollection/widgets/driverLicense/licence_image_help_screen.dart';
import 'package:godropme/features/DriverSide/driverDataCollection/widgets/driverLicense/selfie_with_licence_help_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _dlController = Get.find<DriverLicenceController>();
    _licenceNumberController.text = _dlController.licenceNumber.value;
    _expiryDateController.text = _dlController.expiryDate.value;
    _licenceImagePath = _dlController.licenceImagePath.value;
    _selfieImagePath = _dlController.selfieWithLicencePath.value;
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
                        AppStrings.driverLicenceTitle,
                        style: AppTypography.optionHeading,
                      ),
                    ),

                    SizedBox(
                      height: Responsive.scaleClamped(context, 18, 12, 24),
                    ),

                    // Two image containers in a row: licence image and selfie with licence
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomImageContainer(
                                  imagePath: _licenceImagePath,
                                  width: double.infinity,
                                  height: 140,
                                  onTap: () async {
                                    final result = await Get.to(
                                      () => LicenceImageHelpScreen(
                                        imagePath:
                                            _licenceImagePath ??
                                            'assets/images/sample/driverLicence.jpg',
                                      ),
                                    );

                                    if (result is String && mounted) {
                                      setState(
                                        () => _licenceImagePath = result,
                                      );
                                      _dlController.setLicenceImagePath(result);
                                    }
                                  },
                                ),
                                SizedBox(
                                  height: Responsive.scaleClamped(
                                    context,
                                    8,
                                    6,
                                    12,
                                  ),
                                ),
                                Text(
                                  'Licence',
                                  style: AppTypography.optionTerms,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomImageContainer(
                                  imagePath: _selfieImagePath,
                                  width: double.infinity,
                                  height: 140,
                                  onTap: () async {
                                    final result = await Get.to(
                                      () => SelfieWithLicenceHelpScreen(
                                        imagePath:
                                            _selfieImagePath ??
                                            'assets/images/sample/manwithdrivinglicence.jpg',
                                      ),
                                    );

                                    if (result is String && mounted) {
                                      setState(() => _selfieImagePath = result);
                                      _dlController.setSelfieWithLicencePath(
                                        result,
                                      );
                                    }
                                  },
                                ),
                                SizedBox(
                                  height: Responsive.scaleClamped(
                                    context,
                                    8,
                                    6,
                                    12,
                                  ),
                                ),
                                Text(
                                  'Selfie with Licence',
                                  style: AppTypography.optionTerms,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: Responsive.scaleClamped(context, 12, 8, 18),
                    ),

                    // Note explaining the images
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
                      child: Text(
                        AppStrings.personalInfoCnicNote,
                        style: AppTypography.optionTerms,
                      ),
                    ),

                    // Form fields: Licence number and expiry date
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextField(
                              controller: _licenceNumberController,
                              hintText: AppStrings.driverLicenceNumberHint,
                              borderColor: AppColors.gray,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Please enter licence number'
                                  : null,
                            ),
                            SizedBox(
                              height: Responsive.scaleClamped(
                                context,
                                12,
                                8,
                                18,
                              ),
                            ),
                            CustomTextField(
                              controller: _expiryDateController,
                              hintText: AppStrings.driverLicenceExpiryHint,
                              borderColor: AppColors.gray,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Please enter expiry date'
                                  : null,
                            ),
                            SizedBox(
                              height: Responsive.scaleClamped(
                                context,
                                6,
                                4,
                                12,
                              ),
                            ),
                            SizedBox(
                              height: 18,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  _submitted &&
                                          (_licenceNumberController
                                                  .text
                                                  .isEmpty ||
                                              _expiryDateController
                                                  .text
                                                  .isEmpty)
                                      ? 'Please complete all fields and add images'
                                      : '',
                                  style: TextStyle(
                                    color:
                                        _submitted &&
                                            (_licenceNumberController
                                                    .text
                                                    .isEmpty ||
                                                _expiryDateController
                                                    .text
                                                    .isEmpty)
                                        ? const Color(0xFFFF6B6B)
                                        : Colors.transparent,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                totalSteps: 4,
                onNext: () async {
                  setState(() => _submitted = true);

                  final bool formValid =
                      _formKey.currentState?.validate() ?? false;
                  final bool hasImages =
                      _licenceImagePath != null && _selfieImagePath != null;
                  if (!formValid || !hasImages) return;

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
                  Get.toNamed(AppRoutes.vehicleSelection);
                },
                onPrevious: () {
                  Get.offNamed(AppRoutes.personalInfo);
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
