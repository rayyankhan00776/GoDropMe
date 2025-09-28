import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/core/routes/routes.dart';
import 'package:godropme/core/theme/colors.dart';
import 'package:godropme/core/utils/app_strings.dart';
import 'package:godropme/core/utils/app_typography.dart';
import 'package:godropme/core/utils/responsive.dart';
import 'package:godropme/core/widgets/custom_Appbar.dart';
import 'package:godropme/core/widgets/progress_next_bar.dart';

class DriverLicenceScreen extends StatefulWidget {
  const DriverLicenceScreen({super.key});

  @override
  State<DriverLicenceScreen> createState() => _DriverLicenceScreenState();
}

class _DriverLicenceScreenState extends State<DriverLicenceScreen> {
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
                  setState(() {});
                  // Navigate to next screen
                },
                onPrevious: null,
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
