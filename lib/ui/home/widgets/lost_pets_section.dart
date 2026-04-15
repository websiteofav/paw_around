import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

class LostPetItem {
  final String id;
  final String name;
  final String distance;
  final String? imageUrl;
  final String? breed;
  final String? color;
  final int? missingDays;

  const LostPetItem({
    required this.id,
    required this.name,
    required this.distance,
    this.imageUrl,
    this.missingDays,
    this.breed,
    this.color,
  });
}

class LostPetsSection extends StatelessWidget {
  final List<LostPetItem> pets;
  final VoidCallback? onSeeAllTap;
  final Function(LostPetItem)? onPetTap;

  const LostPetsSection({
    super.key,
    required this.pets,
    this.onSeeAllTap,
    this.onPetTap,
  });

  @override
  Widget build(BuildContext context) {
    if (pets.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.lostPetsNearYou,
                style: AppTextStyles.boldStyle700(
                    fontSize: 18, fontColor: AppColors.grey1000)),
            GestureDetector(
              onTap: onSeeAllTap,
              child: Row(children: [
                Text(AppStrings.seeAll,
                    style: AppTextStyles.interBoldStyle700(
                        fontSize: 16, fontColor: AppColors.secondaryCTA)),
                const Icon(Icons.chevron_right,
                    color: AppColors.secondaryCTA, size: 18),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (int i = 0; i < pets.length && i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(
                child: _LostPetCard(
                    pet: pets[i], onTap: () => onPetTap?.call(pets[i])),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _LostPetCard extends StatelessWidget {
  final LostPetItem pet;
  final VoidCallback? onTap;
  const _LostPetCard({required this.pet, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 264,
        width: 165,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: AppColors.shadowOverlay.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
          border: Border.all(color: AppColors.grey100),
        ),
        padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Missing badge
            Stack(
              children: [
                Hero(
                  tag: 'post-image-${pet.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: pet.imageUrl != null
                          ? Image.network(pet.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _Placeholder())
                          : _Placeholder(),
                    ),
                  ),
                ),
                if (pet.missingDays != null)
                  Positioned(
                    top: 0,
                    left: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              colors: [AppColors.white, AppColors.grey100],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight),
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12))),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: "${AppStrings.missing}:",
                                style: AppTextStyles.interRegularStyle400(
                                    fontSize: 10,
                                    fontColor: AppColors.grey1000),
                                children: [
                                  TextSpan(
                                    text: ' ${pet.missingDays} Days',
                                    style: AppTextStyles.interSemiBoldStyle600(
                                        fontSize: 10,
                                        fontColor: AppColors.grey1000),
                                  ),
                                ]),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pet.name,
                    style: AppTextStyles.interBoldStyle700(
                        fontSize: 14, fontColor: AppColors.grey1000),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  spacing: 4,
                  children: [
                    Text(pet.breed ?? '',
                        style: AppTextStyles.interRegularStyle400(
                            fontSize: 12, fontColor: AppColors.grey600)),
                    Text(".",
                        style: AppTextStyles.interRegularStyle400(
                            fontSize: 12, fontColor: AppColors.grey600)),
                    Flexible(
                      child: Text(
                        pet.color ?? '',
                        style: AppTextStyles.interRegularStyle400(
                            fontSize: 12, fontColor: AppColors.grey600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 2,
              children: [
                const Icon(Icons.gps_fixed, color: AppColors.grey600, size: 12),
                Flexible(
                  child: Text(
                    pet.distance,
                    style: AppTextStyles.interRegularStyle400(
                        fontSize: 12, fontColor: AppColors.grey600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: AppColors.surface,
        child: const Icon(Icons.pets, color: AppColors.textLight, size: 36));
  }
}
