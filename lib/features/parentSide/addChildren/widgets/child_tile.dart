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
import 'child_tile_action_buttons.dart';
import 'selectable_tile_wrapper.dart';

class ChildTile extends StatefulWidget {
  final Map<String, dynamic> childData;
  final VoidCallback? onDelete;
  const ChildTile({super.key, required this.childData, this.onDelete});

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
        return AlertDialog(
          title: const Text('Delete child?'),
          content: const Text(
            'This will remove the child from your device. You can re-add them later. ',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
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
              title: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    ChildTileAvatar(initial: initial),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChildInfoLines(
                        title: title,
                        gender: gender,
                        age: age,
                        school: widget.childData['school']?.toString() ?? '-',
                      ),
                    ),
                  ],
                ),
              ),
              children: [
                const _ItemDivider(),
                const SizedBox(height: 8),
                _IconRow(
                  icon: Icons.place_outlined,
                  label: AppStrings.childPickPointHint,
                  value: widget.childData['pick_point'],
                ),
                const _ItemDivider(),
                _IconRow(
                  icon: Icons.flag_outlined,
                  label: AppStrings.childDropPointHint,
                  value: widget.childData['drop_point'],
                ),
                const _ItemDivider(),
                _IconRow(
                  icon: Icons.family_restroom_outlined,
                  label: AppStrings.childRelationshipHint,
                  value: widget.childData['relationship'],
                ),
                const _ItemDivider(),
                _IconRow(
                  icon: Icons.access_time,
                  label: AppStrings.childPickupTimePref,
                  value:
                      ((widget.childData['pickup_time']
                              ?.toString()
                              .isNotEmpty ??
                          false)
                      ? widget.childData['pickup_time']
                      : AppStrings.timeNotSet),
                ),
                ActionButtonsRow(
                  onFindDriver: () => Get.toNamed(AppRoutes.findDrivers),
                  onDelete: widget.onDelete == null ? null : _confirmDelete,
                ),
              ],
            ),
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
