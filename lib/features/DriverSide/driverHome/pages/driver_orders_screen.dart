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
                  padding: const EdgeInsets.only(left: 8.0, bottom: 12),
                  child: Text('My Orders', style: AppTypography.optionHeading),
                ),
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
