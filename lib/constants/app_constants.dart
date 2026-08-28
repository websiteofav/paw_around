class AppConstants {
  AppConstants._();

  // Animation Durations
  static const Duration animationDuration = Duration(milliseconds: 1500);
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);

  // Logo Dimensions
  static const double logoSize = 120.0;
  static const double logoIconSize = 80.0;
  static const double pawIconSize = 24.0;
  static const double pawContainerSize = 40.0;

  // ============================================
  // SPACING SCALE (4px grid system)
  // ============================================
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space14 = 14.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space28 = 28.0;
  static const double space32 = 32.0;
  static const double space36 = 36.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space60 = 60.0;

  // Legacy spacing (kept for backwards compatibility)
  static const double defaultPadding = space16;
  static const double smallPadding = space8;
  static const double largePadding = space24;
  static const double spacingSmall = space8;
  static const double spacingMedium = space16;
  static const double spacingLarge = space24;
  static const double spacingXLarge = space32;

  // ============================================
  // BORDER RADIUS SCALE
  // ============================================
  static const double radiusXS = 8.0; // Small chips, tags
  static const double radiusSM = 12.0; // Buttons, inputs
  static const double radiusMD = 16.0; // Small cards, bottom sheets
  static const double radiusLG = 20.0; // Medium cards
  static const double radiusXL = 24.0; // Large cards, dialogs
  static const double radiusFull = 999.0; // Pills, circles

  // Legacy radius (kept for backwards compatibility)
  static const double defaultBorderRadius = radiusSM;
  static const double smallBorderRadius = radiusXS;
  static const double largeBorderRadius = radiusMD;
  static const double cardBorderRadius = radiusXL;
  static const double inputBorderRadius = 14.0;
  static const double chipBorderRadius = radiusLG;
  static const double buttonBorderRadius = radiusSM;

  // ============================================
  // COMPONENT SIZES
  // ============================================
  // Buttons
  static const double buttonHeight = 50.0;
  static const double smallButtonHeight = 40.0;
  static const double largeButtonHeight = 60.0;

  // Icons
  static const double defaultIconSize = 24.0;
  static const double smallIconSize = 16.0;
  static const double largeIconSize = 32.0;

  // Avatars
  static const double avatarSizeSmall = 40.0;
  static const double avatarSize = 48.0;
  static const double avatarSizeMedium = 60.0;
  static const double avatarSizeLarge = 72.0;
  static const double avatarSizeXLarge = 100.0;

  // Navigation
  static const double navigationHeight = 80.0;

  // ============================================
  // ELEVATION
  // ============================================
  static const double elevationNone = 0.0;
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationXHigh = 12.0;
}
