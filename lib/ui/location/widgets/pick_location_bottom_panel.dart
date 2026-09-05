import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

/// Persistent bottom panel on the Pick Location screen: an info banner, the
/// currently-resolved address, and the Confirm and Proceed button.
class PickLocationBottomPanel extends StatelessWidget {
  final String? address;
  final String? area;
  final bool isResolving;
  final bool isConfirming;
  final VoidCallback? onConfirm;

  const PickLocationBottomPanel({
    super.key,
    required this.address,
    required this.area,
    required this.isResolving,
    this.isConfirming = false,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: smoothDecoration(
        borderRadius: AppSmoothRadius.custom(20),
        color: AppColors.white,
        shadows: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: smoothDecoration(
              cornerRadius: 8,
              color: AppColors.background3,
            ),
            child: Row(
              children: [
                Image.asset(
                  AppIcons.informationIcon,
                  color: AppColors.secondaryCTA,
                  height: 20,
                  width: 20,
                ),
                AppSpacing.horizontal8,
                Expanded(
                  child: Text(
                    AppStrings.placePinBannerText,
                    style: AppTextStyles.interSemiBoldStyle600(
                      fontSize: 12,
                      fontColor: AppColors.secondaryCTA,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vertical16,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: smoothDecoration(
                  cornerRadius: 10,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  AppIcons.locationPinIcon,
                  color: AppColors.grey1000,
                  colorBlendMode: BlendMode.srcIn,
                  height: 12,
                  width: 12,
                ),
              ),
              AppSpacing.horizontal12,
              Expanded(
                child: isResolving
                    ? Text(
                        AppStrings.resolvingAddress,
                        style: AppTextStyles.interRegularStyle400(
                          fontSize: 12,
                          fontColor: AppColors.grey600,
                        ),
                      )
                    : address == null
                        ? Text(
                            AppStrings.searchOrDragPinPrompt,
                            style: AppTextStyles.interRegularStyle400(
                              fontSize: 14,
                              fontColor: AppColors.grey600,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (area != null)
                                Text(
                                  area!,
                                  style: AppTextStyles.interBoldStyle700(
                                    fontSize: 16,
                                    fontColor: AppColors.grey1000,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              Text(
                                address ?? '',
                                style: AppTextStyles.interRegularStyle400(
                                  fontSize: 12,
                                  fontColor: AppColors.grey600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
              ),
            ],
          ),
          AppSpacing.vertical16,
          const Divider(color: AppColors.border, height: 1),
          AppSpacing.vertical16,
          CommonButton(
            text: AppStrings.confirmAndProceed,
            onPressed: onConfirm,
            isLoading: isConfirming,
            customColor: AppColors.secondaryCTA,
            borderRadius: 12,
          ),
        ],
      ),
    );
  }
}
