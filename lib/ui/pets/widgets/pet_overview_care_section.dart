import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

class PetOverviewCareSection extends StatelessWidget {
  final PetModel pet;
  const PetOverviewCareSection({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.careSection,
              style: AppTextStyles.boldStyle700(
                  fontSize: 18, fontColor: AppColors.grey1100)),
          const SizedBox(height: 12),
          _CareCard(
            bgColor: AppColors.quickActionVaccines,
            iconPath: AppIcons.vaccineIcon,
            categoryLabel: AppStrings.vaccines,
            categoryIconPath: AppIcons.syringIcon,
            recommendLabel: pet.vaccines.isEmpty
                ? AppStrings.getRecommedationText(pet.name)
                : null,
            title: pet.vaccines.isEmpty
                ? AppStrings.startVaccinationJourney
                : AppStrings.vaccinations,
            subtitle: AppStrings.protectFromSeriousDiseases,
            ctaText: pet.vaccines.isEmpty
                ? AppStrings.startVaccination
                : AppStrings.viewVaccines,
            onTap: () =>
                context.pushNamed(AppRoutes.addVaccine, extra: {'pet': pet}),
          ),
          const SizedBox(height: 12),
          _CareCard(
            bgColor: AppColors.quickActionTickFlea,
            iconPath: AppIcons.tickAndFleaIcon,
            categoryLabel: AppStrings.tickAndFlea,
            categoryIconPath: AppIcons.bugIcon,
            title: AppStrings.preventTicksFleasEarly,
            subtitle: AppStrings.keepPetSafeItchFree,
            ctaText: pet.tickFleaSettings == null
                ? AppStrings.addProtection
                : AppStrings.viewSchedule,
            onTap: () =>
                context.pushNamed(AppRoutes.tickFleaSettings, extra: pet),
          ),
          const SizedBox(height: 12),
          _CareCard(
            bgColor: AppColors.quickActionGrooming,
            iconPath: AppIcons.groomingIcon,
            categoryLabel: AppStrings.grooming,
            categoryIconPath: AppIcons.scissorIcon,
            title: AppStrings.keepPetCleanHappy,
            subtitle: AppStrings.bookFirstGroomingSession,
            ctaText: pet.groomingSettings == null
                ? AppStrings.addGrooming
                : AppStrings.viewSchedule,
            onTap: () =>
                context.pushNamed(AppRoutes.groomingSettings, extra: pet),
          ),
        ],
      ),
    );
  }
}

class _CareCard extends StatelessWidget {
  final Color bgColor;
  final String iconPath;
  final String categoryLabel;
  final String? recommendLabel;
  final String categoryIconPath;
  final String title;
  final String subtitle;
  final String ctaText;
  final VoidCallback onTap;

  const _CareCard({
    required this.bgColor,
    required this.iconPath,
    required this.categoryLabel,
    this.recommendLabel,
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.onTap,
    required this.categoryIconPath,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onPressed: onTap,
      child: Container(
        decoration: smoothDecoration(cornerRadius: 20, color: bgColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with category chip overlaid
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.asset(
                    iconPath,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: smoothDecoration(
                        cornerRadius: 20, color: AppColors.grey1100),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        categoryIconPath.contains(".png")
                            ? Image.asset(
                                categoryIconPath,
                                width: 16,
                                height: 16,
                                color: AppColors.white,
                              )
                            : SvgPicture.asset(categoryIconPath,
                                width: 16,
                                height: 16,
                                colorFilter: const ColorFilter.mode(
                                    AppColors.white, BlendMode.srcIn)),
                        const SizedBox(width: 6),
                        Text(categoryLabel,
                            style: AppTextStyles.interSemiBoldStyle600(
                                fontSize: 12, fontColor: AppColors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Content below image
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (recommendLabel != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: smoothDecoration(
                          cornerRadius: 20, color: AppColors.grey900),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle,
                              size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(recommendLabel!,
                              style: AppTextStyles.interMediumStyle500(
                                  fontSize: 12, fontColor: AppColors.primary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(title,
                      style: AppTextStyles.interBoldStyle700(
                          fontSize: 15, fontColor: AppColors.grey1000)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: AppTextStyles.interMediumStyle500(
                          fontSize: 14, fontColor: AppColors.grey1000)),
                  const SizedBox(height: 24),
                  // CTA button — white bg, "+" icon on left
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: smoothDecoration(
                        cornerRadius: 44,
                        color: AppColors.white,
                        shadows: [
                          BoxShadow(
                              color: AppColors.shadowOverlay
                                  .withValues(alpha: 0.10),
                              blurRadius: 6,
                              offset: const Offset(0, 3)),
                          BoxShadow(
                              color: AppColors.shadowOverlay
                                  .withValues(alpha: 0.09),
                              blurRadius: 10,
                              offset: const Offset(0, 10)),
                          BoxShadow(
                              color: AppColors.shadowOverlay
                                  .withValues(alpha: 0.05),
                              blurRadius: 14,
                              offset: const Offset(0, 23)),
                          BoxShadow(
                              color: AppColors.shadowOverlay
                                  .withValues(alpha: 0.01),
                              blurRadius: 16,
                              offset: const Offset(0, 41)),
                        ]),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_circle,
                            size: 24, color: AppColors.grey1000),
                        const SizedBox(width: 8),
                        Text(ctaText,
                            style: AppTextStyles.interBoldStyle700(
                                fontSize: 16, fontColor: AppColors.grey1000)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
