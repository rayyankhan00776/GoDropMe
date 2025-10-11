// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';

class VehicleSelectionItem extends StatelessWidget {
  final String asset;
  final String label;
  final VoidCallback? onTap;

  const VehicleSelectionItem({
    required this.asset,
    required this.label,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.transparent,
              child: SvgPicture.asset(
                asset,
                width: 48,
                height: 48,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: Responsive.scaleClamped(context, 12, 8, 20)),
            Expanded(
              child: Text(label, style: AppTypography.optionLineSecondary),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: AppColors.darkGray,
            ),
          ],
        ),
      ),
    );
  }
}
