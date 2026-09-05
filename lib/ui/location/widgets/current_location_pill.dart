import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

/// "Current location" pill on the Pick Location screen — re-centers the map
/// on the device's GPS fix when tapped.
class CurrentLocationPill extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const CurrentLocationPill({
    super.key,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onPressed: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: smoothDecoration(
          cornerRadius: 999,
          color: AppColors.white,
          shadows: [
            BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0.0510),
              offset: const Offset(0, 3),
              blurRadius: 7,
            ),
            BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0.0392),
              offset: const Offset(0, 13),
              blurRadius: 13,
            ),
            BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0.0314),
              offset: const Offset(0, 30),
              blurRadius: 18,
            ),
            BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0.0118),
              offset: const Offset(0, 54),
              blurRadius: 21,
            ),
            BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0),
              offset: const Offset(0, 84),
              blurRadius: 23,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Image.asset(
                AppIcons.gpsIcon,
                width: 18,
                height: 18,
                color: AppColors.grey1000,
                colorBlendMode: BlendMode.srcIn,
              ),
            AppSpacing.horizontal8,
            Text(
              AppStrings.currentLocationPillLabel,
              style: AppTextStyles.semiBoldStyle600(
                fontSize: 14,
                fontColor: AppColors.grey1000,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
