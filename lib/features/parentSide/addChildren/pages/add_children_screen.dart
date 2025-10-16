// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/features/parentSide/common widgets/parent_drawer_shell.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/features/parentSide/addChildren/controllers/add_children_controller.dart';

class AddChildrenScreen extends StatefulWidget {
  const AddChildrenScreen({super.key});

  @override
  State<AddChildrenScreen> createState() => _AddChildrenScreenState();
}

class _AddChildrenScreenState extends State<AddChildrenScreen> {
  late final AddChildrenController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<AddChildrenController>();
  }

  Future<void> _addChild() async {
    await Get.offNamed(AppRoutes.addChildHelp);
    await _ctrl.loadChildren();
  }

  @override
  Widget build(BuildContext context) {
    return ParentDrawerShell(
      body: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Push content below the overlaid drawer button
                SizedBox(height: Responsive.scaleClamped(context, 60, 48, 72)),
                // Optional section title can be re-added here if needed
                SizedBox(height: Responsive.scaleClamped(context, 18, 12, 24)),

                // Content (reactive)
                Expanded(
                  child: Obx(() {
                    if (_ctrl.children.isEmpty) {
                      return Center(
                        child: Text(
                          AppStrings.noChildrenAdded,
                          style: AppTypography.optionLineSecondary,
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            AppStrings.yourChildren,
                            style: AppTypography.optionHeading,
                          ),
                        ),
                        SizedBox(
                          height: Responsive.scaleClamped(context, 18, 12, 24),
                        ),
                        Expanded(
                          child: ListView.separated(
                            itemCount: _ctrl.children.length,
                            separatorBuilder: (_, __) => SizedBox(
                              height: Responsive.scaleClamped(
                                context,
                                12,
                                8,
                                18,
                              ),
                            ),
                            itemBuilder: (context, index) {
                              final c = _ctrl.children[index];
                              return _ChildTile(childData: c);
                            },
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addChild,
          backgroundColor: AppColors.primary.withOpacity(0.9),
          shape: CircleBorder(
            side: BorderSide(
              color: AppColors.primaryDark.withOpacity(0.8),
              width: 0.6,
            ),
          ),
          child: const Icon(Icons.add, color: AppColors.white),
        ),
      ),
    );
  }
}

class _ChildTile extends StatefulWidget {
  final Map<String, dynamic> childData;
  const _ChildTile({required this.childData});

  @override
  State<_ChildTile> createState() => _ChildTileState();
}

class _ChildTileState extends State<_ChildTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final title = (widget.childData['name']?.toString() ?? '').isNotEmpty
        ? widget.childData['name'].toString()
        : 'Child';
    final initial = title.isNotEmpty ? title[0].toUpperCase() : 'C';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray, width: 2),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (v) => setState(() => _expanded = v),
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
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
            height: 56,
            child: Row(
              children: [
                // Leading circle avatar for visual identity
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryDark.withOpacity(0.8),
                      width: 0.6,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: AppTypography.optionLineSecondary.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.optionLineSecondary.copyWith(
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          children: [
            _RowField(
              label: AppStrings.childAgeHint,
              value: widget.childData['age'],
            ),
            const _ItemDivider(),
            _RowField(
              label: AppStrings.childGenderHint,
              value: widget.childData['gender'],
            ),
            const _ItemDivider(),
            _RowField(
              label: AppStrings.childSchoolHint,
              value: widget.childData['school'],
            ),
            const _ItemDivider(),
            _RowField(
              label: AppStrings.childPickPointHint,
              value: widget.childData['pick_point'],
            ),
            const _ItemDivider(),
            _RowField(
              label: AppStrings.childDropPointHint,
              value: widget.childData['drop_point'],
            ),
            const _ItemDivider(),
            _RowField(
              label: AppStrings.childRelationshipHint,
              value: widget.childData['relationship'],
            ),
            const _ItemDivider(),
            _RowField(
              label: AppStrings.childPickupTimePref,
              value:
                  (widget.childData['pickup_time']?.toString().isNotEmpty ??
                      false)
                  ? widget.childData['pickup_time']
                  : AppStrings.timeNotSet,
            ),
            SizedBox(height: Responsive.scaleClamped(context, 8, 6, 12)),
          ],
        ),
      ),
    );
  }
}

class _RowField extends StatelessWidget {
  final String label;
  final Object? value;
  const _RowField({required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: AppTypography.optionTerms.copyWith(
                color: AppColors.darkGray,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              (value?.toString() ?? '').isEmpty ? '-' : value.toString(),
              style: AppTypography.optionLineSecondary,
            ),
          ),
        ],
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
