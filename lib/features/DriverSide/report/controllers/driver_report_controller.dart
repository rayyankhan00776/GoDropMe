import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:godropme/services/appwrite/active_service_service.dart';
import 'package:godropme/services/appwrite/appwrite_client.dart';
import 'package:godropme/services/appwrite/database_constants.dart';
import 'package:godropme/services/appwrite/driver_service.dart';
import 'package:godropme/services/appwrite/report_service.dart';

/// Parent info for dropdown selection (driver reporting a parent)
class ParentOption {
  final String parentId;
  final String parentName;
  final String? photoUrl;

  ParentOption({
    required this.parentId,
    required this.parentName,
    this.photoUrl,
  });
}

class DriverReportController extends GetxController {
  final isSending = false.obs;
  final isLoading = false.obs;
  final isLoadingParents = false.obs;
  final reports = <Report>[].obs;
  final selectedReportType = Rxn<ReportType>();
  final driverId = Rxn<String>();
  
  // Parent selection for reporting
  final availableParents = <ParentOption>[].obs;
  final selectedParent = Rxn<ParentOption>();

  @override
  void onInit() {
    super.onInit();
    _loadDriverId();
  }

  Future<void> _loadDriverId() async {
    try {
      final result = await DriverService.instance.getDriver();
      if (result.success && result.driverId != null) {
        driverId.value = result.driverId;
        await Future.wait([
          loadReports(),
          loadParents(),
        ]);
      }
    } catch (e) {
      debugPrint('❌ Failed to load driver ID: $e');
    }
  }

  /// Load parents from driver's active services
  Future<void> loadParents() async {
    if (driverId.value == null) return;

    isLoadingParents.value = true;
    try {
      final result = await ActiveServiceService.instance.getDriverActiveServices(
        driverId: driverId.value!,
      );

      if (result.success) {
        final parents = <ParentOption>[];
        final seenParentIds = <String>{};
        final tablesDB = AppwriteClient.tablesDBService();

        for (final service in result.services) {
          final parentId = service['parentId'] as String?;
          if (parentId == null || seenParentIds.contains(parentId)) continue;
          seenParentIds.add(parentId);

          // Fetch parent info
          String parentName = 'Parent';
          String? photoUrl;

          try {
            final parentRow = await tablesDB.getRow(
              databaseId: AppwriteConfig.databaseId,
              tableId: Collections.parents,
              rowId: parentId,
            );
            parentName = parentRow.data['fullName'] ?? 'Parent';
            photoUrl = parentRow.data['profilePhotoUrl'];
          } catch (e) {
            debugPrint('⚠️ Could not fetch parent $parentId: $e');
          }

          parents.add(ParentOption(
            parentId: parentId,
            parentName: parentName,
            photoUrl: photoUrl,
          ));
        }

        availableParents.assignAll(parents);
        debugPrint('✅ Loaded ${parents.length} parents for reporting');
      }
    } catch (e) {
      debugPrint('❌ Failed to load parents: $e');
    } finally {
      isLoadingParents.value = false;
    }
  }

  void selectParent(ParentOption? parent) {
    selectedParent.value = parent;
  }

  Future<void> loadReports() async {
    if (driverId.value == null) return;
    
    isLoading.value = true;
    try {
      final result = await ReportService.instance.getReports(
        userId: driverId.value!,
        role: ReporterRole.driver,
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
    if (driverId.value == null) {
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
        reporterId: driverId.value!,
        reporterRole: ReporterRole.driver,
        reportType: selectedReportType.value!,
        title: title.trim(),
        description: description.trim(),
        reportedUserId: selectedParent.value?.parentId, // Use selected parent
        tripId: tripId,
        attachmentUrls: attachmentUrls,
      );

      if (result.success) {
        // Clear selections
        selectedReportType.value = null;
        selectedParent.value = null;
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
