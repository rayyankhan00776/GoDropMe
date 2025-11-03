import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/common%20widgets/custom_Appbar.dart';
import 'package:godropme/common%20widgets/progress_next_bar.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/features/driverSide/driverRegistration/controllers/service_details_controller.dart';
import 'package:godropme/features/driverSide/driverRegistration/widgets/serviceDetails/service_details_form.dart';
import 'package:godropme/routes.dart';

class ServiceDetailsScreen extends StatefulWidget {
  const ServiceDetailsScreen({super.key});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ServiceDetailsFormState> _formWidgetKey =
      GlobalKey<ServiceDetailsFormState>();
  late final ServiceDetailsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ServiceDetailsController>();
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () =>
                            Get.offNamed(AppRoutes.vehicleRegistration),
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 28,
                          color: AppColors.black,
                        ),
                        splashRadius: 20,
                      ),
                    ),
                    SizedBox(
                      height: Responsive.scaleClamped(context, 8, 6, 12),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Service Details',
                        style: AppTypography.optionHeading,
                      ),
                    ),
                    SizedBox(
                      height: Responsive.scaleClamped(context, 18, 12, 24),
                    ),
                    ServiceDetailsForm(
                      key: _formWidgetKey,
                      formKey: _formKey,
                      onSubmit: (values) async {
                        // map values to controller and save
                        _controller.selectedSchools.assignAll(
                          (values['schoolNames'] as List).cast<String>(),
                        );
                        _controller.dutyType.value =
                            values['dutyType'] as String?;
                        final start = values['routeStart'];
                        if (start != null) {
                          _controller
                            ..routeStartLat.value = start.latitude
                            ..routeStartLng.value = start.longitude;
                        }
                        // address from the bottom sheet (optional)
                        final startAddress =
                            values['routeStartAddress'] as String?;
                        _controller.routeStartAddress.value = startAddress;
                        _controller.operatingDays.value =
                            values['operatingDays'] as String?;
                        // Extra notes are optional; use empty string if null.
                        _controller.extraNotes.value =
                            (values['notes'] as String?) ?? '';
                        _controller.isActive.value =
                            values['active'] as bool? ?? true;

                        await _controller.saveServiceDetails();
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
                          final serviceDetails = await LocalStorage.getJson(
                            StorageKeys.driverServiceDetails,
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
                          print(
                            'driverIdentification: ${identification ?? {}}',
                          );
                          // ignore: avoid_print
                          print('vehicleRegistration: ${vehicle ?? {}}');
                          // ignore: avoid_print
                          print('serviceDetails: ${serviceDetails ?? {}}');
                          // ignore: avoid_print
                          print('--- end onboarding data ---');
                        } catch (e) {
                          // ignore: avoid_print
                          print('Failed to print onboarding data: $e');
                        }

                        Get.offAllNamed(AppRoutes.driverMap);
                      },
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
                currentStep: 5,
                totalSteps: 5,
                onNext: () {
                  _formWidgetKey.currentState?.submit();
                },
                onPrevious: () => Get.offNamed(AppRoutes.vehicleRegistration),
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
