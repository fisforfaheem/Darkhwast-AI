import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTextStyles {
  // English Styles (Sora)
  static TextStyle get display => GoogleFonts.sora(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get headline => GoogleFonts.sora(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get title => GoogleFonts.sora(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get body => GoogleFonts.sora(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySecondary => GoogleFonts.sora(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );

  static TextStyle get caption => GoogleFonts.sora(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );

  static TextStyle get button => GoogleFonts.sora(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textInverse,
      );

  // Urdu Styles (Noto Nastaliq Urdu)
  static TextStyle get urduBody => GoogleFonts.notoNastaliqUrdu(
        fontSize: 18,
        height: 2.0,
        color: AppColors.textPrimary,
      );

  static TextStyle get urduTitle => GoogleFonts.notoNastaliqUrdu(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 2.2,
        color: AppColors.textPrimary,
      );
}
