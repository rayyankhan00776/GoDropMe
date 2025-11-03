// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:godropme/features/parentSide/common widgets/parent_drawer_shell.dart';
import 'package:godropme/routes.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/utils/responsive.dart';
import 'package:godropme/features/parentSide/addChildren/controllers/add_children_controller.dart';
import 'package:godropme/features/parentSide/addChildren/widgets/add_children_header_banner.dart';
import 'package:godropme/features/parentSide/addChildren/widgets/add_children_empty_state.dart';
import 'package:godropme/features/parentSide/addChildren/widgets/children_count_chip.dart';
import 'package:godropme/features/parentSide/addChildren/widgets/child_tile.dart';

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
    await Get.toNamed(AppRoutes.addChildHelp);
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
                // Header banner
                AddChildrenHeaderBanner(onAddChild: _addChild),
                SizedBox(height: Responsive.scaleClamped(context, 14, 10, 20)),

                // Content (reactive)
                Expanded(
                  child: Obx(() {
                    if (_ctrl.children.isEmpty) {
                      return AddChildrenEmptyState(onAddChild: _addChild);
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                          child: Row(
                            children: [
                              Text(
                                AppStrings.yourChildren,
                                style: AppTypography.optionHeading,
                              ),
                              const SizedBox(width: 8),
                              ChildrenCountChip(count: _ctrl.children.length),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            itemCount: _ctrl.children.length,
                            separatorBuilder: (_, __) => SizedBox(
                              height: Responsive.scaleClamped(
                                context,
                                10,
                                8,
                                16,
                              ),
                            ),
                            itemBuilder: (context, index) {
                              final c = _ctrl.children[index];
                              return ChildTile(
                                childData: c,
                                onDelete: () async {
                                  await _ctrl.deleteChild(index);
                                },
                              );
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
      ),
    );
  }
}
