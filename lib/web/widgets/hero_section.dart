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
    return Padding(
      padding: AppEdgeInsets.horizontalLarge.copyWith(
        top: AppConstants.space48,
        bottom: AppConstants.space48,
      ),
      child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 6,
          child: _buildTextContent(
            textAlign: TextAlign.left,
            ctaAlignment: WrapAlignment.start,
          ),
        ),
        AppSpacing.horizontal40,
        Expanded(
          flex: 6,
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
          ctaAlignment: WrapAlignment.center,
        ),
        AppSpacing.vertical40,
        _buildHeroImage(),
      ],
    );
  }

  Widget _buildTextContent({
    required TextAlign textAlign,
    required WrapAlignment ctaAlignment,
  }) {
    return Column(
      crossAxisAlignment: textAlign == TextAlign.left
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          AppStrings.landingHeroTitle,
          style: AppTextStyles.extraBoldStyle800(
            fontSize: isMobile ? 32 : 40,
            fontColor: AppColors.textPrimary,
            height: 1.2,
          ),
          textAlign: textAlign,
        ),
        AppSpacing.vertical16,
        Text(
          AppStrings.landingHeroSubtitle,
          style: AppTextStyles.regularStyle400(
            fontSize: 17,
            fontColor: AppColors.textSecondary,
            height: 1.6,
          ),
          textAlign: textAlign,
        ),
        AppSpacing.vertical32,

        /// CTA buttons
        Wrap(
          alignment: ctaAlignment,
          spacing: AppConstants.space16,
          runSpacing: AppConstants.space12,
          children: [
            CommonButton(
              text: AppStrings.landingDownloadOnAndroid,
              onPressed: () {},
              size: ButtonSize.large,
              icon: Icons.android,
              customColor: AppColors.authPrimaryButton,
            ),
            CommonButton(
              text: AppStrings.landingIosComingSoon,
              onPressed: null,
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
    return Image.asset(
      AppIcons.heroPetIcon,
      fit: BoxFit.contain,
    );
  }
}
