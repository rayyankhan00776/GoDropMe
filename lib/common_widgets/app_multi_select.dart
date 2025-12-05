import 'package:flutter/material.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/constants/app_strings.dart';
import 'package:godropme/shared/bottom_sheets/multi_select_bottom_sheet.dart';

/// Shared multi-select field that opens a bottom sheet and displays
/// a compact summary of selected items.
class AppMultiSelect extends StatelessWidget {
  final String hint;
  final List<String> items;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;
  final double height;

  const AppMultiSelect({
    super.key,
    required this.hint,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.height = 56,
  });

  String _summary() {
    if (selected.isEmpty) return AppStrings.tapToSelect;
    if (selected.length <= 2) return selected.join(', ');
    return '${selected.take(2).join(', ')}  +${selected.length - 2} more';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final res = await showMultiSelectBottomSheet(
            context: context,
            title: hint,
            items: items,
            initiallySelected: selected,
          );
          if (res != null) onChanged(res);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: AppColors.gray, width: 2),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            isDense: true,
            filled: true,
            fillColor: AppColors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _summary(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: selected.isEmpty
                      ? AppTypography.optionTerms
                      : AppTypography.optionLineSecondary.copyWith(
                          color: AppColors.black,
                        ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.darkGray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
