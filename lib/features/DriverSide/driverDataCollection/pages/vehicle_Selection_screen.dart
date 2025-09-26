// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/core/widgets/custom_Appbar.dart';
import 'package:godropme/core/utils/app_assets.dart';
import 'package:godropme/core/utils/app_strings.dart';
import 'package:godropme/core/utils/app_typography.dart';
import 'package:godropme/core/theme/colors.dart';
import 'package:godropme/features/DriverSide/driverDataCollection/widgets/vehicleSelection/vehicle_selection_item.dart';

class VehicleSelectionScreen extends StatelessWidget {
  const VehicleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                onPressed: () => Get.back(),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 25,
                  color: AppColors.darkGray,
                ),
                splashRadius: 20,
              ),
            ),

            const SizedBox(height: 8),

            // Title (shifted slightly to the right)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                AppStrings.chooseVehicleTitle,
                style: AppTypography.optionHeading,
              ),
            ),

            const SizedBox(height: 18),

            // Vehicle options as vertical tiles (no border)
            Column(
              children: [
                VehicleSelectionItem(
                  asset: AppAssets.carSvg,
                  label: AppStrings.vehicleCar,
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                VehicleSelectionItem(
                  asset: AppAssets.rickshawSvg,
                  label: AppStrings.vehicleRickshaw,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
