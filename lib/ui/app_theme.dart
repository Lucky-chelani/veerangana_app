import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      // Primary colors
      primaryColor: AppColors.rosePink,
      colorScheme: ColorScheme.light(
        primary: AppColors.rosePink,
        secondary: AppColors.raspberry,
        tertiary: AppColors.salmonPink,
        //background: 
        //surface: AppColors.lightPeach,
        surface: Colors.white,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        //onBackground: AppColors.deepBurgundy,
        onSurface: AppColors.deepBurgundy,
        onError: Colors.white,
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.deepBurgundy),
        displayMedium: TextStyle(color: AppColors.deepBurgundy),
        displaySmall: TextStyle(color: AppColors.deepBurgundy),
        headlineMedium: TextStyle(color: AppColors.deepBurgundy),
        headlineSmall: TextStyle(color: AppColors.deepBurgundy),
        titleLarge: TextStyle(color: AppColors.deepBurgundy),
        bodyLarge: TextStyle(color: AppColors.deepBurgundy),
        bodyMedium: TextStyle(color: AppColors.deepBurgundy),
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.rosePink,
        foregroundColor: Colors.white,
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.raspberry,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.raspberry, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.salmonPink),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Scaffold background color
      scaffoldBackgroundColor: AppColors.lightPeach,
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.raspberry,
        unselectedItemColor: AppColors.salmonPink,
      ),
    );
  }
}