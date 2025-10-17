import 'package:flutter/material.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';

class DropdownField extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final VoidCallback onTap;
  final bool enabled;

  const DropdownField({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.onTap,
    this.enabled = true,
  });

  InputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color, width: 2),
  );

  @override
  Widget build(BuildContext context) {
    final display = value?.isNotEmpty == true ? value! : hint;
    final isHint = value == null || value!.isEmpty;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: enabled ? onTap : null,
        child: InputDecorator(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.optionTerms,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            enabledBorder: _border(AppColors.gray),
            focusedBorder: _border(AppColors.primary),
            disabledBorder: _border(AppColors.grayLight),
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
