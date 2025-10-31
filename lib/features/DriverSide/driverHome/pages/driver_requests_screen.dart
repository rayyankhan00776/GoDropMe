import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/features/driverSide/common widgets/driver_drawer_shell.dart';
import 'package:godropme/features/driverSide/driverHome/controllers/driver_requests_controller.dart';
import 'package:godropme/features/driverSide/driverHome/widgets/driver_request_tile.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';

class DriverRequestsScreen extends StatelessWidget {
  const DriverRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(DriverRequestsController(), permanent: false);
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
                  child: Text('Requests', style: AppTypography.optionHeading),
                ),
                Expanded(
                  child: Obx(() {
                    final items = ctrl.requests;
                    if (items.isEmpty) {
                      return Center(
                        child: Text(
                          'No requests yet',
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
                        final req = items[i];
                        return DriverRequestTile(
                          data: req,
                          onAccept: () => ctrl.accept(req.id),
                          onReject: () => ctrl.reject(req.id),
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
