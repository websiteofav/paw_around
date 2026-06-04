import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

class PetOverviewAboutSection extends StatelessWidget {
  final PetModel pet;
  const PetOverviewAboutSection({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.aboutPet(pet.name),
              style: AppTextStyles.boldStyle700(
                  fontSize: 18, fontColor: AppColors.grey1100)),
          const SizedBox(height: 8),
          _MetricsRow(pet: pet),
          const SizedBox(height: 16),
          if (pet.notes.isNotEmpty)
            Text(pet.notes,
                style: AppTextStyles.interRegularStyle400(
                    fontSize: 16, fontColor: AppColors.grey600))
          else
            ScaleButton(
              onPressed: () => context.pushNamed(AppRoutes.addPet, extra: pet),
              child: Container(
                height: 36,
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                decoration: smoothDecoration(
                    cornerRadius: 999, color: AppColors.background3),
                child: Row(
                  spacing: 4,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_circle,
                        color: AppColors.secondaryCTA, size: 18),
                    Text(AppStrings.addBio,
                        style: AppTextStyles.mediumStyle500(
                            fontSize: 13, fontColor: AppColors.secondaryCTA)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  final PetModel pet;
  const _MetricsRow({required this.pet});

  @override
  Widget build(BuildContext context) {
    final weightVal = pet.weight > 0
        ? '${pet.weight.toStringAsFixed(1)} ${AppStrings.kgUnit}'
        : AppStrings.valueNotSet;
    final heightVal = pet.height > 0
        ? '${pet.height.toStringAsFixed(1)} ${AppStrings.cmUnit}'
        : AppStrings.valueNotSet;
    final colourVal =
        pet.colour.isNotEmpty ? pet.colour : AppStrings.valueNotSet;
    final sexVal = pet.gender.isNotEmpty ? pet.gender : AppStrings.valueNotSet;

    return Row(
      children: [
        _MetricBox(label: AppStrings.weightLabel, value: weightVal),
        const SizedBox(width: 8),
        _MetricBox(label: AppStrings.heightLabel, value: heightVal),
        const SizedBox(width: 8),
        _MetricBox(label: AppStrings.colour, value: colourVal),
        const SizedBox(width: 8),
        _MetricBox(label: AppStrings.sexLabel, value: sexVal),
      ],
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;
  const _MetricBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 82,
        decoration: smoothDecoration(
          cornerRadius: 14,
          color: AppColors.background3,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.interRegularStyle400(
                    fontSize: 16, fontColor: AppColors.grey800)),
            const SizedBox(height: 2),
            Text(value,
                textAlign: TextAlign.center,
                style: AppTextStyles.interSemiBoldStyle600(
                    fontSize: 16, fontColor: AppColors.secondaryCTA)),
          ],
        ),
      ),
    );
  }
}
