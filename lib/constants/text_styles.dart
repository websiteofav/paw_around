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

  // Light (w300)
  static TextStyle lightStyle300({
    double fontSize = 16,
    Color? fontColor,
    TextDecoration? decoration,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.nunito(
        fontSize: fontSize,
        fontWeight: FontWeight.w300,
        color: fontColor ?? AppColors.textPrimary,
        decoration: decoration,
        letterSpacing: letterSpacing,
        height: height,
      );

  // Convenience aliases for common use cases
  static TextStyle semiBoldTextStyle({
    double fontSize = 16,
    Color? fontColor,
    TextDecoration? decoration,
    double? letterSpacing,
    double? height,
  }) =>
      semiBoldStyle600(
        fontSize: fontSize,
        fontColor: fontColor,
        decoration: decoration,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle boldTextStyle({
    double fontSize = 16,
    Color? fontColor,
    TextDecoration? decoration,
    double? letterSpacing,
    double? height,
  }) =>
      boldStyle700(
        fontSize: fontSize,
        fontColor: fontColor,
        decoration: decoration,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle regularTextStyle({
    double fontSize = 16,
    Color? fontColor,
    TextDecoration? decoration,
    double? letterSpacing,
    double? height,
  }) =>
      regularStyle400(
        fontSize: fontSize,
        fontColor: fontColor,
        decoration: decoration,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle mediumTextStyle({
    double fontSize = 16,
    Color? fontColor,
    TextDecoration? decoration,
    double? letterSpacing,
    double? height,
  }) =>
      mediumStyle500(
        fontSize: fontSize,
        fontColor: fontColor,
        decoration: decoration,
        letterSpacing: letterSpacing,
        height: height,
      );
}
