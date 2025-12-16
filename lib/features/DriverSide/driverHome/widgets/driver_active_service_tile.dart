// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:godropme/features/DriverSide/common_widgets/drawer widgets/driver_drawer_card.dart';
import 'package:godropme/features/DriverSide/driverHome/models/driver_active_service.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/common_widgets/appwrite_image.dart';

/// Tile widget for driver's active service display.
class DriverActiveServiceTile extends StatelessWidget {
  final DriverActiveService data;
  final VoidCallback onEndService;

  const DriverActiveServiceTile({
    super.key,
    required this.data,
    required this.onEndService,
  });

  @override
  Widget build(BuildContext context) {
    return DriverDrawerCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Parent info + status badge
            Row(
              children: [
                _Avatar(
                  name: data.parentName,
                  photoUrl: data.parentPhotoUrl,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data.parentName,
                              style: AppTypography.optionLineSecondary.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _StatusBadge(status: data.status),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.schoolName,
                        style: AppTypography.helperSmall.copyWith(
                          color: AppColors.darkGray,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 20),

            // Child info
            _DetailLine(
              label: 'Child',
              value: [
                data.childName,
                if (data.childAge != null) '${data.childAge} yrs',
                if (data.childGender != null) data.childGender,
              ].where((s) => s != null && s.isNotEmpty).join(' • '),
            ),
            const SizedBox(height: 4),

            // Pick & Drop info
            _LocationLine(
              label: 'Pick',
              icon: Icons.radio_button_checked,
              iconColor: Colors.green,
              value: _cleanAddress(data.pickPoint),
            ),
            const SizedBox(height: 4),
            _LocationLine(
              label: 'Drop',
              icon: Icons.location_on,
              iconColor: Colors.red,
              value: _cleanAddress(data.dropPoint),
            ),

            const SizedBox(height: 10),
            
            // Monthly fee display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Monthly Fee',
                    style: AppTypography.helperSmall.copyWith(
                      color: AppColors.darkGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Rs. ${_formatPrice(data.monthlyFeePkr)}/month',
                    style: AppTypography.optionLineSecondary.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Start date
            if (data.startDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: AppColors.darkGray,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Started: ${_formatDate(data.startDate!)}',
                    style: AppTypography.helperSmall.copyWith(
                      color: AppColors.darkGray,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 14),

            // End service button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onEndService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text('End Service'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  /// Clean address by removing coordinate prefixes (e.g., "2HCQ+R88, ")
  String _cleanAddress(String address) {
    if (address.isEmpty) return address;
    // Remove patterns like "2HCQ+R88, " at the start
    final cleaned = address.replaceFirst(RegExp(r'^[A-Z0-9]{4}\+[A-Z0-9]{3},\s*'), '');
    return cleaned.isEmpty ? address : cleaned;
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String? photoUrl;

  const _Avatar({
    required this.name,
    this.photoUrl,
  });

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

    // Use Appwrite image if available
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipOval(
        child: AppwriteImage(
          imageUrl: photoUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          placeholder: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          errorWidget: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: AppTypography.optionLineSecondary.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }

    // Fallback to initials
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

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'active':
        bgColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green.shade700;
        label = 'Active';
        break;
      case 'paused':
        bgColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange.shade700;
        label = 'Paused';
        break;
      case 'ended':
        bgColor = AppColors.grayLight;
        textColor = AppColors.darkGray;
        label = 'Ended';
        break;
      default:
        bgColor = AppColors.grayLight;
        textColor = AppColors.darkGray;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTypography.helperSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({required this.label, required this.value});

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

/// Location line widget with icon
class _LocationLine extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  
  const _LocationLine({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 6),
        SizedBox(
          width: 36,
          child: Text(
            '$label:',
            style: AppTypography.helperSmall.copyWith(
              color: AppColors.darkGray,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: AppTypography.helperSmall.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
