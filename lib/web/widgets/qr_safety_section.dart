import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

class QrSafetySection extends StatefulWidget {
  final bool isMobile;
  final VoidCallback? onCtaPressed;

  const QrSafetySection({
    super.key,
    required this.isMobile,
    this.onCtaPressed,
  });

  @override
  State<QrSafetySection> createState() => _QrSafetySectionState();
}

class _QrSafetySectionState extends State<QrSafetySection> {
  bool _isImageHovered = false;

  @override
  Widget build(BuildContext context) {
    final verticalPadding =
        widget.isMobile ? AppConstants.space60 : AppConstants.space40 * 2;

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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child:
                widget.isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: _buildImageCard(),
        ),
        AppSpacing.horizontal32,
        Expanded(
          flex: 4,
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
    return MouseRegion(
      onEnter: (_) => setState(() => _isImageHovered = true),
      onExit: (_) => setState(() => _isImageHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(0.0, _isImageHovered ? -5.0 : 0.0)
          ..scale(_isImageHovered ? 1.02 : 1.0),
        padding: const EdgeInsets.all(AppConstants.space32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppBorderRadius.xl,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: _isImageHovered ? 28 : 24,
              offset: Offset(0, _isImageHovered ? 12 : 10),
              spreadRadius: -4,
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Image.asset(
            AppIcons.petWithQrIcon,
            fit: BoxFit.contain,
            frameBuilder: (context, child, frame, loaded) {
              //
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                child: child,
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.iconBgLight,
                alignment: Alignment.center,
                child: Icon(
                  Icons.qr_code_2,
                  size: 64,
                  color: AppColors.primary,
                ),
              );
            },
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
          AppStrings.landingQrEyebrow,
          style: AppTextStyles.semiBoldStyle600(
            fontSize: 13,
            fontColor: AppColors.primary,
          ).copyWith(letterSpacing: 1.2),
          textAlign: textAlign,
        ),
        AppSpacing.vertical12,
        Text(
          AppStrings.landingQrHeading,
          style: AppTextStyles.extraBoldStyle800(
            fontSize: widget.isMobile ? 28 : 40,
            fontColor: AppColors.textPrimary,
            height: 1.15,
            letterSpacing: -0.8,
          ),
          textAlign: textAlign,
        ),
        AppSpacing.vertical20,
        Text(
          AppStrings.landingQrBody,
          style: AppTextStyles.regularStyle400(
            fontSize: 17,
            fontColor: AppColors.textSecondary,
            height: 1.6,
          ),
          textAlign: textAlign,
        ),
        AppSpacing.vertical16,
        Align(
          alignment: textAlign == TextAlign.left
              ? Alignment.centerLeft
              : Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified,
                size: 18,
                color: AppColors.success,
              ),
              AppSpacing.horizontal8,
              Text(
                AppStrings.landingQrTrustBadge,
                style: AppTextStyles.mediumStyle500(
                  fontSize: 14,
                  fontColor: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.vertical32,
        Column(
          crossAxisAlignment: ctaAlignment == MainAxisAlignment.center
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            CommonButton(
              text: AppStrings.landingQrCtaPrimary,
              onPressed: () {
                if (widget.onCtaPressed != null) {
                  widget.onCtaPressed!();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppStrings.landingQrCtaPrimary),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              isFullWidth: widget.isMobile,
              size: ButtonSize.large,
              customColor: AppColors.primary,
              customTextColor: AppColors.white,
            ),
            AppSpacing.vertical12,
            TextButton(
              onPressed: () {
                if (widget.onCtaPressed != null) {
                  widget.onCtaPressed!();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppStrings.landingQrCtaSecondary),
                      backgroundColor: AppColors.navigationBackground,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.landingQrCtaSecondary,
                    style: AppTextStyles.mediumStyle500(
                      fontSize: 15,
                      fontColor: AppColors.primary,
                    ),
                  ),
                  AppSpacing.horizontal4,
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
