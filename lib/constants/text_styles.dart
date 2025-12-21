import 'package:flutter/material.dart';
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
  }) =>
      TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: fontColor ?? AppColors.textPrimary,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  // Medium (w500)
  static TextStyle mediumStyle500({
    double fontSize = 16,
    Color? fontColor,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: fontColor ?? AppColors.textPrimary,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  // Semi-bold (w600)
  static TextStyle semiBoldStyle600({
    double fontSize = 16,
    Color? fontColor,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: fontColor ?? AppColors.textPrimary,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  // Bold (w700)
  static TextStyle boldStyle700({
    double fontSize = 16,
    Color? fontColor,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: fontColor ?? AppColors.textPrimary,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  // Extra Bold (w800)
  static TextStyle extraBoldStyle800({
    double fontSize = 16,
    Color? fontColor,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: fontColor ?? AppColors.textPrimary,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  // Light (w300)
  static TextStyle lightStyle300({
    double fontSize = 16,
    Color? fontColor,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w300,
        color: fontColor ?? AppColors.textPrimary,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  // Convenience aliases for common use cases
  static TextStyle semiBoldTextStyle({
    double fontSize = 16,
    Color? fontColor,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      semiBoldStyle600(
        fontSize: fontSize,
        fontColor: fontColor,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  static TextStyle boldTextStyle({
    double fontSize = 16,
    Color? fontColor,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      boldStyle700(
        fontSize: fontSize,
        fontColor: fontColor,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  static TextStyle regularTextStyle({
    double fontSize = 16,
    Color? fontColor,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      regularStyle400(
        fontSize: fontSize,
        fontColor: fontColor,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  static TextStyle mediumTextStyle({
    double fontSize = 16,
    Color? fontColor,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      mediumStyle500(
        fontSize: fontSize,
        fontColor: fontColor,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );
}
