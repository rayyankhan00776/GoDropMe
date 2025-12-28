import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/features/DriverSide/common_widgets/driver_drawer_shell.dart';
import 'package:godropme/features/DriverSide/driverHome/models/driver_active_service.dart';
import 'package:godropme/features/DriverSide/driverHome/widgets/driver_active_service_tile.dart';
import 'package:godropme/features/DriverSide/driverHome/controllers/driver_active_services_controller.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/services/appwrite/chat_service.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';

/// Screen for drivers to view and manage their active services.
class DriverActiveServicesScreen extends StatelessWidget {
  const DriverActiveServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(DriverActiveServicesController(), permanent: false);

    return Scaffold(
      body: DriverDrawerShell(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Responsive.scaleClamped(context, 60, 48, 72)),
                
                // Header
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 4),
                  child: Text('Active Services', style: AppTypography.optionHeading),
                ),
                Obx(() => Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 16),
                  child: Text(
                    '${ctrl.activeCount} active service(s)',
                    style: AppTypography.helperSmall.copyWith(
                      color: AppColors.darkGray,
                    ),
                  ),
                )),

                // Services list
                Expanded(
                  child: Obx(() {
                    if (ctrl.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (ctrl.services.isEmpty) {
                      return _buildEmptyState();
                    }
                    
                    return RefreshIndicator(
                      onRefresh: ctrl.refresh,
                      child: ListView.separated(
                        itemCount: ctrl.services.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final service = ctrl.services[i];
                          return DriverActiveServiceTile(
                            data: service,
                            onEndService: () => _showEndServiceDialog(context, ctrl, service),
                            onChat: () => _openChatWithParent(ctrl, service),
                          );
                        },
                      ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: AppColors.grayLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No active services',
            style: AppTypography.optionLineSecondary.copyWith(
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Accept requests to start providing services',
            style: AppTypography.helperSmall.copyWith(
              color: AppColors.gray,
            ),
          ),
        ],
      ),
    );
  }

  void _showEndServiceDialog(BuildContext context, DriverActiveServicesController ctrl, DriverActiveService service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('End Service'),
        content: Text(
          'Are you sure you want to end the service for ${service.childName}?\n\n'
          'Parent: ${service.parentName}\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.darkGray),
            ),
          ),
          Obx(() => ElevatedButton(
            onPressed: ctrl.isEndingService.value ? null : () async {
              final success = await ctrl.endService(service.id);
              if (success && ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),  
            ),
            child: ctrl.isEndingService.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('End Service'),
          )),
        ],
      ),
    );
  }

  /// Open chat with parent for an active service
  Future<void> _openChatWithParent(DriverActiveServicesController ctrl, DriverActiveService service) async {
    final driverId = ctrl.driverId.value;
    final parentId = service.parentId;
    final parentName = service.parentName;
    
    if (driverId == null || parentId.isEmpty) {
      Get.snackbar('Error', 'Unable to start chat. Please try again.');
      return;
    }

    // Show loading indicator
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // Get or create chat room
      final result = await ChatService.instance.getOrCreateChatRoom(
        parentId: parentId,
        driverId: driverId,
      );

      Get.back(); // Close loading dialog

      if (result.success) {
        // Navigate to conversation screen
        Get.toNamed(
          AppRoutes.driverConversation,
          arguments: {
            'contactId': result.chatRoomId,
            'name': parentName,
            'avatarUrl': service.parentPhotoUrl,
          },
        );
      } else {
        Get.snackbar('Error', result.message);
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar('Error', 'Failed to start chat. Please try again.');
    }
  }
}
