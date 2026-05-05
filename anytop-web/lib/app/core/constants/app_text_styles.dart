import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle pageTitle({bool isMobile = false}) => TextStyle(
        fontSize: isMobile ? 24 : 28,
        fontWeight: FontWeight.w700,
        color: AppColors.slate900,
        letterSpacing: -0.5,
      );

  static const TextStyle pageSubtitle = TextStyle(
    fontSize: 15,
    color: AppColors.slate500,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle sectionLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.slate400,
    letterSpacing: 1.5,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.slate900,
    letterSpacing: -0.3,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 13,
    color: AppColors.slate400,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle formLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.slate700,
  );

  static const TextStyle body = TextStyle(
    fontSize: 13,
    color: AppColors.slate500,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.slate400,
  );
}
