import 'package:flutter/material.dart';
import 'package:godropme/core/theme/colors.dart';

class AppTypography {
  static const TextStyle onboardTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  static const TextStyle onboardSubtitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.darkGray,
  );

  static const TextStyle onboardButton = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  static const TextStyle onboardSkip = TextStyle(
    fontSize: 17,
    color: AppColors.darkGray,
  );

  // Option screen typography
  static const TextStyle optionHeading = TextStyle(
    fontSize: 27,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  static const TextStyle optionLinePrimary = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  static const TextStyle optionLineSecondary = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w500,
    color: AppColors.darkGray,
  );

  static const TextStyle optionTerms = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.darkGray,
  );

  // Personal info helper styles
  static const TextStyle personalInfoHelper = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  static const TextStyle helpButton = TextStyle(
    color: AppColors.primary,
    fontSize: 21,
    fontWeight: FontWeight.w500,
  );
}
