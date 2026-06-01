import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_constants.dart';

/// Smooth border radius values using figma_squircle (cornerSmoothing: 1.0 = full iOS squircle)
class AppSmoothRadius {
  AppSmoothRadius._();

  static const double _s = 1.0;

  static SmoothBorderRadius get xs =>
      SmoothBorderRadius(cornerRadius: AppConstants.radiusXS, cornerSmoothing: _s);
  static SmoothBorderRadius get sm =>
      SmoothBorderRadius(cornerRadius: AppConstants.radiusSM, cornerSmoothing: _s);
  static SmoothBorderRadius get md =>
      SmoothBorderRadius(cornerRadius: AppConstants.radiusMD, cornerSmoothing: _s);
  static SmoothBorderRadius get lg =>
      SmoothBorderRadius(cornerRadius: AppConstants.radiusLG, cornerSmoothing: _s);
  static SmoothBorderRadius get xl =>
      SmoothBorderRadius(cornerRadius: AppConstants.radiusXL, cornerSmoothing: _s);
  static SmoothBorderRadius get input =>
      SmoothBorderRadius(cornerRadius: AppConstants.inputBorderRadius, cornerSmoothing: _s);

  static SmoothBorderRadius custom(double r) =>
      SmoothBorderRadius(cornerRadius: r, cornerSmoothing: _s);

  static SmoothBorderRadius topOnly(double r) =>
      SmoothBorderRadius.only(
        topLeft: SmoothRadius(cornerRadius: r, cornerSmoothing: _s),
        topRight: SmoothRadius(cornerRadius: r, cornerSmoothing: _s),
      );
}

/// Factory for smooth ShapeDecoration — use instead of BoxDecoration when a border radius is needed.
/// Drop-in replacement: same params as BoxDecoration but renders with squircle corners.
ShapeDecoration smoothDecoration({
  Color? color,
  double cornerRadius = AppConstants.radiusMD,
  SmoothBorderRadius? borderRadius,
  List<BoxShadow>? shadows,
  BorderSide side = BorderSide.none,
  DecorationImage? image,
}) {
  return ShapeDecoration(
    color: color,
    shadows: shadows,
    image: image,
    shape: SmoothRectangleBorder(
      borderRadius:
          borderRadius ?? SmoothBorderRadius(cornerRadius: cornerRadius, cornerSmoothing: 1.0),
      side: side,
    ),
  );
}
