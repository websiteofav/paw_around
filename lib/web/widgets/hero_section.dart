import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:url_launcher/url_launcher.dart';

class HeroSection extends StatelessWidget {
  final bool isMobile;

  const HeroSection({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final verticalPadding =
        isMobile ? AppConstants.space48 : AppConstants.space40 * 2;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background,
            AppColors.iconBgLight.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Padding(
        padding: AppEdgeInsets.horizontalLarge.copyWith(
          top: verticalPadding,
          bottom: verticalPadding,
        ),
        child: isMobile
            ? _buildMobileLayout(context)
            : _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 24),
                child: child,
              ),
            ),
            child: _buildTextContent(
              context: context,
              textAlign: TextAlign.left,
              ctaAlignment: WrapAlignment.start,
            ),
          ),
        ),
        AppSpacing.horizontal40,
        Expanded(
          flex: 7,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 24),
                child: child,
              ),
            ),
            child: _buildHeroImage(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 24),
              child: child,
            ),
          ),
          child: _buildTextContent(
            context: context,
            textAlign: TextAlign.center,
            ctaAlignment: WrapAlignment.center,
          ),
        ),
        AppSpacing.vertical40,
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 24),
              child: child,
            ),
          ),
          child: _buildHeroImage(),
        ),
      ],
    );
  }

  Widget _buildTextContent({
    required BuildContext context,
    required TextAlign textAlign,
    required WrapAlignment ctaAlignment,
  }) {
    return Column(
      crossAxisAlignment: textAlign == TextAlign.left
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
          },
          blendMode: BlendMode.srcIn,
          child: Text(
            AppStrings.landingHeroTitle,
            style: AppTextStyles.extraBoldStyle800(
              fontSize: isMobile ? 36 : 56,
              fontColor: AppColors.white,
              letterSpacing: -0.8,
              height: 1.15,
            ),
            textAlign: textAlign,
          ),
        ),
        AppSpacing.vertical16,
        Text(
          AppStrings.landingHeroSubtitle,
          style: AppTextStyles.regularStyle400(
            fontSize: 18,
            fontColor: AppColors.textSecondary,
            height: 1.6,
          ),
          textAlign: textAlign,
        ),
        AppSpacing.vertical32,

        /// CTA buttons
        Wrap(
          alignment: ctaAlignment,
          runAlignment: ctaAlignment,
          spacing: AppConstants.space16,
          runSpacing: AppConstants.space12,
          children: [
            Semantics(
              button: true,
              label: AppStrings.landingDownloadOnAndroid,
              hint: 'Opens Google Play Store page for Paw Around',
              child: CommonButton(
                text: AppStrings.landingDownloadOnAndroid,
                onPressed: () => _launchPlayStore(context),
                size: ButtonSize.large,
                imagePath: AppIcons.playStoreIcon,
                customColor: AppColors.authPrimaryButton,
                isFullWidth: isMobile,
              ),
            ),
            AppSpacing.vertical8,
            Semantics(
              button: true,
              label: AppStrings.landingIosComingSoon,
              hint: AppStrings.landingIosComingSoonMessage,
              child: CommonButton(
                text: AppStrings.landingIosComingSoon,
                onPressed: null,
                size: ButtonSize.large,
                variant: ButtonVariant.outline,
                customColor: AppColors.inputBorder,
                customTextColor: AppColors.textLight,
                imagePath: AppIcons.appStoreIcon,
                isFullWidth: isMobile,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    final maxSize = isMobile ? 300.0 : 480.0;

    return Semantics(
      label:
          'Illustration of the Paw Around app showing pet care, safety, and community features',
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxSize,
          maxWidth: maxSize,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: maxSize,
              height: maxSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
            Positioned(
              top: 24,
              left: 0,
              child: Icon(
                Icons.pets,
                size: 32,
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 8,
              child: Icon(
                Icons.pets,
                size: 24,
                color: AppColors.primaryDark.withValues(alpha: 0.08),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    AppColors.primaryDark.withValues(alpha: 0.16),
                  ],
                ),
                borderRadius: AppBorderRadius.xl,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: AppBorderRadius.xl,
                child: Image.asset(
                  AppIcons.heroPetIcon,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.surface,
                      alignment: Alignment.center,
                      padding: AppEdgeInsets.allMedium,
                      child: Text(
                        AppStrings.appName,
                        style: AppTextStyles.semiBoldStyle600(
                          fontSize: 18,
                          fontColor: AppColors.textSecondary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPlayStore(BuildContext context) async {
    final uri = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.pawaround.app',
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.landingPlayStoreOpenError),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.landingPlayStoreOpenError),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showIosComingSoonMessage(BuildContext context) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.landingIosComingSoonMessage),
        backgroundColor: AppColors.navigationBackground,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
