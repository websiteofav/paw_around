import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

class PetOverviewPersonalitySection extends StatelessWidget {
  final PetModel pet;
  const PetOverviewPersonalitySection({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.personality,
              style: AppTextStyles.boldStyle700(
                  fontSize: 18, fontColor: AppColors.grey1100)),
          const SizedBox(height: 12),
          if (pet.personality.isEmpty)
            _EmptyPersonality(pet: pet)
          else
            _PersonalityChips(traits: pet.personality),
        ],
      ),
    );
  }
}

class _EmptyPersonality extends StatelessWidget {
  final PetModel pet;
  const _EmptyPersonality({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.whatsPetLikeDay(pet.name),
            style: AppTextStyles.interRegularStyle400(
                fontSize: 16, fontColor: AppColors.grey600)),
        const SizedBox(height: 8),
        ScaleButton(
          onPressed: () => context.pushNamed(AppRoutes.addPet, extra: pet),
          child: Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              decoration: smoothDecoration(
                  cornerRadius: 22, color: AppColors.background3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  const Icon(Icons.add_circle,
                      color: AppColors.secondaryCTA, size: 18),
                  Text(AppStrings.addPersonality,
                      style: AppTextStyles.mediumStyle500(
                          fontSize: 13, fontColor: AppColors.secondaryCTA)),
                ],
              )),
        ),
      ],
    );
  }
}

class _PersonalityChips extends StatelessWidget {
  final List<String> traits;
  const _PersonalityChips({required this.traits});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: traits.map((t) => _Chip(label: t)).toList(),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: smoothDecoration(
        cornerRadius: 24,
        color: AppColors.background3,
        side: const BorderSide(color: AppColors.border),
      ),
      child: Text(label,
          style: AppTextStyles.interMediumStyle500(
              fontSize: 13, fontColor: AppColors.grey1000)),
    );
  }
}
