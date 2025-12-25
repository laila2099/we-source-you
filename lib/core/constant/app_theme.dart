import 'package:flutter/material.dart';
import 'package:we_source_you/core/constant/app_color.dart';
import 'package:we_source_you/core/constant/text_style.dart';

class AppTheme {
  // Light Theme
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.cream,
      useMaterial3: true,
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.h1(),
        headlineMedium: AppTextStyles.h2(),
        headlineSmall: AppTextStyles.h3(),
        titleLarge: AppTextStyles.h4(),

        bodyLarge: AppTextStyles.body(),
        bodyMedium: AppTextStyles.body(),
        bodySmall: AppTextStyles.caption(),
        labelLarge: AppTextStyles.button(),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade900,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.blue.shade900,
          side: BorderSide(color: Colors.blue.shade900),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  // Dark Theme
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      useMaterial3: true,
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.h1().copyWith(color: Colors.white),
        headlineMedium: AppTextStyles.h2().copyWith(color: Colors.white),
        headlineSmall: AppTextStyles.h3().copyWith(color: Colors.white),
        titleLarge: AppTextStyles.h4().copyWith(color: Colors.white),

        bodyLarge: AppTextStyles.body().copyWith(color: Colors.grey[300]),
        bodyMedium: AppTextStyles.body().copyWith(color: Colors.grey[300]),
        bodySmall: AppTextStyles.caption().copyWith(color: Colors.grey[400]),
        labelLarge: AppTextStyles.button().copyWith(color: Colors.white),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade400,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
