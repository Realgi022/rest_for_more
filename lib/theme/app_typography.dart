import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

TextTheme appTextTheme = TextTheme(
  displayLarge: GoogleFonts.cormorantGaramond(
    fontSize: 40,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  ),
  headlineMedium: GoogleFonts.cormorantGaramond(
    fontSize: 30,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  ),
  titleMedium: GoogleFonts.montserrat(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  ),
  bodyMedium: GoogleFonts.montserrat(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  ),
  bodySmall: GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  ),
);
