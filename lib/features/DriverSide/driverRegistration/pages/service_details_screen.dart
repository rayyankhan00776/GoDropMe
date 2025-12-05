import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/common_widgets/custom_Appbar.dart';
import 'package:godropme/common_widgets/progress_next_bar.dart';
import 'package:godropme/services/appwrite/driver_registration_service.dart';
import 'package:godropme/sharedPrefs/local_storage.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/features/DriverSide/driverRegistration/controllers/service_details_controller.dart';
import 'package:godropme/features/DriverSide/driverRegistration/widgets/serviceDetails/service_details_form.dart';
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
                        onPressed: () => Get.back(),
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
                        // Extract schools data - store IDs for database
                        final schoolsData = (values['schools'] as List?) ?? [];
                        final schoolIds = <String>[];
                        final schoolNames = <String>[]; // For display/debug only
                        
                        for (final s in schoolsData) {
                          if (s is Map) {
                            final id = s['id']?.toString() ?? '';
                            final name = s['name']?.toString() ?? '';
                            
                            if (id.isNotEmpty) {
                              schoolIds.add(id);
                              schoolNames.add(name); // For controller display
                            }
                          }
                        }
                        _controller.selectedSchools.assignAll(schoolNames);
                        
                        // Service category (Male/Female/Both)
                        final serviceCategory = values['serviceCategory'] as String?;
                        _controller.serviceCategory.value = serviceCategory;
                        
                        final center = values['serviceAreaCenter'];
                        List<double>? centerPoint;
                        if (center != null) {
                          _controller
                            ..routeStartLat.value = center.latitude
                            ..routeStartLng.value = center.longitude;
                          // Store as [lng, lat] for Appwrite point type
                          centerPoint = [center.longitude, center.latitude];
                        }
                        // address from the bottom sheet (optional)
                        final serviceAreaAddress =
                            values['serviceAreaAddress'] as String?;
                        _controller.routeStartAddress.value = serviceAreaAddress;
                        // service area polygon data - convert to Appwrite polygon format
                        // Appwrite polygon: [[[lng, lat], [lng, lat], ..., [lng, lat]]] (3D array)
                        // - Outer array holds linear rings
                        // - First ring is exterior boundary
                        // - Ring must be closed (first point = last point)
                        final radiusKm = values['serviceAreaRadiusKm'] as double?;
                        final rawPolygon = values['serviceAreaPolygon'] as List?;
                        final ringPoints = rawPolygon
                                ?.whereType<Map>()
                                .map((e) {
                                  final lat = (e['lat'] as num?)?.toDouble();
                                  final lng = (e['lng'] as num?)?.toDouble();
                                  if (lat != null && lng != null) {
                                    return [lng, lat]; // [lng, lat] for Appwrite point
                                  }
                                  return null;
                                })
                                .whereType<List<double>>()
                                .toList() ??
                            <List<double>>[];
                        
                        // Ensure polygon ring is closed (first point = last point)
                        List<List<List<double>>>? polygon;
                        if (ringPoints.isNotEmpty) {
                          final ring = List<List<double>>.from(ringPoints);
                          // Close the ring if not already closed
                          if (ring.first[0] != ring.last[0] || ring.first[1] != ring.last[1]) {
                            ring.add(List<double>.from(ring.first));
                          }
                          polygon = [ring]; // Wrap in outer array for Appwrite polygon format
                        }
                        // Monthly service price in PKR
                        final monthlyPricePkr = values['monthlyPricePkr'] as int? ?? 0;
                        _controller.monthlyPricePkr.value = monthlyPricePkr;
                        // Extra notes are optional; use empty string if null.
                        _controller.extraNotes.value =
                            (values['notes'] as String?) ?? '';

                        // Save service details using Appwrite-compatible flat types
                        await LocalStorage.setJson(
                          StorageKeys.driverServiceDetails,
                          {
                            // School IDs - foreign keys to schools table
                            'schoolIds': schoolIds,
                            'serviceCategory': serviceCategory, // 'Male', 'Female', or 'Both'
                            'serviceAreaCenter': centerPoint, // [lng, lat] for Appwrite point
                            'serviceAreaAddress': _controller.routeStartAddress.value,
                            'serviceAreaRadiusKm': radiusKm,
                            'serviceAreaPolygon': polygon, // Array of [lng, lat] for Appwrite polygon
                            'monthlyPricePkr': monthlyPricePkr,
                            'extraNotes': _controller.extraNotes.value,
                          },
                        );
                        
                        // Submit registration to Appwrite
                        // Show loading indicator
                        Get.dialog(
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                          barrierDismissible: false,
                        );
                        
                        try {
                          final result = await DriverRegistrationService.instance.submitRegistration();
                          
                          // Close loading dialog
                          if (Get.isDialogOpen ?? false) {
                            Get.back();
                          }
                          
                          if (result.success) {
                            // Clear local data after successful submission
                            await DriverRegistrationService.instance.clearLocalData();
                            
                            // Navigate to pending approval screen
                            // Driver will wait for admin approval (12-24 hrs)
                            Get.offAllNamed(AppRoutes.driverPendingApproval);
                          } else {
                            // Show error message
                            Get.snackbar(
                              'Registration Failed',
                              result.message ?? 'Please try again',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red.shade100,
                              colorText: Colors.red.shade900,
                              duration: const Duration(seconds: 4),
                            );
                          }
                        } catch (e) {
                          // Close loading dialog
                          if (Get.isDialogOpen ?? false) {
                            Get.back();
                          }
                          
                          Get.snackbar(
                            'Error',
                            'Something went wrong. Please try again.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.shade100,
                            colorText: Colors.red.shade900,
                          );
                          debugPrint('Registration error: $e');
                        }
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
                onPrevious: () => Get.back(),
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
