import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

class LandingNavBar extends StatelessWidget {
  final bool isMobile;

  const LandingNavBar({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppEdgeInsets.horizontalLarge.copyWith(
        top: AppConstants.space16,
        bottom: AppConstants.space16,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.98),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: AppConstants.pawContainerSize,
                height: AppConstants.pawContainerSize,
                decoration: BoxDecoration(
                  color: AppColors.iconBgLight,
                  borderRadius: AppBorderRadius.full,
                ),
                child: const Icon(
                  Icons.pets,
                  size: AppConstants.pawIconSize,
                  color: AppColors.primary,
                ),
              ),
              AppSpacing.horizontal12,
              Text(
                AppStrings.appName,
                style: AppTextStyles.boldStyle700(
                  fontSize: 20,
                  fontColor: AppColors.navigationText,
                ),
              ),
            ],
          ),
          if (!isMobile)
            Row(
              children: [
                _NavItem(
                  label: AppStrings.landingNavHome,
                  isActive: true,
                ),
                _NavItem(label: AppStrings.landingNavAbout),
                _NavItem(label: AppStrings.landingNavFaq),
                _NavItem(label: AppStrings.landingNavContact),
              ],
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final bool isActive;

  const _NavItem({
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppConstants.space24),
      child: Text(
        label,
        style: (isActive
                ? AppTextStyles.semiBoldStyle600(
                    fontSize: 14,
                    fontColor: AppColors.primary,
                  )
                : AppTextStyles.mediumStyle500(
                    fontSize: 14,
                    fontColor: AppColors.textSecondary,
                  ))
            .copyWith(letterSpacing: 0.3),
      ),
    );
  }
}
