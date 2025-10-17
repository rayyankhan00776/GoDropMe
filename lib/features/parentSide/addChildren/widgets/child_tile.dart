// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';

class ChildTile extends StatefulWidget {
  final Map<String, dynamic> childData;
  const ChildTile({super.key, required this.childData});

  @override
  State<ChildTile> createState() => _ChildTileState();
}

class _ChildTileState extends State<ChildTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final title = (widget.childData['name']?.toString() ?? '').isNotEmpty
        ? widget.childData['name'].toString()
        : 'Child';
    final initial = title.isNotEmpty ? title[0].toUpperCase() : 'C';
    final gender = (widget.childData['gender']?.toString() ?? '').trim();
    final age = (widget.childData['age']?.toString() ?? '').trim();

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.grayLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
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
                  // Leading avatar
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: AppColors.gradientPink,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.15),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: AppTypography.optionLineSecondary.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.optionLineSecondary
                                    .copyWith(
                                      color: AppColors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                    ),
                              ),
                            ),
                            if (gender.isNotEmpty) const SizedBox(width: 6),
                            if (gender.isNotEmpty) _Pill(text: gender),
                            if (age.isNotEmpty) const SizedBox(width: 6),
                            if (age.isNotEmpty) _Pill(text: '${age}y'),
                          ],
                        ),
                        const SizedBox(height: 2),
                        _MetaRow(
                          icon: Icons.school_outlined,
                          text: widget.childData['school']?.toString() ?? '-',
                        ),
                      ],
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
                    ((widget.childData['pickup_time']?.toString().isNotEmpty ??
                        false)
                    ? widget.childData['pickup_time']
                    : AppStrings.timeNotSet),
              ),
              SizedBox(height: Responsive.scaleClamped(context, 8, 6, 12)),
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

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppTypography.optionTerms.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.gray),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text.isEmpty ? '-' : text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.optionTerms.copyWith(color: AppColors.gray),
          ),
        ),
      ],
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
              color: AppColors.primary.withOpacity(0.1),
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
