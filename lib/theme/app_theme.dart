// Copyright 2026 Evan Li Zhen Feng. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colors approximated from the Agnes AI web app screenshots.
class AppColors {
  static const outerBackground = Color(0xFFF3F4F6);
  static const panelBackground = Color(0xFFFFFFFF);
  static const railBackground = Color(0xFFFFFFFF);
  static const primaryBlue = Color(0xFF4457E8);
  static const accentPurple = Color(0xFF6C5CE7);
  static const userBubble = Color(0xFFEDEAFB);
  static const chipBackground = Color(0xFFF8F8FA);
  static const border = Color(0xFFE7E7EC);
  static const textPrimary = Color(0xFF1F2430);
  static const textSecondary = Color(0xFF6B7280);
  static const iconInactive = Color(0xFF9CA3AF);
  static const danger = Color(0xFFE05252);
  static const gold = Color(0xFFF5A623);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.outerBackground,
    );

    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return base.copyWith(
      textTheme: textTheme,
      dividerColor: AppColors.border,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.chipBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.panelBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }

  static TextStyle logoStyle({double fontSize = 22}) => GoogleFonts.baloo2(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryBlue,
      );
}
