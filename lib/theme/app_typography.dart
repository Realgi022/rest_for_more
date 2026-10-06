// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// import 'app_colors.dart';

// TextTheme appTextTheme = TextTheme(
//   displayLarge: GoogleFonts.cormorantGaramond(
//     fontSize: 40,
//     fontWeight: FontWeight.w400,
//     color: AppColors.textPrimary,
//   ),
//   headlineMedium: GoogleFonts.cormorantGaramond(
//     fontSize: 30,
//     fontWeight: FontWeight.w400,
//     color: AppColors.textPrimary,
//   ),
//   titleMedium: GoogleFonts.montserrat(
//     fontSize: 17,
//     fontWeight: FontWeight.w600,
//     color: AppColors.textPrimary,
//   ),
//   bodyMedium: GoogleFonts.montserrat(
//     fontSize: 15,
//     fontWeight: FontWeight.w400,
//     color: AppColors.textPrimary,
//   ),
//   bodySmall: GoogleFonts.montserrat(
//     fontSize: 14,
//     fontWeight: FontWeight.w400,
//     color: AppColors.textSecondary,
//   ),
// );

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

TextTheme appTextTheme = TextTheme(
  // H1
  displayLarge: GoogleFonts.cormorantGaramond(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.1,
    color: AppColors.textPrimary,
  ),

  // H2
  headlineMedium: GoogleFonts.cormorantGaramond(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.15,
    color: AppColors.textPrimary,
  ),

  // H3
  headlineSmall: GoogleFonts.cormorantGaramond(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textPrimary,
  ),

  // Titles / buttons
  titleMedium: GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  ),

  // Normal text
  bodyMedium: GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textPrimary,
  ),

  // Small labels
  bodySmall: GoogleFonts.montserrat(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.textSecondary,
  ),

  // Small UI labels
  labelMedium: GoogleFonts.montserrat(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.textSecondary,
  ),
);
