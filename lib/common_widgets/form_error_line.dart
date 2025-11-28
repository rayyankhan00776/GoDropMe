import 'package:flutter/material.dart';
import 'package:godropme/utils/app_typography.dart';

/// A thin, consistent error line used below forms to display
/// a global validation message without shifting layout.
class FormErrorLine extends StatelessWidget {
  final String message;
  final bool visible;
  final double height;

  const FormErrorLine({
    super.key,
    required this.message,
    required this.visible,
    this.height = 18,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Align(
        alignment: Alignment.center,
        child: Text(
          visible ? message : '',
          style: visible
              ? AppTypography.errorSmall
              : AppTypography.errorSmall.copyWith(color: Colors.transparent),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
