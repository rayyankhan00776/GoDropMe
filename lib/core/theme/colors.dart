import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primaryDark = Color(0xFF6046AA);
  static const Color primary = Color(0xFF756AED);
  static const Color primaryLight = Color(0xFFB7ACD9);

  // Primary Gradient
  static const List<Color> primaryGradient = [
    Color(0xFF9991F6),
    Color(0xFF756AED),
  ];

  // Button Gradient (for CustomButton)
  static const List<Color> buttonGradient = [
    Color(0xFF9991F6),
    Color(0xFF756AED),
  ];

  // Accent Color
  static const Color accent = Color(0xFFFC6752);

  // Neutral Colors
  static const Color lightGreen = Color.fromARGB(255, 24, 146, 146);
  static const Color black = Color(0xFF383838);
  static const Color darkGray = Color(0xFF50565A);
  static const Color gray = Color(0xFF77808D);
  static const Color lightGray = Color(0xFFBDBCBC);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grayLight = Color(0xFFC1C6CC);
  // Semantic Colors
  static const Color success = Color(0xFF34DFDD);
  static const Color warning = Color(0xFFFFB461);
  static const Color transparent = Colors.transparent;

  // Other Gradients
  static const List<Color> gradientBlue = [
    Color(0xFF6BF1F1),
    Color(0xFF3FD7D7),
  ];
  static const List<Color> gradientPink = [
    Color(0xFFFF99B5),
    Color(0xFFEC6ABF),
  ];
}
