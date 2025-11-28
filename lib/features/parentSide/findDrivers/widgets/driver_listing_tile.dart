// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:godropme/features/parentSide/findDrivers/models/driver_listing.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';

class DriverListingTile extends StatefulWidget {
  final DriverListing data;
  final bool isRequested;
  const DriverListingTile({
    super.key,
    required this.data,
    this.isRequested = false,
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
                  _DriverAvatar(asset: d.photoAsset),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.name,
                          style: AppTypography.optionLineSecondary.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${d.vehicle} (${d.vehicleColor})',
                          style: AppTypography.optionTerms,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                  _DetailLine(label: 'Type', value: d.type),
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
                  ),
                  _DetailLine(label: 'Extra Notes', value: d.extraNotes),

                  SizedBox(height: Responsive.scaleClamped(context, 12, 8, 18)),

                  // Action button (Request / Requested)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.isRequested
                          ? null
                          : () {
                              Get.snackbar(
                                'Request',
                                'Request sent (demo)',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.black.withValues(
                                  alpha: 0.85,
                                ),
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(12),
                                borderRadius: 12,
                                duration: const Duration(seconds: 2),
                              );
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
                      child: Text(widget.isRequested ? 'Requested' : 'Request'),
                    ),
                  ),

                  if (widget.isRequested) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
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
}

class _DriverAvatar extends StatelessWidget {
  final String asset;
  const _DriverAvatar({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        asset,
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
  const _DetailLine({required this.label, required this.value});

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
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
