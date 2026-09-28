import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const String fontFamily = 'Roboto';

  static double _fs(double size) {
    if (Get.context != null) {
      final width = MediaQuery.of(Get.context!).size.width;
      if (width >= 600) {
        return size; // Fixed logical pixels on Tablet & Desktop Web
      }
    }
    return size.sp; // ScreenUtil scaling on Mobile
  }

  // Headings
  static TextStyle h1({bool isDark = false}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: _fs(28),
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle h2({bool isDark = false}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: _fs(22),
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle h3({bool isDark = false}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: _fs(18),
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  // Body Text
  static TextStyle bodyLarge({bool isDark = false}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: _fs(16),
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle bodyMedium({bool isDark = false}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: _fs(14),
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle bodySmall({bool isDark = false}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: _fs(12),
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      );

  // Labels & Buttons
  static TextStyle button({bool isDark = false, Color? color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: _fs(16),
        fontWeight: FontWeight.w600,
        color: color ?? (isDark ? AppColors.textPrimaryDark : Colors.white),
      );

  static TextStyle label({bool isDark = false}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: _fs(13),
        fontWeight: FontWeight.w500,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      );

  // Financial Figures
  static TextStyle amountLarge({required Color color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: _fs(24),
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle amountMedium({required Color color}) => TextStyle(
        fontFamily: fontFamily,
        fontSize: _fs(16),
        fontWeight: FontWeight.w600,
        color: color,
      );
}
