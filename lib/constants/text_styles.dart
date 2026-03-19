import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  // Regular (w400)
  static TextStyle regularStyle400({
    double fontSize = 16,
    Color? fontColor,
    TextDecoration? decoration,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.nunito(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: fontColor ?? AppColors.textPrimary,
        decoration: decoration,
        letterSpacing: letterSpacing,
        height: height,
      );

  // Medium (w500)
  static TextStyle mediumStyle500({
    double fontSize = 16,
    Color? fontColor,
    TextDecoration? decoration,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.nunito(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: fontColor ?? AppColors.textPrimary,
        decoration: decoration,
        letterSpacing: letterSpacing,
        height: height,
      );

  // Semi-bold (w600)
  static TextStyle semiBoldStyle600({
    double fontSize = 16,
    Color? fontColor,
    TextDecoration? decoration,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.nunito(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: fontColor ?? AppColors.textPrimary,
        decoration: decoration,
        letterSpacing: letterSpacing,
        height: height,
      );

  // Bold (w700)
  static TextStyle boldStyle700({
    double fontSize = 16,
    Color? fontColor,
    TextDecoration? decoration,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.nunito(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: fontColor ?? AppColors.textPrimary,
        decoration: decoration,
        letterSpacing: letterSpacing,
        height: height,
      );

  // Extra Bold (w800)
  static TextStyle extraBoldStyle800({
    double fontSize = 16,
    Color? fontColor,
    TextDecoration? decoration,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.nunito(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: fontColor ?? AppColors.textPrimary,
        decoration: decoration,
        letterSpacing: letterSpacing,
        height: height,
      );

  // Regular (w400)
  static TextStyle interRegularStyle400({
    double fontSize = 16,
    Color? fontColor,
    TextDecoration? decoration,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: fontColor ?? AppColors.textPrimary,
        decoration: decoration,
        letterSpacing: letterSpacing,
        height: height,
      );

  // Medium (w500)
  static TextStyle interMediumStyle500({
    double fontSize = 16,
    Color? fontColor,
    TextDecoration? decoration,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: fontColor ?? AppColors.textPrimary,
        decoration: decoration,
        letterSpacing: letterSpacing,
        height: height,
      );

  // Semi-bold (w600)
  static TextStyle interSemiBoldStyle600({
    double fontSize = 16,
    Color? fontColor,
    TextDecoration? decoration,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: fontColor ?? AppColors.textPrimary,
        decoration: decoration,
        letterSpacing: letterSpacing,
        height: height,
      );

  // Bold (w700)
  static TextStyle interBoldStyle700({
    double fontSize = 16,
    Color? fontColor,
    TextDecoration? decoration,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: fontColor ?? AppColors.textPrimary,
        decoration: decoration,
        letterSpacing: letterSpacing,
        height: height,
      );
}
