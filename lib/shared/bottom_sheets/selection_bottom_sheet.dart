import 'package:flutter/material.dart';
import 'package:godropme/theme/colors.dart';
import 'package:godropme/utils/app_typography.dart';
import 'package:godropme/constants/app_strings.dart';

/// Shared single-select bottom sheet used across the app.
///
/// Preserves the existing visual design used in feature-specific implementations.
Future<void> showSelectionBottomSheet({
  required BuildContext context,
  required String title,
  required List<String> items,
  required String? selected,
  required ValueChanged<String> onSelect,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    builder: (ctx) {
      final height = MediaQuery.of(ctx).size.height * 0.75;
      return SafeArea(
        top: false,
        child: SizedBox(
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
                      icon: const Icon(Icons.close, color: AppColors.darkGray),
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
                    final isSelected = item == selected;
                    return ListTile(
                      title: Text(
                        item,
                        style: AppTypography.optionLineSecondary.copyWith(
                          color: AppColors.black,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () {
                        onSelect(item);
                        Navigator.of(ctx).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
