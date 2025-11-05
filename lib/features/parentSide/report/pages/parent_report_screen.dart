import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/features/parentSide/common widgets/parent_drawer_shell.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/common widgets/custom_button.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/features/parentSide/report/controllers/parent_report_controller.dart';

class ParentReportScreen extends StatefulWidget {
  const ParentReportScreen({super.key});

  @override
  State<ParentReportScreen> createState() => _ParentReportScreenState();
}

class _ParentReportScreenState extends State<ParentReportScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ParentReportController>();
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: ParentDrawerShell(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 56),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check, color: Colors.black, size: 30),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppStrings.reportGuideline1,
                            style: AppTypography.helperSmall.copyWith(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check, color: Colors.black, size: 30),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppStrings.reportGuideline2,
                            style: AppTypography.helperSmall.copyWith(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: height * 0.24,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  decoration: InputDecoration(
                    hintText: AppStrings.reportHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    fillColor: AppColors.white,
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: CustomButton(
                  text: AppStrings.send,
                  borderRadius: BorderRadius.circular(12),
                  width: double.infinity,
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    final ok = await ctrl.submitReport(_controller.text);
                    if (!context.mounted) return;
                    if (ok) {
                      _controller.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(AppStrings.reportSent)),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
