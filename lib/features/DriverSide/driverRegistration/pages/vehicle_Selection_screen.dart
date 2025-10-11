// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/routes/routes.dart';
import 'package:godropme/common%20widgets/custom_Appbar.dart';
import 'package:godropme/features/DriverSide/driverRegistration/controllers/vehicle_selection_controller.dart';
import 'package:godropme/utils/app_assets.dart';
import 'package:godropme/utils/app_strings.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/core/theme/colors.dart';
import 'package:godropme/features/DriverSide/driverRegistration/widgets/vehicleSelection/vehicle_selection_item.dart';
import 'package:godropme/utils/responsive.dart';

class VehicleSelectionScreen extends StatelessWidget {
  const VehicleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VehicleSelectionController>();
    return Scaffold(
      appBar: const CustomBlurAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon-only back button under appbar
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Get.offNamed(AppRoutes.driverName),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 25,
                  color: AppColors.darkGray,
                ),
                splashRadius: 20,
              ),
            ),

            SizedBox(height: Responsive.scaleClamped(context, 8, 6, 12)),

            // Title (shifted slightly to the right)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                AppStrings.chooseVehicleTitle,
                style: AppTypography.optionHeading,
              ),
            ),

            SizedBox(height: Responsive.scaleClamped(context, 18, 12, 28)),

            // Vehicle options as vertical tiles (no border)
            Column(
              children: [
                VehicleSelectionItem(
                  asset: AppAssets.carSvg,
                  label: AppStrings.vehicleCar,
                  onTap: () {
                    controller.select(AppStrings.vehicleCar);
                    controller.saveSelection();
                    // Navigate to personal info screen
                    Get.offNamed(AppRoutes.personalInfo);
                  },
                ),
                SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),
                VehicleSelectionItem(
                  asset: AppAssets.rickshawSvg,
                  label: AppStrings.vehicleRickshaw,
                  onTap: () {
                    controller.select(AppStrings.vehicleRickshaw);
                    controller.saveSelection();
                    // Navigate to personal info screen
                    Get.offNamed(AppRoutes.personalInfo);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
