import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/services/appwrite/active_service_service.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/database_constants.dart';
import 'package:godropme/services/appwrite/parent_service.dart';
import 'package:godropme/services/appwrite/report_service.dart';

/// Driver info for dropdown selection
class DriverOption {
  final String driverId;
  final String driverName;
  final String? photoUrl;

  DriverOption({
    required this.driverId,
    required this.driverName,
    this.photoUrl,
  });
}

class ParentReportController extends GetxController {
  final isSending = false.obs;
  final isLoading = false.obs;
  final isLoadingDrivers = false.obs;
  final reports = <Report>[].obs;
  final selectedReportType = Rxn<ReportType>();
  final parentId = Rxn<String>();
  
  // Driver selection for reporting
  final availableDrivers = <DriverOption>[].obs;
  final selectedDriver = Rxn<DriverOption>();

  @override
  void onInit() {
    super.onInit();
    _loadParentId();
  }

  Future<void> _loadParentId() async {
    try {
      final result = await ParentService.instance.getParent();
      if (result.success && result.parent != null) {
        parentId.value = result.parent!.id;
        await Future.wait([
          loadReports(),
          loadDrivers(),
        ]);
      }
    } catch (e) {
      debugPrint('❌ Failed to load parent ID: $e');
    }
  }

  /// Load drivers from parent's active services
  Future<void> loadDrivers() async {
    if (parentId.value == null) return;

    isLoadingDrivers.value = true;
    try {
      final result = await ActiveServiceService.instance.getParentActiveServices(
        parentId: parentId.value!,
      );

      if (result.success) {
        final drivers = <DriverOption>[];
        final seenDriverIds = <String>{};
        final tablesDB = AppwriteClient.tablesDBService();

        for (final service in result.services) {
          final driverId = service['driverId'] as String?;
          if (driverId == null || seenDriverIds.contains(driverId)) continue;
          seenDriverIds.add(driverId);

          // Fetch driver info
          String driverName = 'Driver';
          String? photoUrl;

          try {
            final driverRow = await tablesDB.getRow(
              databaseId: AppwriteConfig.databaseId,
              tableId: Collections.drivers,
              rowId: driverId,
            );
            driverName = driverRow.data['fullName'] ?? 'Driver';
            photoUrl = driverRow.data['profilePhotoUrl'];
          } catch (e) {
            debugPrint('⚠️ Could not fetch driver $driverId: $e');
          }

          drivers.add(DriverOption(
            driverId: driverId,
            driverName: driverName,
            photoUrl: photoUrl,
          ));
        }

        availableDrivers.assignAll(drivers);
        debugPrint('✅ Loaded ${drivers.length} drivers for reporting');
      }
    } catch (e) {
      debugPrint('❌ Failed to load drivers: $e');
    } finally {
      isLoadingDrivers.value = false;
    }
  }

  void selectDriver(DriverOption? driver) {
    selectedDriver.value = driver;
  }

  Future<void> loadReports() async {
    if (parentId.value == null) return;
    
    isLoading.value = true;
    try {
      final result = await ReportService.instance.getReports(
        userId: parentId.value!,
        role: ReporterRole.parent,
      );
      if (result.success) {
        reports.assignAll(result.reports);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitReport({
    required String title,
    required String description,
    String? tripId,
    List<File>? attachments,
  }) async {
    if (parentId.value == null) {
      Get.snackbar('Error', 'Please login to submit a report');
      return false;
    }

    if (selectedReportType.value == null) {
      Get.snackbar('Error', 'Please select a report type');
      return false;
    }

    if (title.trim().isEmpty) {
      Get.snackbar('Error', 'Please provide a title');
      return false;
    }

    if (description.trim().isEmpty) {
      Get.snackbar('Error', 'Please provide a description');
      return false;
    }

    isSending.value = true;
    try {
      // Upload attachments first
      List<String>? attachmentUrls;
      if (attachments != null && attachments.isNotEmpty) {
        attachmentUrls = await ReportService.instance.uploadAttachments(attachments);
      }

      final result = await ReportService.instance.submitReport(
        reporterId: parentId.value!,
        reporterRole: ReporterRole.parent,
        reportType: selectedReportType.value!,
        title: title.trim(),
        description: description.trim(),
        reportedUserId: selectedDriver.value?.driverId, // Use selected driver
        tripId: tripId,
        attachmentUrls: attachmentUrls,
      );

      if (result.success) {
        // Clear selections
        selectedReportType.value = null;
        selectedDriver.value = null;
        // Reload reports
        await loadReports();
        return true;
      } else {
        Get.snackbar('Error', result.message);
        return false;
      }
    } finally {
      isSending.value = false;
    }
  }

  void setReportType(ReportType type) {
    selectedReportType.value = type;
  }
}
