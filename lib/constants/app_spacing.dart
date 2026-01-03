import 'package:flutter/material.dart';
import 'app_constants.dart';

/// Convenience class providing pre-built SizedBox widgets for consistent spacing.
/// Uses the spacing scale defined in AppConstants.
class AppSpacing {
  AppSpacing._();

  // ============================================
  // VERTICAL SPACING
  // ============================================
  static const SizedBox vertical4 = SizedBox(height: AppConstants.space4);
  static const SizedBox vertical6 = SizedBox(height: AppConstants.space6);
  static const SizedBox vertical8 = SizedBox(height: AppConstants.space8);
  static const SizedBox vertical10 = SizedBox(height: AppConstants.space10);
  static const SizedBox vertical12 = SizedBox(height: AppConstants.space12);
  static const SizedBox vertical14 = SizedBox(height: AppConstants.space14);
  static const SizedBox vertical16 = SizedBox(height: AppConstants.space16);
  static const SizedBox vertical20 = SizedBox(height: AppConstants.space20);
  static const SizedBox vertical24 = SizedBox(height: AppConstants.space24);
  static const SizedBox vertical28 = SizedBox(height: AppConstants.space28);
  static const SizedBox vertical32 = SizedBox(height: AppConstants.space32);
  static const SizedBox vertical40 = SizedBox(height: AppConstants.space40);
  static const SizedBox vertical48 = SizedBox(height: AppConstants.space48);
  static const SizedBox vertical60 = SizedBox(height: AppConstants.space60);

  // ============================================
  // HORIZONTAL SPACING
  // ============================================
  static const SizedBox horizontal4 = SizedBox(width: AppConstants.space4);
  static const SizedBox horizontal6 = SizedBox(width: AppConstants.space6);
  static const SizedBox horizontal8 = SizedBox(width: AppConstants.space8);
  static const SizedBox horizontal10 = SizedBox(width: AppConstants.space10);
  static const SizedBox horizontal12 = SizedBox(width: AppConstants.space12);
  static const SizedBox horizontal14 = SizedBox(width: AppConstants.space14);
  static const SizedBox horizontal16 = SizedBox(width: AppConstants.space16);
  static const SizedBox horizontal20 = SizedBox(width: AppConstants.space20);
  static const SizedBox horizontal24 = SizedBox(width: AppConstants.space24);
  static const SizedBox horizontal28 = SizedBox(width: AppConstants.space28);
  static const SizedBox horizontal32 = SizedBox(width: AppConstants.space32);
  static const SizedBox horizontal40 = SizedBox(width: AppConstants.space40);
  static const SizedBox horizontal48 = SizedBox(width: AppConstants.space48);
}

/// Extension to easily create EdgeInsets using AppConstants spacing values.
class AppEdgeInsets {
  AppEdgeInsets._();

  // Symmetric padding presets
  static const EdgeInsets allSmall = EdgeInsets.all(AppConstants.space8);
  static const EdgeInsets allMedium = EdgeInsets.all(AppConstants.space16);
  static const EdgeInsets allLarge = EdgeInsets.all(AppConstants.space24);

  // Horizontal padding presets
  static const EdgeInsets horizontalSmall = EdgeInsets.symmetric(horizontal: AppConstants.space8);
  static const EdgeInsets horizontalMedium = EdgeInsets.symmetric(horizontal: AppConstants.space16);
  static const EdgeInsets horizontalLarge = EdgeInsets.symmetric(horizontal: AppConstants.space24);

  // Vertical padding presets
  static const EdgeInsets verticalSmall = EdgeInsets.symmetric(vertical: AppConstants.space8);
  static const EdgeInsets verticalMedium = EdgeInsets.symmetric(vertical: AppConstants.space16);
  static const EdgeInsets verticalLarge = EdgeInsets.symmetric(vertical: AppConstants.space24);

  // Common screen padding
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(horizontal: AppConstants.space16);
  static const EdgeInsets screenAll = EdgeInsets.all(AppConstants.space16);
  static const EdgeInsets screenWithBottom = EdgeInsets.fromLTRB(
    AppConstants.space16,
    AppConstants.space16,
    AppConstants.space16,
    AppConstants.space32,
  );

  // Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(AppConstants.space20);
  static const EdgeInsets cardPaddingSmall = EdgeInsets.all(AppConstants.space12);
}

/// Convenience class for creating BorderRadius using AppConstants.
class AppBorderRadius {
  AppBorderRadius._();

  static BorderRadius get xs => BorderRadius.circular(AppConstants.radiusXS);
  static BorderRadius get sm => BorderRadius.circular(AppConstants.radiusSM);
  static BorderRadius get md => BorderRadius.circular(AppConstants.radiusMD);
  static BorderRadius get lg => BorderRadius.circular(AppConstants.radiusLG);
  static BorderRadius get xl => BorderRadius.circular(AppConstants.radiusXL);
  static BorderRadius get full => BorderRadius.circular(AppConstants.radiusFull);

  // Top only variants (for bottom sheets)
  static BorderRadius get topMd => const BorderRadius.vertical(
        top: Radius.circular(AppConstants.radiusMD),
      );
  static BorderRadius get topXl => const BorderRadius.vertical(
        top: Radius.circular(AppConstants.radiusXL),
      );
}
