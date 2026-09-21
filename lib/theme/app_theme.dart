import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_typography.dart';

ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.surface,
  colorScheme: const ColorScheme.light(
    primary: AppColors.brand,
    secondary: AppColors.brandTint,
    surface: AppColors.surface,
    onPrimary: AppColors.textOnBrand,
    onSurface: AppColors.textPrimary,
  ),
  textTheme: appTextTheme,
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.brand,
      foregroundColor: AppColors.textOnBrand,
      minimumSize: const Size.fromHeight(54),
      textStyle: GoogleFonts.montserrat(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.brand,
      minimumSize: const Size.fromHeight(54),
      side: const BorderSide(color: AppColors.brandTint),
      textStyle: GoogleFonts.montserrat(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: AppColors.surface,
    indicatorColor: AppColors.surfaceMuted,
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      final isSelected = states.contains(WidgetState.selected);

      return GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? AppColors.brand : AppColors.brandTint,
      );
    }),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      final isSelected = states.contains(WidgetState.selected);

      return IconThemeData(
        color: isSelected ? AppColors.brand : AppColors.brandTint,
      );
    }),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.surface,
    elevation: 0,
    centerTitle: false,
    foregroundColor: AppColors.textPrimary,
    titleTextStyle: GoogleFonts.montserrat(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  ),
);
