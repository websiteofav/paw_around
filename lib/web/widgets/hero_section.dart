import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

class HeroSection extends StatelessWidget {
  final bool isMobile;

  const HeroSection({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: AppEdgeInsets.horizontalLarge.copyWith(
        bottom: AppConstants.space40,
      ),
      child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );

    return content;
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: _buildTextContent(
            textAlign: TextAlign.left,
            ctaAlignment: MainAxisAlignment.start,
          ),
        ),
        AppSpacing.horizontal32,
        Expanded(
          flex: 5,
          child: _buildHeroImage(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTextContent(
          textAlign: TextAlign.center,
          ctaAlignment: MainAxisAlignment.center,
        ),
        AppSpacing.vertical32,
        _buildHeroImage(),
      ],
    );
  }

  Widget _buildTextContent({
    required TextAlign textAlign,
    required MainAxisAlignment ctaAlignment,
  }) {
    return Column(
      crossAxisAlignment: textAlign == TextAlign.left
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          AppStrings.landingHeroTitle,
          style: AppTextStyles.extraBoldStyle800(
            fontSize: isMobile ? 30 : 38,
            fontColor: AppColors.textPrimary,
            height: 1.2,
          ),
          textAlign: textAlign,
        ),
        AppSpacing.vertical16,
        Text(
          AppStrings.landingHeroSubtitle,
          style: AppTextStyles.regularStyle400(
            fontSize: 16,
            fontColor: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: textAlign,
        ),
        AppSpacing.vertical24,
        Row(
          mainAxisAlignment: ctaAlignment,
          children: [
            CommonButton(
              text: AppStrings.landingDownloadOnAndroid,
              onPressed: () {},
              isFullWidth: false,
              size: ButtonSize.large,
              icon: Icons.android,
              customColor: AppColors.authPrimaryButton,
            ),
            AppSpacing.horizontal16,
            CommonButton(
              text: AppStrings.landingIosComingSoon,
              onPressed: () {},
              isFullWidth: false,
              size: ButtonSize.large,
              variant: ButtonVariant.secondary,
              customColor: AppColors.surface,
              customTextColor: AppColors.textSecondary,
              icon: Icons.apple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.space24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppBorderRadius.xl,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: ClipRRect(
          borderRadius: AppBorderRadius.lg,
          child: Image.asset(
            AppIcons.heroPetIcon,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
