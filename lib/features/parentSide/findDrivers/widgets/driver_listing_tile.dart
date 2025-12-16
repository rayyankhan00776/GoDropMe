// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:godropme/features/parentSide/findDrivers/models/driver_listing.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/common_widgets/appwrite_image.dart';

class DriverListingTile extends StatefulWidget {
  final DriverListing data;
  final bool isRequested;
  /// Selected child ID for the request
  final String? selectedChildId;
  /// Selected child name for display
  final String? selectedChildName;
  /// Callback when user sends a request
  final VoidCallback? onSendRequest;
  /// Callback when user cancels a request
  final VoidCallback? onCancelRequest;
  
  const DriverListingTile({
    super.key,
    required this.data,
    this.isRequested = false,
    this.selectedChildId,
    this.selectedChildName,
    this.onSendRequest,
    this.onCancelRequest,
  });

  @override
  State<DriverListingTile> createState() => _DriverListingTileState();
}

class _DriverListingTileState extends State<DriverListingTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grayLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  _DriverAvatar(
                    asset: d.photoAsset,
                    photoUrl: d.profilePhotoFileId,
                    name: d.name,
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
                                d.name,
                                style: AppTypography.optionLineSecondary.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Rating badge
                            if (d.rating > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber.shade700,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      d.rating.toStringAsFixed(1),
                                      style: AppTypography.helperSmall.copyWith(
                                        color: Colors.amber.shade800,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.directions_car,
                              size: 14,
                              color: AppColors.darkGray,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                d.vehicle.isNotEmpty 
                                    ? d.vehicle
                                    : '${d.type}',
                                style: AppTypography.optionTerms.copyWith(
                                  color: AppColors.darkGray,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.darkGray,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),

          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 16),
                  _DetailLine(label: 'Vehicle Type', value: d.type),
                  _DetailLine(
                    label: 'Seats Available',
                    value: d.seatsAvailable.toString(),
                  ),
                  _DetailLine(label: 'Serving', value: d.serving),
                  _DetailLine(label: 'Service Area', value: d.serviceArea),
                  _DetailLine(label: 'Service For', value: '${d.serviceCategory} Students'),
                  _DetailLine(
                    label: 'Monthly Price',
                    value: 'Rs. ${d.monthlyPricePkr.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                    highlight: true,
                  ),

                  SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),

                  // Action button (Request / Requested)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.isRequested
                          ? null
                          : () {
                              if (widget.onSendRequest != null) {
                                widget.onSendRequest!();
                              } else {
                                _handleRequest(context);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isRequested
                            ? AppColors.grayLight
                            : AppColors.primary,
                        foregroundColor: widget.isRequested
                            ? AppColors.darkGray
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(widget.isRequested ? 'Requested' : 'Request Service'),
                    ),
                  ),

                  if (widget.isRequested) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          if (widget.onCancelRequest != null) {
                            widget.onCancelRequest!();
                          } else {
                            Get.snackbar(
                              'Request',
                              'Request cancelled (demo)',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.black.withValues(
                                alpha: 0.85,
                              ),
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(12),
                              borderRadius: 12,
                              duration: const Duration(seconds: 2),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(
                            color: AppColors.primary,
                            width: 1.2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel Request'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _handleRequest(BuildContext context) {
    final d = widget.data;
    
    // One-click request - just show snackbar confirmation
    Get.snackbar(
      'Request Sent',
      'Your request has been sent to ${d.name}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }
}

class _DriverAvatar extends StatelessWidget {
  final String asset;
  final String? photoUrl;
  final String name;
  
  const _DriverAvatar({
    required this.asset,
    this.photoUrl,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    // Use Appwrite image if available
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipOval(
        child: AppwriteImage(
          imageUrl: photoUrl!,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          placeholder: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'D',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    // Fallback to SVG asset
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        asset.isNotEmpty ? asset : 'assets/images/svg/person.svg',
        width: 28,
        height: 28,
        color: AppColors.primary,
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  
  const _DetailLine({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(
              '$label:',
              style: AppTypography.optionTerms.copyWith(
                color: AppColors.gray,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTypography.optionLineSecondary.copyWith(
                fontSize: 14,
                color: highlight ? AppColors.primary : AppColors.black,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
