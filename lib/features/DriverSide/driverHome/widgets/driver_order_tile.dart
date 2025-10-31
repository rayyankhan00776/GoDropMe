// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:godropme/features/driverSide/common widgets/drawer widgets/driver_drawer_card.dart';
import 'package:godropme/features/driverSide/driverHome/models/driver_order.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';

class DriverOrderTile extends StatelessWidget {
  final DriverOrder data;
  final VoidCallback onChat;
  final VoidCallback onPicked;
  final VoidCallback onDropped;

  const DriverOrderTile({
    super.key,
    required this.data,
    required this.onChat,
    required this.onPicked,
    required this.onDropped,
  });

  @override
  Widget build(BuildContext context) {
    final picked = data.status == DriverOrderStatus.picked;
    final dropped = data.status == DriverOrderStatus.dropped;

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
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: dropped ? null : onPicked,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Picked'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: picked || dropped
                          ? AppColors.darkGray
                          : AppColors.primary,
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
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: dropped ? null : onDropped,
                    icon: const Icon(Icons.flag_outlined, size: 18),
                    label: const Text('Dropped'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: dropped
                          ? AppColors.darkGray
                          : AppColors.primary,
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
      DriverOrderStatus.pendingPickup => 'Pending',
      DriverOrderStatus.picked => 'Picked',
      DriverOrderStatus.dropped => 'Dropped',
    };
    final color = switch (status) {
      DriverOrderStatus.pendingPickup => AppColors.primary,
      DriverOrderStatus.picked => Colors.orange,
      DriverOrderStatus.dropped => Colors.green,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
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
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(imageUrl!),
        backgroundColor: AppColors.grayLight,
      );
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primary.withOpacity(0.1),
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
