import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_typography.dart';

ThemeData appTheme = _buildTheme(
  brightness: Brightness.light,
  surface: AppColors.surface,
  surfaceMuted: AppColors.surfaceMuted,
  brand: AppColors.brand,
  brandTint: AppColors.brandTint,
  textPrimary: AppColors.textPrimary,
  textSecondary: AppColors.textSecondary,
  textOnBrand: AppColors.textOnBrand,
);

ThemeData appDarkTheme = _buildTheme(
  brightness: Brightness.dark,
  surface: AppColors.nightSurface,
  surfaceMuted: AppColors.nightSurfaceMuted,
  brand: AppColors.nightBrand,
  brandTint: AppColors.nightBrandTint,
  textPrimary: AppColors.nightTextPrimary,
  textSecondary: AppColors.nightTextSecondary,
  textOnBrand: AppColors.nightSurface,
);

ThemeData _buildTheme({
  required Brightness brightness,
  required Color surface,
  required Color surfaceMuted,
  required Color brand,
  required Color brandTint,
  required Color textPrimary,
  required Color textSecondary,
  required Color textOnBrand,
}) {
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: surface,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: brand,
      onPrimary: textOnBrand,
      secondary: brandTint,
      onSecondary: textOnBrand,
      error: Colors.redAccent,
      onError: textOnBrand,
      surface: surface,
      onSurface: textPrimary,
    ),
    textTheme: appTextTheme.apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: brand,
        foregroundColor: textOnBrand,
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
        foregroundColor: brand,
        minimumSize: const Size.fromHeight(54),
        side: BorderSide(color: brandTint),
        textStyle: GoogleFonts.montserrat(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: surfaceMuted,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);

        return GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? brand : brandTint,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final isSelected = states.contains(WidgetState.selected);

        return IconThemeData(color: isSelected ? brand : brandTint);
      }),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      elevation: 0,
      centerTitle: false,
      foregroundColor: textPrimary,
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? brand : textSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? surfaceMuted : null;
      }),
    ),
  );
}
