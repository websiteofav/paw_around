import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

class QrSafetySection extends StatelessWidget {
  final bool isMobile;

  const QrSafetySection({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppEdgeInsets.horizontalLarge,
      child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: _buildImageCard(),
        ),
        AppSpacing.horizontal32,
        Expanded(
          flex: 5,
          child: _buildTextContent(
            textAlign: TextAlign.left,
            ctaAlignment: MainAxisAlignment.start,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildImageCard(),
        AppSpacing.vertical32,
        _buildTextContent(
          textAlign: TextAlign.center,
          ctaAlignment: MainAxisAlignment.center,
        ),
      ],
    );
  }

  Widget _buildImageCard() {
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
      child: ClipRRect(
        borderRadius: AppBorderRadius.lg,
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Image.asset(
            AppIcons.petWithQrIcon,
            fit: BoxFit.cover,
          ),
        ),
      ),
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
          AppStrings.landingQrHeading,
          style: AppTextStyles.extraBoldStyle800(
            fontSize: isMobile ? 26 : 32,
            fontColor: AppColors.textPrimary,
            height: 1.2,
          ),
          textAlign: textAlign,
        ),
        AppSpacing.vertical16,
        Text(
          AppStrings.landingQrBody,
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
              text: AppStrings.landingStaySafeCta,
              onPressed: () {},
              isFullWidth: isMobile,
              size: ButtonSize.large,
              customColor: AppColors.primaryDark,
              customTextColor: AppColors.white,
            ),
          ],
        ),
      ],
    );
  }
}
