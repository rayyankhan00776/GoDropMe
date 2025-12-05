import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/features/DriverSide/common_widgets/driver_drawer_shell.dart';
import 'package:godropme/features/DriverSide/driverHome/controllers/driver_orders_controller.dart';
import 'package:godropme/features/DriverSide/driverHome/widgets/driver_order_tile.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';

class DriverOrdersScreen extends StatelessWidget {
  const DriverOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(DriverOrdersController(), permanent: false);
    return Scaffold(
      body: DriverDrawerShell(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Responsive.scaleClamped(context, 60, 48, 72)),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 4),
                  child: Text('My Orders', style: AppTypography.optionHeading),
                ),
                // Current window indicator
                Obx(() {
                  final window = ctrl.currentWindow.value;
                  final isMorning = window == 'morning';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isMorning ? Icons.sunny_snowing : Icons.nights_stay_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isMorning ? 'Morning Trips (Home → School)' : 'Afternoon Trips (School → Home)',
                            style: AppTypography.helperSmall.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                Expanded(
                  child: Obx(() {
                    final items = ctrl.orders;
                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          'No active orders',
                          style: AppTypography.helperSmall.copyWith(
                            color: AppColors.darkGray,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final ord = items[i];
                        return DriverOrderTile(
                          data: ord,
                          onChat: () {
                            // TODO: navigate to chat screen with this parent
                          },
                          onPicked: () => ctrl.markPicked(ord.id),
                          onDropped: () => ctrl.markDropped(ord.id),
                          onAbsent: () => ctrl.markAbsent(ord.id),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
