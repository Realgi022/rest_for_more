// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// import 'app_colors.dart';
// import 'app_typography.dart';

// ThemeData appTheme = _buildTheme(
//   brightness: Brightness.light,
//   surface: AppColors.surface,
//   surfaceMuted: AppColors.surfaceMuted,
//   brand: AppColors.brand,
//   brandTint: AppColors.brandTint,
//   textPrimary: AppColors.textPrimary,
//   textSecondary: AppColors.textSecondary,
//   textOnBrand: AppColors.textOnBrand,
// );

// ThemeData appDarkTheme = _buildTheme(
//   brightness: Brightness.dark,
//   surface: AppColors.nightSurface,
//   surfaceMuted: AppColors.nightSurfaceMuted,
//   brand: AppColors.nightBrand,
//   brandTint: AppColors.nightBrandTint,
//   textPrimary: AppColors.nightTextPrimary,
//   textSecondary: AppColors.nightTextSecondary,
//   textOnBrand: AppColors.nightSurface,
// );

// ThemeData _buildTheme({
//   required Brightness brightness,
//   required Color surface,
//   required Color surfaceMuted,
//   required Color brand,
//   required Color brandTint,
//   required Color textPrimary,
//   required Color textSecondary,
//   required Color textOnBrand,
// }) {
//   return ThemeData(
//     useMaterial3: true,
//     brightness: brightness,
//     scaffoldBackgroundColor: surface,
//     colorScheme: ColorScheme(
//       brightness: brightness,
//       primary: brand,
//       onPrimary: textOnBrand,
//       secondary: brandTint,
//       onSecondary: textOnBrand,
//       error: Colors.redAccent,
//       onError: textOnBrand,
//       surface: surface,
//       onSurface: textPrimary,
//     ),
//     textTheme: appTextTheme.apply(
//       bodyColor: textPrimary,
//       displayColor: textPrimary,
//     ),
//     filledButtonTheme: FilledButtonThemeData(
//       style: FilledButton.styleFrom(
//         backgroundColor: brand,
//         foregroundColor: textOnBrand,
//         minimumSize: const Size.fromHeight(54),
//         textStyle: GoogleFonts.montserrat(
//           fontSize: 15,
//           fontWeight: FontWeight.w600,
//         ),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//       ),
//     ),
//     outlinedButtonTheme: OutlinedButtonThemeData(
//       style: OutlinedButton.styleFrom(
//         foregroundColor: brand,
//         minimumSize: const Size.fromHeight(54),
//         side: BorderSide(color: brandTint),
//         textStyle: GoogleFonts.montserrat(
//           fontSize: 15,
//           fontWeight: FontWeight.w600,
//         ),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//       ),
//     ),
//     navigationBarTheme: NavigationBarThemeData(
//       backgroundColor: surface,
//       indicatorColor: surfaceMuted,
//       labelTextStyle: WidgetStateProperty.resolveWith((states) {
//         final isSelected = states.contains(WidgetState.selected);

//         return GoogleFonts.montserrat(
//           fontSize: 12,
//           fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
//           color: isSelected ? brand : brandTint,
//         );
//       }),
//       iconTheme: WidgetStateProperty.resolveWith((states) {
//         final isSelected = states.contains(WidgetState.selected);

//         return IconThemeData(color: isSelected ? brand : brandTint);
//       }),
//     ),
//     appBarTheme: AppBarTheme(
//       backgroundColor: surface,
//       elevation: 0,
//       centerTitle: false,
//       foregroundColor: textPrimary,
//       titleTextStyle: GoogleFonts.montserrat(
//         fontSize: 17,
//         fontWeight: FontWeight.w600,
//         color: textPrimary,
//       ),
//     ),
//     switchTheme: SwitchThemeData(
//       thumbColor: WidgetStateProperty.resolveWith((states) {
//         return states.contains(WidgetState.selected) ? brand : textSecondary;
//       }),
//       trackColor: WidgetStateProperty.resolveWith((states) {
//         return states.contains(WidgetState.selected) ? surfaceMuted : null;
//       }),
//     ),
//   );
// }

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
  accent: AppColors.accent,
  textPrimary: AppColors.textPrimary,
  textSecondary: AppColors.textSecondary,
  textOnBrand: AppColors.textOnBrand,
  border: AppColors.border,
);

