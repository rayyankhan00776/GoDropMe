// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:get/get.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'child_tile_helpers.dart';
import 'child_tile_avatar.dart';
import 'child_info_lines.dart';
import 'selectable_tile_wrapper.dart';

class ChildTile extends StatefulWidget {
  final Map<String, dynamic> childData;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkAbsent;
  final bool isAbsentToday;
  
  const ChildTile({
    super.key, 
    required this.childData, 
    this.onDelete,
    this.onMarkAbsent,
    this.isAbsentToday = false,
  });

  @override
  State<ChildTile> createState() => _ChildTileState();
}

class _ChildTileState extends State<ChildTile> {
  bool _expanded = false;

  Future<void> _confirmDelete() async {
    if (widget.onDelete == null) return;
    final res = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  'Delete Child?',
                  style: AppTypography.optionHeading.copyWith(
                    color: AppColors.black,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                // Content
                Text(
                  'This will remove the child from your device. You can re-add them later.',
                  textAlign: TextAlign.center,
                  style: AppTypography.optionTerms.copyWith(
                    color: AppColors.darkGray,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.darkGray,
                          side: const BorderSide(color: AppColors.grayLight),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: AppTypography.optionTerms.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGray,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Delete',
                          style: AppTypography.optionTerms.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (res == true) {
      widget.onDelete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = childTitle(widget.childData);
    final initial = childInitial(title);
    final gender = childGender(widget.childData);
    final age = childAge(widget.childData);

    return SelectableTileWrapper(
      selected: false,
      child: Material(
        color: Colors.transparent,
        child: Container(
          // Ensure inner content respects the rounded corners so the border is visible on corners
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          // Paint the border ABOVE the child so ExpansionTile/Material backgrounds can't cover it
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.grayLight, width: 1),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              onExpansionChanged: (v) => setState(() => _expanded = v),
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 2,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              backgroundColor: Colors.white,
              collapsedBackgroundColor: Colors.white,
              iconColor: AppColors.darkGray,
              collapsedIconColor: AppColors.darkGray,
              trailing: AnimatedRotation(
                turns: _expanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 180),
                child: const Icon(Icons.expand_more, color: AppColors.darkGray),
              ),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 80,
                    child: Row(
                      children: [
                        ChildTileAvatar(
                          initial: initial,
                          photoPath: widget.childData['photoPath']?.toString(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChildInfoLines(
                            title: title,
                            gender: gender,
                            age: age,
                            school: widget.childData['schoolName']?.toString() ?? '-',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Quick action buttons row (always visible)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Row(
                      children: [
                        // Mark Absent button
                        if (widget.onMarkAbsent != null)
                          Expanded(
                            child: _QuickActionButton(
                              icon: widget.isAbsentToday 
                                  ? Icons.check_circle 
                                  : Icons.person_off_outlined,
                              label: widget.isAbsentToday ? 'Absent' : 'Mark Absent',
                              isActive: widget.isAbsentToday,
                              activeColor: Colors.orange,
                              onTap: widget.onMarkAbsent!,
                            ),
                          ),
                        if (widget.onMarkAbsent != null) const SizedBox(width: 8),
                        // Find Driver button
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.directions_car_outlined,
                            label: 'Find Driver',
                            onTap: () => Get.toNamed(AppRoutes.findDrivers),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              children: [
                const _ItemDivider(),
                const SizedBox(height: 8),
                _IconRow(
                  icon: Icons.place_outlined,
                  label: AppStrings.childPickPointHint,
                  value: widget.childData['pickPoint'],
                ),
                const _ItemDivider(),
                _IconRow(
                  icon: Icons.flag_outlined,
                  label: AppStrings.childDropPointHint,
                  value: widget.childData['dropPoint'],
                ),
                const _ItemDivider(),
                _IconRow(
                  icon: Icons.family_restroom_outlined,
                  label: AppStrings.childRelationshipHint,
                  value: widget.childData['relationshipToChild'],
                ),
                const _ItemDivider(),
                _IconRow(
                  icon: Icons.access_time,
                  label: AppStrings.childSchoolOpenTime,
                  value:
                      ((widget.childData['schoolOpenTime']
                              ?.toString()
                              .isNotEmpty ??
                          false)
                      ? widget.childData['schoolOpenTime']
                      // Legacy support for old field name
                      : (widget.childData['pickupTime']?.toString().isNotEmpty ?? false)
                          ? widget.childData['pickupTime']
                          : 'Not set'),
                ),
                const _ItemDivider(),
                _IconRow(
                  icon: Icons.access_time_filled,
                  label: AppStrings.childSchoolOffTime,
                  value:
                      ((widget.childData['schoolOffTime']
                              ?.toString()
                              .isNotEmpty ??
                          false)
                      ? widget.childData['schoolOffTime']
                      : 'Not set'),
                ),
                // Delete button (only in expanded section)
                if (widget.onDelete != null) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton.icon(
                      onPressed: _confirmDelete,
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: Text(
                        'Delete',
                        style: AppTypography.optionTerms.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact action button for the quick actions row
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final Color? activeColor;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? (activeColor ?? AppColors.primary) : AppColors.darkGray;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isActive 
                ? color.withValues(alpha: 0.1) 
                : AppColors.grayLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? color : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.helperSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemDivider extends StatelessWidget {
  const _ItemDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Divider(height: 1, thickness: 1, color: AppColors.grayLight),
    );
  }
}

class _IconRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Object? value;
  const _IconRow({required this.icon, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            height: 28,
            width: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.optionTerms.copyWith(
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  (value?.toString() ?? '').isEmpty ? '-' : value.toString(),
                  style: AppTypography.optionLineSecondary.copyWith(
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
