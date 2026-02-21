import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadSection extends StatelessWidget {
  const DownloadSection({super.key});

  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.pawaround.app';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final headingSize = isMobile ? 36.0 : 48.0;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.05),
                AppColors.primaryLight.withValues(alpha: 0.1),
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 90),
          child: Padding(
            padding: AppEdgeInsets.horizontalLarge,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.landingDownloadHeading,
                      style: AppTextStyles.extraBoldStyle800(
                        fontSize: headingSize,
                        fontColor: AppColors.textPrimary,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.vertical16,
                    Text(
                      AppStrings.landingDownloadSubheading,
                      style: AppTextStyles.regularStyle400(
                        fontSize: 18,
                        fontColor: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.vertical24,
                    _buildFeatureChecklist(isMobile),
                    AppSpacing.vertical24,
                    _buildSocialProof(context),
                    AppSpacing.vertical32,
                    _buildButtons(context, isMobile),
                    AppSpacing.vertical32,
                    Text(
                      AppStrings.landingDownloadOrScan,
                      style: AppTextStyles.regularStyle400(
                        fontSize: 14,
                        fontColor: AppColors.textSecondary,
                      ),
                    ),
                    AppSpacing.vertical12,
                    Container(
                      padding: const EdgeInsets.all(AppConstants.space12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: AppBorderRadius.md,
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.shadowOverlay.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: _playStoreUrl,
                        version: QrVersions.auto,
                        size: 120,
                        backgroundColor: AppColors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppColors.textPrimary,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    AppSpacing.vertical16,
                    _buildTrustIndicators(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureChecklist(bool isMobile) {
    final items = [
      AppStrings.landingDownloadFeatureReminders,
      AppStrings.landingDownloadFeatureQr,
      AppStrings.landingDownloadFeatureVets,
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppConstants.space16,
      runSpacing: AppConstants.space8,
      children: items.map((label) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 18,
              color: AppColors.primary,
            ),
            AppSpacing.horizontal8,
            Text(
              label,
              style: AppTextStyles.mediumStyle500(
                fontSize: 15,
                fontColor: AppColors.textSecondary,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSocialProof(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          color: AppColors.ratingColor,
          size: 20,
        ),
        AppSpacing.horizontal6,
        Text(
          AppStrings.landingDownloadRating,
          style: AppTextStyles.semiBoldStyle600(
            fontSize: 16,
            fontColor: AppColors.textPrimary,
          ),
        ),
        Text(
          '  •  ',
          style: AppTextStyles.regularStyle400(
            fontSize: 16,
            fontColor: AppColors.textSecondary,
          ),
        ),
        Text(
          AppStrings.landingDownloadSocialDownloads,
          style: AppTextStyles.mediumStyle500(
            fontSize: 16,
            fontColor: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context, bool isMobile) {
    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CommonButton(
                text: AppStrings.landingDownloadOnAndroid,
                onPressed: () => _launchPlayStore(context),
                isFullWidth: true,
                size: ButtonSize.large,
                imagePath: AppIcons.playStoreIcon,
                customColor: AppColors.primary,
                customTextColor: AppColors.white,
              ),
              AppSpacing.vertical20,
              CommonButton(
                text: AppStrings.landingIosComingSoon,
                onPressed: null,
                isFullWidth: true,
                size: ButtonSize.large,
                variant: ButtonVariant.outline,
                customColor: AppColors.border,
                customTextColor: AppColors.textLight,
                imagePath: AppIcons.appStoreIcon,
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CommonButton(
                text: AppStrings.landingDownloadOnAndroid,
                onPressed: () => _launchPlayStore(context),
                isFullWidth: false,
                size: ButtonSize.large,
                imagePath: AppIcons.playStoreIcon,
                customColor: AppColors.primary,
                customTextColor: AppColors.white,
              ),
              AppSpacing.horizontal20,
              CommonButton(
                text: AppStrings.landingIosComingSoon,
                onPressed: null,
                isFullWidth: false,
                size: ButtonSize.large,
                variant: ButtonVariant.outline,
                customColor: AppColors.border,
                customTextColor: AppColors.textLight,
                imagePath: AppIcons.appStoreIcon,
              ),
            ],
          );
  }

  Widget _buildTrustIndicators(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppConstants.space8,
      runSpacing: AppConstants.space8,
      children: [
        Text(
          AppStrings.landingDownloadTrustFree,
          style: AppTextStyles.mediumStyle500(
            fontSize: 13,
            fontColor: AppColors.textLight,
          ),
        ),
        Text(
          '•',
          style: AppTextStyles.regularStyle400(
            fontSize: 13,
            fontColor: AppColors.textLight,
          ),
        ),
        Text(
          AppStrings.landingDownloadTrustSecure,
          style: AppTextStyles.mediumStyle500(
            fontSize: 13,
            fontColor: AppColors.textLight,
          ),
        ),
        Text(
          '•',
          style: AppTextStyles.regularStyle400(
            fontSize: 13,
            fontColor: AppColors.textLight,
          ),
        ),
        Text(
          AppStrings.landingDownloadTrustPrivacy,
          style: AppTextStyles.mediumStyle500(
            fontSize: 13,
            fontColor: AppColors.textLight,
          ),
        ),
      ],
    );
  }

  Future<void> _launchPlayStore(BuildContext context) async {
    final uri = Uri.parse(_playStoreUrl);
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
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.landingPlayStoreOpenError),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
