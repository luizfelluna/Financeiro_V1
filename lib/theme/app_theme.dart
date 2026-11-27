import 'package:flutter/material.dart';

class AppColors {
  // Base branca e superfícies claras
  static const Color background = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8F9FA);

  // Laranjas (Cor principal da paleta)
  static const Color primaryOrange = Color(0xFFF37A1F);
  static const Color softOrange = Color(0xFFF99B4E);
  static const Color paleOrange = Color(0xFFFFF3E8);

  // Azuis (Detalhes menores da paleta)
  static const Color lightBlue = Color(0xFF567EC2);
  static const Color royalBlue = Color(0xFF235390);
  static const Color deepBlue = Color(0xFF143666);
  static const Color navyBlue = Color(0xFF0E2447);

  // Status financeiros
  static const Color success = Color(0xFF2E7D32);
  static const Color danger = Color(0xFFC62828);
}

class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryOrange,
      brightness: Brightness.light,
      primary: AppColors.primaryOrange,
      onPrimary: Colors.white,
      secondary: AppColors.royalBlue,
      onSecondary: Colors.white,
      tertiary: AppColors.navyBlue,
      surface: AppColors.background,
      onSurface: AppColors.navyBlue,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.background,
        elevation: 1,
        shadowColor: AppColors.navyBlue.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: AppColors.lightBlue.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.background,
        indicatorColor: AppColors.paleOrange,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.primaryOrange,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            );
          }
          return const TextStyle(
            color: AppColors.royalBlue,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryOrange);
          }
          return const IconThemeData(color: AppColors.royalBlue);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.lightBlue.withValues(alpha: 0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.lightBlue.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryOrange, width: 2),
        ),
      ),
    );
  }
}