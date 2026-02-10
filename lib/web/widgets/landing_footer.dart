import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

class LandingFooter extends StatelessWidget {
  const LandingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppEdgeInsets.horizontalLarge.copyWith(
        top: AppConstants.space24,
        bottom: AppConstants.space24,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.98),
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
          ),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;

          return Column(
            crossAxisAlignment:
                isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
            children: [
              Divider(
                color: AppColors.divider,
              ),
              AppSpacing.vertical16,
              if (isMobile)
                Column(
                  children: [
                    _FooterLinks(
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                    AppSpacing.vertical16,
                    _CopyrightText(textAlign: TextAlign.center),
                    AppSpacing.vertical16,
                    _SocialIcons(mainAxisAlignment: MainAxisAlignment.center),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _FooterLinks(
                      mainAxisAlignment: MainAxisAlignment.start,
                    ),
                    _CopyrightText(textAlign: TextAlign.center),
                    _SocialIcons(
                      mainAxisAlignment: MainAxisAlignment.end,
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FooterLinks extends StatelessWidget {
  final MainAxisAlignment mainAxisAlignment;

  const _FooterLinks({
    required this.mainAxisAlignment,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        _FooterLinkText(label: AppStrings.landingFooterAbout),
        AppSpacing.horizontal16,
        _FooterLinkText(label: AppStrings.landingFooterPrivacyPolicy),
        AppSpacing.horizontal16,
        _FooterLinkText(label: AppStrings.landingFooterTermsOfService),
      ],
    );
  }
}

class _FooterLinkText extends StatelessWidget {
  final String label;

  const _FooterLinkText({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.mediumStyle500(
        fontSize: 13,
        fontColor: AppColors.textSecondary,
      ),
    );
  }
}

class _CopyrightText extends StatelessWidget {
  final TextAlign textAlign;

  const _CopyrightText({
    required this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      AppStrings.landingFooterCopyright,
      style: AppTextStyles.regularStyle400(
        fontSize: 12,
        fontColor: AppColors.textLight,
      ),
      textAlign: textAlign,
    );
  }
}

class _SocialIcons extends StatelessWidget {
  final MainAxisAlignment mainAxisAlignment;

  const _SocialIcons({
    required this.mainAxisAlignment,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: const [
        _SocialIcon(icon: Icons.facebook),
        SizedBox(width: AppConstants.space12),
        _SocialIcon(icon: Icons.camera_alt_outlined),
        SizedBox(width: AppConstants.space12),
        _SocialIcon(icon: Icons.alternate_email),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;

  const _SocialIcon({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.iconBgLight,
        borderRadius: AppBorderRadius.full,
      ),
      child: Icon(
        icon,
        size: 18,
        color: AppColors.primary,
      ),
    );
  }
}

