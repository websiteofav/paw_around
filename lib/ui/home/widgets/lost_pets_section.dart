import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

class LostPetItem {
  final String id;
  final String name;
  final String distance;
  final String? imageUrl;

  const LostPetItem({
    required this.id,
    required this.name,
    required this.distance,
    this.imageUrl,
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
    if (pets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.lostPetsNearYou,
              style: AppTextStyles.semiBoldStyle600(fontSize: 18, fontColor: AppColors.textPrimary),
            ),
            GestureDetector(
              onTap: onSeeAllTap,
              child: Row(
                children: [
                  Text(
                    AppStrings.seeAll,
                    style: AppTextStyles.mediumStyle500(fontSize: 14, fontColor: AppColors.primary),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Pet cards row
        Row(
          children: [
            for (int i = 0; i < pets.length && i < 2; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(
                child: _LostPetCard(
                  pet: pets[i],
                  onTap: () => onPetTap?.call(pets[i]),
                ),
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

  const _LostPetCard({
    required this.pet,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Pet avatar - wrapped in Hero for smooth transition
            Hero(
              tag: 'post-image-${pet.id}',
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.iconBgLight,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: pet.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          pet.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.pets,
                              color: AppColors.primary,
                              size: 24,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.pets,
                        color: AppColors.primary,
                        size: 24,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Name and distance
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: AppTextStyles.semiBoldStyle600(fontSize: 16, fontColor: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pet.distance,
                    style: AppTextStyles.regularStyle400(fontSize: 14, fontColor: AppColors.primary),
                  ),
                ],
              ),
            ),
            // Chevron
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
