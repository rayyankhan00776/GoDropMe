import 'package:flutter/widgets.dart';

/// Small centralized responsive helper used across the app.
/// Keeps scaling logic in one place so widgets stay consistent.
class Responsive {
  Responsive._();

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Returns total vertical padding (top + bottom) from MediaQuery.
  static double paddingVertical(BuildContext context) =>
      MediaQuery.of(context).padding.vertical;

  /// Returns total horizontal padding (left + right) from MediaQuery.
  static double paddingHorizontal(BuildContext context) =>
      MediaQuery.of(context).padding.horizontal;

  /// Width as percent (0..100)
  static double wp(BuildContext context, double percent) =>
      screenWidth(context) * percent / 100.0;

  /// Height as percent (0..100)
  static double hp(BuildContext context, double percent) =>
      screenHeight(context) * percent / 100.0;

  /// Scale a base size by the device width relative to a 390pt design width
  /// and clamp between min and max to preserve visual intent.
  static double scaleClamped(
    BuildContext context,
    double base,
    double min,
    double max,
  ) {
    final factor = screenWidth(context) / 390.0;
    final scaled = base * factor;
    return scaled.clamp(min, max).toDouble();
  }

  /// Simple scale (no clamp) using 390pt baseline.
  static double scale(BuildContext context, double base) {
    final factor = screenWidth(context) / 390.0;
    return base * factor;
  }

  /// Percent of an arbitrary total value with clamping.
  static double percentOf(
    double total,
    double percent,
    double min,
    double max,
  ) {
    final val = total * percent;
    return val.clamp(min, max).toDouble();
  }
}
