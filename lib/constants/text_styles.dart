import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  // App Title Styles
  static TextStyle appTitle({
    double fontSize = 32,
    Color? fontColor,
    FontWeight fontWeight = FontWeight.bold,
    double letterSpacing = 1.2,
  }) =>
      TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: fontColor ?? AppColors.primary,
        letterSpacing: letterSpacing,
      );

  static TextStyle appSubtitle({
    double fontSize = 18,
    Color? fontColor,
    FontWeight fontWeight = FontWeight.w500,
    double letterSpacing = 0.5,
  }) =>
      TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: fontColor ?? AppColors.textSecondary,
        letterSpacing: letterSpacing,
      );

  // Button Styles
  static TextStyle buttonText({
    double fontSize = 16,
    Color? fontColor,
    FontWeight fontWeight = FontWeight.w600,
    double letterSpacing = 0.5,
  }) =>
      TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: fontColor,
        letterSpacing: letterSpacing,
      );

  // Form Styles
  static TextStyle formLabel({
    double fontSize = 16,
    Color? fontColor,
    FontWeight fontWeight = FontWeight.w500,
  }) =>
      TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: fontColor ?? AppColors.textPrimary,
      );

  static TextStyle formHint({
    double fontSize = 16,
    Color? fontColor,
    FontWeight fontWeight = FontWeight.normal,
  }) =>
      TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: fontColor ?? AppColors.textSecondary,
      );

  // Card Styles
  static TextStyle cardTitle({
    double fontSize = 18,
    Color? fontColor,
    FontWeight fontWeight = FontWeight.w600,
  }) =>
      TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: fontColor ?? AppColors.textPrimary,
      );

  static TextStyle cardSubtitle({
    double fontSize = 14,
    Color? fontColor,
    FontWeight fontWeight = FontWeight.normal,
  }) =>
      TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: fontColor ?? AppColors.textSecondary,
      );

  // Welcome message style
  static TextStyle welcomeMessage({
    double fontSize = 16,
    Color? fontColor,
    FontWeight fontWeight = FontWeight.w500,
  }) =>
      TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: fontColor ?? AppColors.textSecondary,
      );

  // Tagline style
  static TextStyle tagline({
    double fontSize = 14,
    Color? fontColor,
    FontWeight fontWeight = FontWeight.w400,
    double letterSpacing = 0.3,
  }) =>
      TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: fontColor ?? AppColors.textSecondary,
        letterSpacing: letterSpacing,
      );

  // AppBar Title Style
  static TextStyle appBarTitle({
    double fontSize = 18,
    Color? fontColor,
    FontWeight fontWeight = FontWeight.bold,
  }) =>
      TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: fontColor ?? AppColors.navigationText,
      );

  // Body Text Style
  static TextStyle bodyText({
    double fontSize = 16,
    Color? fontColor,
    FontWeight fontWeight = FontWeight.normal,
  }) =>
      TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: fontColor ?? AppColors.textPrimary,
      );

  // Error Text Style
  static TextStyle errorText({
    double fontSize = 14,
    Color? fontColor,
    FontWeight fontWeight = FontWeight.normal,
  }) =>
      TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: fontColor ?? AppColors.error,
      );

  // Heading styles with different weights
  static TextStyle heading({
    double fontSize = 20,
    Color? fontColor,
    FontWeight fontWeight = FontWeight.w600,
  }) =>
      TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: fontColor ?? AppColors.textPrimary,
      );

  // Caption style for small text
  static TextStyle caption({
    double fontSize = 12,
    Color? fontColor,
    FontWeight fontWeight = FontWeight.normal,
  }) =>
      TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: fontColor ?? AppColors.textSecondary,
      );

  // Link style
  static TextStyle link({
    double fontSize = 14,
    Color? fontColor,
    FontWeight fontWeight = FontWeight.w500,
    TextDecoration decoration = TextDecoration.underline,
  }) =>
      TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: fontColor ?? AppColors.primary,
        decoration: decoration,
      );
}
