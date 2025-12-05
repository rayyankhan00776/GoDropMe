// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:godropme/common_widgets/appwrite_image.dart';
import 'package:godropme/features/DriverSide/common_widgets/drawer widgets/driver_drawer_card.dart';
import 'package:godropme/features/DriverSide/driverHome/models/driver_order.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';

class DriverOrderTile extends StatelessWidget {
  final DriverOrder data;
  final VoidCallback onChat;
  final VoidCallback onPicked;
  final VoidCallback onDropped;
  final VoidCallback? onAbsent;

  const DriverOrderTile({
    super.key,
    required this.data,
    required this.onChat,
    required this.onPicked,
    required this.onDropped,
    this.onAbsent,
  });

  @override
  Widget build(BuildContext context) {
    final scheduled = data.status == DriverOrderStatus.scheduled;
    final enroute = data.status == DriverOrderStatus.driverEnroute;
    final arrived = data.status == DriverOrderStatus.arrived;
    final picked = data.status == DriverOrderStatus.picked;
    final inTransit = data.status == DriverOrderStatus.inTransit;
    final dropped = data.status == DriverOrderStatus.dropped;
    final absent = data.status == DriverOrderStatus.absent;
    final cancelled = data.status == DriverOrderStatus.cancelled;
    
    // Trip is finalized (no more actions possible)
    final isFinalized = dropped || absent || cancelled;
    
    // Picked button: enabled when trip is scheduled/enroute/arrived (not yet picked)
    final canPick = scheduled || enroute || arrived;
    
    // Dropped button: only enabled AFTER picked (sequential flow)
    final canDrop = picked || inTransit;
    
    // Hide "Mark Absent" after picked (child is already picked up) or if finalized
    final hideAbsent = isFinalized || picked || inTransit;

    return DriverDrawerCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _Avatar(name: data.parentName, imageUrl: data.avatarUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.parentName,
                        style: AppTypography.optionLineSecondary.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.schoolName,
                        style: AppTypography.helperSmall.copyWith(
                          color: AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: data.status),
              ],
            ),
            const SizedBox(height: 10),
            _LabeledLine(label: 'Pick', value: data.pickPoint),
            const SizedBox(height: 6),
            _LabeledLine(label: 'Drop', value: data.dropPoint),
            const SizedBox(height: 12),
            // First row: Chat + Picked + Dropped
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onChat,
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('Chat'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // PICKED button: only active before picking
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: canPick ? onPicked : null,
                    icon: Icon(
                      picked || canDrop || isFinalized 
                          ? Icons.check_circle 
                          : Icons.check_circle_outline,
                      size: 18,
                    ),
                    label: Text(picked || canDrop ? 'Picked' : 'Pick Up'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: picked || canDrop
                          ? Colors.green  // Show green when picked
                          : canPick 
                              ? AppColors.primary 
                              : AppColors.darkGray,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // DROPPED button: only active AFTER picked
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: canDrop ? onDropped : null,
                    icon: Icon(
                      dropped ? Icons.flag : Icons.flag_outlined,
                      size: 18,
                    ),
                    label: Text(dropped ? 'Dropped' : 'Drop Off'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dropped
                          ? Colors.green  // Show green when dropped
                          : canDrop 
                              ? AppColors.primary 
                              : AppColors.darkGray,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            // Second row: Absent button (only show if callback provided and not finalized/picked)
            if (onAbsent != null && !hideAbsent) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onAbsent,
                  icon: const Icon(Icons.person_off_outlined, size: 18),
                  label: const Text('Mark Absent'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    foregroundColor: Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final DriverOrderStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final text = switch (status) {
      DriverOrderStatus.scheduled => 'Scheduled',
      DriverOrderStatus.driverEnroute => 'En Route',
      DriverOrderStatus.arrived => 'Arrived',
      DriverOrderStatus.picked => 'Picked',
      DriverOrderStatus.inTransit => 'In Transit',
      DriverOrderStatus.dropped => 'Dropped',
      DriverOrderStatus.cancelled => 'Cancelled',
      DriverOrderStatus.absent => 'Absent',
    };
    final color = switch (status) {
      DriverOrderStatus.scheduled => AppColors.primary,
      DriverOrderStatus.driverEnroute => Colors.blue,
      DriverOrderStatus.arrived => Colors.teal,
      DriverOrderStatus.picked => Colors.orange,
      DriverOrderStatus.inTransit => Colors.purple,
      DriverOrderStatus.dropped => Colors.green,
      DriverOrderStatus.cancelled => Colors.red,
      DriverOrderStatus.absent => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTypography.helperSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LabeledLine extends StatelessWidget {
  final String label;
  final String value;
  const _LabeledLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 44,
          child: Text(
            '$label:',
            style: AppTypography.helperSmall.copyWith(
              color: AppColors.darkGray,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: AppTypography.helperSmall.copyWith(color: AppColors.black),
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  const _Avatar({required this.name, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty
        ? 'P'
        : name
              .trim()
              .split(RegExp(r"\s+"))
              .map((e) => e.isNotEmpty ? e[0] : '')
              .take(2)
              .join()
              .toUpperCase();
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: AppwriteImage(
          imageUrl: imageUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          placeholder: Container(
            width: 48,
            height: 48,
            color: AppColors.grayLight,
            child: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          errorWidget: _buildInitials(initials),
        ),
      );
    }
    return _buildInitials(initials);
  }

  Widget _buildInitials(String initials) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      child: Text(
        initials,
        style: AppTypography.optionLineSecondary.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
