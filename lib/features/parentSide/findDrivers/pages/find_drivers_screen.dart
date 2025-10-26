import 'package:flutter/material.dart';
import 'package:godropme/features/parentSide/common widgets/parent_drawer_shell.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/features/parentSide/findDrivers/models/driver_listing.dart';
import 'package:godropme/features/parentSide/findDrivers/widgets/driver_listing_tile.dart';

class FindDriversScreen extends StatelessWidget {
  const FindDriversScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final demo = DriverListing.demo();

    return ParentDrawerShell(
      body: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leave vertical space below the overlaid drawer button for consistency
                SizedBox(height: Responsive.scaleClamped(context, 60, 48, 72)),

                // Screen title
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 12),
                  child: Text(
                    'Find Drivers',
                    style: AppTypography.optionHeading,
                  ),
                ),

                // One dummy driver card (expandable)
                DriverListingTile(data: demo),

                // If more are needed, list them here with spacing
                // SizedBox(height: 12),
                // DriverListingTile(data: anotherDemo),
              ],
            ),
          ),
        ),
        backgroundColor: AppColors.white,
      ),
    );
  }
}