ThemeData appDarkTheme = _buildTheme(
  brightness: Brightness.dark,
  surface: AppColors.nightSurface,
  surfaceMuted: AppColors.nightSurfaceMuted,
  brand: AppColors.nightBrand,
  brandTint: AppColors.nightBrandTint,
  accent: AppColors.accent,
  textPrimary: AppColors.nightTextPrimary,
  textSecondary: AppColors.nightTextSecondary,
  textOnBrand: AppColors.nightSurface,
  border: AppColors.nightBorder,
);

ThemeData _buildTheme({
  required Brightness brightness,
  required Color surface,
  required Color surfaceMuted,
  required Color brand,
  required Color brandTint,
  required Color accent,
  required Color textPrimary,
  required Color textSecondary,
  required Color textOnBrand,
  required Color border,
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
      onError: Colors.white,

      surface: surface,
      onSurface: textPrimary,
    ),

    // --------------------------
    // TYPOGRAPHY
    // --------------------------

    textTheme: appTextTheme.apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ),

    // --------------------------
    // APP BAR
    // --------------------------

    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,

      titleTextStyle: GoogleFonts.cormorantGaramond(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),

      iconTheme: IconThemeData(
        color: textPrimary,
        size: 24,
      ),
    ),

    // --------------------------
    // CARDS
    // --------------------------

    cardTheme: CardThemeData(
      color: surfaceMuted,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // --------------------------
    // FILLED BUTTON
    // --------------------------

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: brand,
        foregroundColor: textOnBrand,

        minimumSize: const Size(
          48,
          52,
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),

        textStyle: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),

    // --------------------------
    // ELEVATED BUTTON
    // --------------------------

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: brand,
        foregroundColor: textOnBrand,

        elevation: 0,

        minimumSize: const Size(
          48,
          52,
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),

        textStyle: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),

    // --------------------------
    // OUTLINED BUTTON
    // --------------------------

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: brand,

        minimumSize: const Size(
          48,
          52,
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),

        side: BorderSide(
          color: brand,
          width: 1,
        ),

        textStyle: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),

    // --------------------------
    // TEXT BUTTON
    // --------------------------

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: brand,

        minimumSize: const Size(
          48,
          48,
        ),

        textStyle: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    // --------------------------
    // INPUT FIELDS
    // --------------------------

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceMuted,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),

      hintStyle: GoogleFonts.montserrat(
        color: textSecondary,
        fontSize: 14,
      ),

      labelStyle: GoogleFonts.montserrat(
        color: textSecondary,
        fontSize: 14,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: brand,
          width: 1.5,
        ),
      ),
    ),

    // --------------------------
    // NAVIGATION BAR
    // --------------------------

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      elevation: 0,
      height: 72,

      indicatorColor: surfaceMuted,

      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) {
          final selected =
              states.contains(WidgetState.selected);

          return GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? brand : textSecondary,
          );
        },
      ),

      iconTheme: WidgetStateProperty.resolveWith(
        (states) {
          final selected =
              states.contains(WidgetState.selected);

          return IconThemeData(
            color: selected ? brand : textSecondary,
            size: 24,
          );
        },
      ),
    ),

    // --------------------------
    // SWITCH
    // --------------------------

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return textOnBrand;
          }

          return textSecondary;
        },
      ),

      trackColor: WidgetStateProperty.resolveWith(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return brand;
          }

          return surfaceMuted;
        },
      ),
    ),

    // --------------------------
    // DIVIDERS
    // --------------------------

    dividerTheme: DividerThemeData(
      color: border,
      thickness: 1,
      space: 1,
    ),

    // --------------------------
    // ICONS
    // --------------------------

    iconTheme: IconThemeData(
      color: brand,
      size: 24,
    ),

    // --------------------------
    // PROGRESS INDICATORS
    // --------------------------

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: brand,
      linearTrackColor: surfaceMuted,
      circularTrackColor: surfaceMuted,
    ),
  );
}
