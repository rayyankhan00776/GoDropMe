// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/features/commonFeatures/DriverOrParentOption/widgets/dop_header.dart';
import 'package:godropme/features/commonFeatures/DriverOrParentOption/widgets/dop_illustration.dart';
import 'package:godropme/features/commonFeatures/DriverOrParentOption/widgets/dop_actions.dart';
import 'package:godropme/features/commonFeatures/DriverOrParentOption/controllers/dop_controller.dart';
import 'package:godropme/utils/responsive.dart';

class DopOptionScreen extends StatelessWidget {
  const DopOptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, size: 28),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const DopHeader(),
                        SizedBox(
                          height: Responsive.scaleClamped(context, 6, 6, 14),
                        ),

                        Expanded(
                          child: Center(
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [DopIllustration()],
                              ),
                            ),
                          ),
                        ),

                        DopActions(
                          onContinueParent: () {
                            final c = Get.find<DopOptionController>();
                            c.selectParent();
                            c.continueWithSelection();
                          },
                          onContinueDriver: () {
                            final c = Get.find<DopOptionController>();
                            c.selectDriver();
                            c.continueWithSelection();
                          },
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).viewPadding.bottom + 8,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: Responsive.scaleClamped(context, 12, 8, 28)),
              ],
            );
          },
        ),
      ),
    );
  }
}
