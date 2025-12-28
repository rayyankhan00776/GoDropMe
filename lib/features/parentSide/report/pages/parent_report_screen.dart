// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:godropme/common_widgets/appwrite_image.dart';
import 'package:godropme/features/parentSide/common_widgets/parent_drawer_shell.dart';
import 'package:godropme/features/parentSide/report/controllers/parent_report_controller.dart';
import 'package:godropme/services/appwrite/report_service.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';

class ParentReportScreen extends StatefulWidget {
  const ParentReportScreen({super.key});

  @override
  State<ParentReportScreen> createState() => _ParentReportScreenState();
}

class _ParentReportScreenState extends State<ParentReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _attachments = <File>[].obs;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ParentReportController>();

    return Scaffold(
      body: ParentDrawerShell(
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 64),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text('Report & Feedback',
                        style: AppTypography.optionHeading),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Tab bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.grayLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.darkGray,
                  labelStyle: AppTypography.helperSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'New Report'),
                    Tab(text: 'My Reports'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNewReportTab(ctrl),
                    _buildMyReportsTab(ctrl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewReportTab(ParentReportController ctrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Guidelines
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Guidelines',
                  style: AppTypography.helperSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildGuideline('Be specific about the incident'),
                _buildGuideline('Include date and time if applicable'),
                _buildGuideline('Attach photos or evidence if available'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Report type selection
          Text(
            'Report Type *',
            style: AppTypography.helperSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ReportType.values.map((type) {
              return Obx(() {
                final isSelected = ctrl.selectedReportType.value == type;
                return GestureDetector(
                  onTap: () => ctrl.setReportType(type),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.grayLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? null
                          : Border.all(color: AppColors.grayLight),
                    ),
                    child: Text(
                      type.displayName,
                      style: AppTypography.helperSmall.copyWith(
                        color: isSelected ? Colors.white : AppColors.darkGray,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              });
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Driver selection (optional - for reporting a specific driver)
          Text(
            'Report Driver (Optional)',
            style: AppTypography.helperSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            if (ctrl.isLoadingDrivers.value) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grayLight),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }

            if (ctrl.availableDrivers.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.grayLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: AppColors.gray),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No active drivers found. You can still submit a general report.',
                        style: AppTypography.helperSmall.copyWith(
                          color: AppColors.gray,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.grayLight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<DriverOption>(
                  value: ctrl.selectedDriver.value,
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  hint: Text(
                    'Select a driver (optional)',
                    style: AppTypography.helperSmall.copyWith(
                      color: AppColors.gray,
                    ),
                  ),
                  icon: Icon(Icons.keyboard_arrow_down, color: AppColors.gray),
                  items: [
                    // Add "None" option to clear selection
                    DropdownMenuItem<DriverOption>(
                      value: null,
                      child: Text(
                        'General Report (No specific driver)',
                        style: AppTypography.helperSmall.copyWith(
                          color: AppColors.gray,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    ...ctrl.availableDrivers.map((driver) {
                      return DropdownMenuItem<DriverOption>(
                        value: driver,
                        child: Row(
                          children: [
                            _DriverAvatar(
                              photoUrl: driver.photoUrl,
                              name: driver.driverName,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              driver.driverName,
                              style: AppTypography.helperSmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) => ctrl.selectDriver(value),
                ),
              ),
            );
          }),
          const SizedBox(height: 20),

          // Title
          Text(
            'Title *',
            style: AppTypography.helperSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            maxLength: 150,
            decoration: InputDecoration(
              hintText: 'Brief summary of the issue',
              hintStyle: AppTypography.helperSmall.copyWith(
                color: AppColors.gray,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.grayLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
              counterText: '',
            ),
          ),
          const SizedBox(height: 20),

          // Description
          Text(
            'Description *',
            style: AppTypography.helperSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            maxLines: 5,
            maxLength: 2000,
            decoration: InputDecoration(
              hintText: 'Describe the incident in detail...',
              hintStyle: AppTypography.helperSmall.copyWith(
                color: AppColors.gray,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.grayLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 20),

          // Attachments
          Text(
            'Attachments (Optional)',
            style: AppTypography.helperSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._attachments.map((file) => _buildAttachmentTile(file)),
                  if (_attachments.length < 5) _buildAddAttachmentButton(),
                ],
              )),
          const SizedBox(height: 32),

          // Submit button
          Obx(() => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: ctrl.isSending.value ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: ctrl.isSending.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit Report',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMyReportsTab(ParentReportController ctrl) {
    return Obx(() {
      if (ctrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (ctrl.reports.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: AppColors.grayLight),
              const SizedBox(height: 16),
              Text(
                'No reports yet',
                style: AppTypography.optionLineSecondary.copyWith(
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your submitted reports will appear here',
                style: AppTypography.helperSmall.copyWith(
                  color: AppColors.gray,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: ctrl.loadReports,
        color: AppColors.primary,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: ctrl.reports.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final report = ctrl.reports[index];
            return _ReportTile(report: report);
          },
        ),
      );
    });
  }

  Widget _buildGuideline(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.helperSmall.copyWith(
                color: AppColors.darkGray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentTile(File file) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            file,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _attachments.remove(file),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddAttachmentButton() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.grayLight.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.grayLight,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                color: AppColors.darkGray, size: 24),
            const SizedBox(height: 4),
            Text(
              'Add',
              style: AppTypography.helperSmall.copyWith(
                color: AppColors.darkGray,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      _attachments.add(File(picked.path));
    }
  }

  Future<void> _submitReport() async {
    FocusScope.of(context).unfocus();
    final ctrl = Get.find<ParentReportController>();

    final success = await ctrl.submitReport(
      title: _titleController.text,
      description: _descriptionController.text,
      attachments: _attachments.isNotEmpty ? _attachments.toList() : null,
    );

    if (success) {
      _titleController.clear();
      _descriptionController.clear();
      _attachments.clear();
      _tabController.animateTo(1); // Switch to My Reports tab

      Get.snackbar(
        'Success',
        'Your report has been submitted. We will review it shortly.',
        backgroundColor: Colors.green.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
      );
    }
  }
}

class _ReportTile extends StatelessWidget {
  final Report report;

  const _ReportTile({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grayLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatusBadge(report.status),
              const Spacer(),
              Text(
                _formatDate(report.createdAt),
                style: AppTypography.helperSmall.copyWith(
                  color: AppColors.gray,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            report.title,
            style: AppTypography.optionLineSecondary.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.grayLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              report.reportType.displayName,
              style: AppTypography.helperSmall.copyWith(
                fontSize: 11,
                color: AppColors.darkGray,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            report.description,
            style: AppTypography.helperSmall.copyWith(
              color: AppColors.darkGray,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (report.attachmentUrls.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.attach_file, size: 14, color: AppColors.gray),
                const SizedBox(width: 4),
                Text(
                  '${report.attachmentUrls.length} attachment(s)',
                  style: AppTypography.helperSmall.copyWith(
                    fontSize: 12,
                    color: AppColors.gray,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ReportStatus status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case ReportStatus.pending:
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case ReportStatus.underReview:
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        break;
      case ReportStatus.resolved:
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case ReportStatus.dismissed:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: AppTypography.helperSmall.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Avatar widget for driver with AppwriteImage support
class _DriverAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double radius;

  const _DriverAvatar({
    required this.photoUrl,
    required this.name,
    // ignore: unused_element_parameter
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipOval(
        child: AppwriteImage(
          imageUrl: photoUrl!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: _buildInitialsAvatar(),
          errorWidget: _buildInitialsAvatar(),
        ),
      );
    }
    return _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'D',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
