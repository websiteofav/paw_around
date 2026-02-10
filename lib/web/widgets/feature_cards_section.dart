import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

class FeatureCardsSection extends StatelessWidget {
  const FeatureCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppEdgeInsets.horizontalLarge,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 700;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Wrap(
                spacing: AppConstants.space24,
                runSpacing: AppConstants.space24,
                alignment: WrapAlignment.center,
                children: [
                  _FeatureCard(
                    icon: Icons.event_available_outlined,
                    title: AppStrings.landingFeaturePetCareRemindersTitle,
                    description: AppStrings.landingFeaturePetCareRemindersBody,
                    width: _cardWidth(constraints.maxWidth, isNarrow),
                  ),
                  _FeatureCard(
                    icon: Icons.qr_code_2_outlined,
                    title: AppStrings.landingFeatureLostFoundTitle,
                    description: AppStrings.landingFeatureLostFoundBody,
                    width: _cardWidth(constraints.maxWidth, isNarrow),
                  ),
                  _FeatureCard(
                    icon: Icons.location_on_outlined,
                    title: AppStrings.landingFeatureNearbyVetsTitle,
                    description: AppStrings.landingFeatureNearbyVetsBody,
                    width: _cardWidth(constraints.maxWidth, isNarrow),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  double _cardWidth(double maxWidth, bool isNarrow) {
    if (isNarrow) {
      return maxWidth;
    }
    return (maxWidth - (2 * AppConstants.space24)) / 3;
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final double width;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: AppEdgeInsets.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppBorderRadius.lg,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.iconBgLight,
                borderRadius: AppBorderRadius.md,
              ),
              child: Icon(
                icon,
                size: 28,
                color: AppColors.primary,
              ),
            ),
            AppSpacing.vertical16,
            Text(
              title,
              style: AppTextStyles.semiBoldStyle600(
                fontSize: 18,
                fontColor: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vertical10,
            Text(
              description,
              style: AppTextStyles.regularStyle400(
                fontSize: 14,
                fontColor: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
