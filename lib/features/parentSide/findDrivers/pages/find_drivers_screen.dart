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
            child: DefaultTabController(
              length: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Leave vertical space below the overlaid drawer button for consistency
                  SizedBox(
                    height: Responsive.scaleClamped(context, 60, 48, 72),
                  ),

                  // Screen title
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                    child: Text(
                      'Find Drivers',
                      style: AppTypography.optionHeading,
                    ),
                  ),

                  // Tabs: Find | Requested
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grayLight, width: 1),
                    ),
                    child: const TabBar(
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.black54,
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(text: 'Find'),
                        Tab(text: 'Requested'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tab content
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Find tab: current data with Request action
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              DriverListingTile(data: demo),
                              // Add more tiles here if required
                            ],
                          ),
                        ),

                        // Requested tab: same data but button shows "Requested"
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              DriverListingTile(data: demo, isRequested: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: AppColors.white,
      ),
    );
  }
}
