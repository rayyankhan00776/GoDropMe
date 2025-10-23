import 'package:flutter/material.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/constants/app_strings.dart';

Future<List<String>?> showMultiSelectBottomSheet({
  required BuildContext context,
  required String title,
  required List<String> items,
  required List<String> initiallySelected,
}) async {
  final selected = initiallySelected.toSet();
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    builder: (ctx) {
      final height = MediaQuery.of(ctx).size.height * 0.75;
      return SafeArea(
        top: false,
        child: StatefulBuilder(
          builder: (context, setState) => SizedBox(
            height: height,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.optionHeading,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.darkGray,
                        ),
                        tooltip: AppStrings.close,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final item = items[i];
                      final isSelected = selected.contains(item);
                      return CheckboxListTile(
                        title: Text(
                          item,
                          style: AppTypography.optionLineSecondary.copyWith(
                            color: AppColors.black,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                        value: isSelected,
                        activeColor: AppColors.primary,
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              selected.add(item);
                            } else {
                              selected.remove(item);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(selected.toList()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(AppStrings.done),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
