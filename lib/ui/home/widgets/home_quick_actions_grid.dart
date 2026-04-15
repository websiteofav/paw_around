import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

class HomeQuickActionsGrid extends StatelessWidget {
  final VoidCallback onVaccines;
  final VoidCallback onTickFlea;
  final VoidCallback onGrooming;
  final VoidCallback onReportLost;

  const HomeQuickActionsGrid({
    super.key,
    required this.onVaccines,
    required this.onTickFlea,
    required this.onGrooming,
    required this.onReportLost,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.quickActions,
            style: AppTextStyles.boldStyle700(
                fontSize: 18, fontColor: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _ActionCard(
                    label: AppStrings.vaccines,
                    icon: AppIcons.vaccineIcon,
                    bgColor: AppColors.quickActionVaccines,
                    onTap: onVaccines)),
            const SizedBox(width: 12),
            Expanded(
                child: _ActionCard(
                    label: AppStrings.tickAndFlea,
                    icon: AppIcons.tickAndFleaIcon,
                    bgColor: AppColors.quickActionTickFlea,
                    onTap: onTickFlea)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _ActionCard(
                    label: AppStrings.grooming,
                    icon: AppIcons.groomingIcon,
                    bgColor: AppColors.quickActionGrooming,
                    onTap: onGrooming)),
            const SizedBox(width: 12),
            Expanded(
                child: _ActionCard(
                    label: AppStrings.reportLost,
                    icon: AppIcons.reportLostIcon,
                    bgColor: AppColors.quickActionLost,
                    onTap: onReportLost)),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String label;
  final String icon;
  final Color bgColor;
  final VoidCallback onTap;
  const _ActionCard(
      {required this.label,
      required this.icon,
      required this.bgColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onPressed: onTap,
      child: Container(
        height: 160,
        width: 170,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: bgColor),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              left: 0,
              bottom: 40,
              child: Image.asset(icon),
            ),
            if (label == AppStrings.vaccines)
              Positioned(
                  right: 28,
                  left: 28,
                  bottom: 36,
                  child: Container(
                    height: 18,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12)),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors.grey100,
                          AppColors.white,
                        ],
                        stops: [0.7, 1.0],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(AppStrings.recommended,
                        style: AppTextStyles.interSemiBoldStyle600(
                            fontColor: AppColors.grey1000, fontSize: 8)),
                  )),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.grey1000,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 4,
                  children: [
                    Text(label,
                        style: AppTextStyles.interMediumStyle500(
                            fontSize: 16, fontColor: AppColors.white)),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                          color: AppColors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_forward_ios,
                          size: 12, color: AppColors.grey1000),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
