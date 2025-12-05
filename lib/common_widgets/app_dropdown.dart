import 'package:flutter/material.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/shared/bottom_sheets/selection_bottom_sheet.dart';

/// App-wide dropdown field that uses a bottom sheet for selection.
/// Matches the visual pattern used across forms and hides inline
/// error text (prefer a separate FormErrorLine for global messages).
class AppDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String> onSelect;
  final bool enabled;
  final double height;

  const AppDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onSelect,
    this.enabled = true,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final display = value?.isNotEmpty == true ? value! : hint;
    final isHint = value == null || value!.isEmpty;

    return SizedBox(
      width: double.infinity,
      height: height,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled
            ? () async {
                await showSelectionBottomSheet(
                  context: context,
                  title: hint,
                  items: items,
                  selected: value,
                  onSelect: onSelect,
                );
              }
            : null,
        child: InputDecorator(
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gray, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.grayLight,
                width: 2,
              ),
            ),
            isDense: true,
            filled: true,
            fillColor: AppColors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  display,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isHint
                      ? AppTypography.optionTerms
                      : AppTypography.optionLineSecondary.copyWith(
                          color: AppColors.black,
                        ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: enabled ? AppColors.darkGray : AppColors.grayLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
