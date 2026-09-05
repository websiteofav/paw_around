import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/text_styles.dart';

/// Icon-in-circle row used for date/time, location and payment lines on the
/// Upcoming Session screen. [trailingLabel] renders as an underlined link.
class UpcomingSessionDetailRow extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String? subtitle;
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;

  const UpcomingSessionDetailRow({
    super.key,
    required this.iconAsset,
    required this.title,
    this.subtitle,
    this.trailingLabel,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.background3,
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            iconAsset,
            width: 20,
            height: 20,
            color: AppColors.secondaryCTA,
            colorBlendMode: BlendMode.srcIn,
          ),
        ),
        AppSpacing.horizontal12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.interBoldStyle700(
                    fontSize: 16, fontColor: AppColors.grey1000),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppTextStyles.interRegularStyle400(
                      fontSize: 12, fontColor: AppColors.grey600),
                ),
            ],
          ),
        ),
        if (trailingLabel != null)
          GestureDetector(
            onTap: onTrailingTap,
            child: Text(
              trailingLabel!,
              style: AppTextStyles.interBoldStyle700(
                fontSize: 12,
                fontColor: AppColors.secondaryCTA,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
      ],
    );
  }
}
