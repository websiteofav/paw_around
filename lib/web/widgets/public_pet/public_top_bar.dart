import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/utils/url_utils.dart';

/// Top bar for public pet profile (QR / shared links). Matches [LandingNavBar] styling.
class PublicPetTopBar extends StatelessWidget {
  const PublicPetTopBar({super.key});

  static const double _navBarLogoSize = 48;
  static const double _navBarMaxWidth = 1280;

  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.pawaround.app';

  void _navigateToLanding(BuildContext context) {
    context.go('/');
  }

  Future<void> _openPlayStore() async {
    await UrlUtils.launch(_playStoreUrl);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 800;
    final logoSize = isMobile ? 40.0 : _navBarLogoSize;
    final nameFontSize = isMobile ? 20.0 : 24.0;

    return Container(
      padding: AppEdgeInsets.horizontalLarge.copyWith(
        top: AppConstants.space20,
        bottom: AppConstants.space20,
      ),
      decoration: BoxDecoration(
        color: AppColors.navigationBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildLogo(context, logoSize),
                  AppSpacing.horizontal8,
                  Text(
                    AppStrings.appName,
                    style: AppTextStyles.boldStyle700(
                      fontSize: nameFontSize,
                      fontColor: AppColors.navigationText,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              CommonButton(
                text: AppStrings.publicPetTopBarDownloadApp,
                onPressed: _openPlayStore,
                variant: ButtonVariant.primary,
                size: isMobile ? ButtonSize.small : ButtonSize.medium,
                isFullWidth: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context, double size) {
    return Semantics(
      button: true,
      label: AppStrings.landingNavHome,
      child: InkWell(
        onTap: () => _navigateToLanding(context),
        borderRadius: BorderRadius.circular(size / 2),
        splashColor: AppColors.primary.withValues(alpha: 0.1),
        highlightColor: AppColors.primary.withValues(alpha: 0.05),
        focusColor: AppColors.primary.withValues(alpha: 0.08),
        child: ClipOval(
          child: Image.asset(
            AppIcons.appIcon,
            fit: BoxFit.contain,
            width: size,
            height: size,
            errorBuilder: (_, __, ___) => Icon(
              Icons.pets,
              color: AppColors.primary,
              size: size * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
