import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_bloc.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_event.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

class PetTypeSelector extends StatelessWidget {
  const PetTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PetFormBloc, PetFormState>(
      builder: (context, state) {
        final selectedSpecies = state.species.toLowerCase();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  AppStrings.petType,
                  style: AppTextStyles.interRegularStyle400(
                      fontSize: 14, fontColor: AppColors.grey1000),
                ),
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: AppTextStyles.interRegularStyle400(
                      fontSize: 14, fontColor: AppColors.grey1000),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Dog and Cat row
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: _PetTypeOption(
                    label: AppStrings.dog,
                    icon: AppIcons.addPetDogIcon,
                    isSelected: selectedSpecies == 'dog',
                    onTap: () {
                      context
                          .read<PetFormBloc>()
                          .add(const SelectSpecies('Dog'));
                    },
                  ),
                ),
                Expanded(
                  child: _PetTypeOption(
                    label: AppStrings.cat,
                    icon: AppIcons.addPetCatIcon,
                    isSelected: selectedSpecies == 'cat',
                    onTap: () {
                      context
                          .read<PetFormBloc>()
                          .add(const SelectSpecies('Cat'));
                    },
                  ),
                ),
              ],
            ),

            // Helper text when Other is selected
            if (selectedSpecies == 'other') ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppStrings.petTypeOtherHelper,
                  style: AppTextStyles.regularStyle400(
                      fontSize: 13, fontColor: AppColors.textSecondary),
                ),
              ),
            ],

            // Error message
            if (state.errors['species'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  state.errors['species']!,
                  style: AppTextStyles.regularStyle400(
                      fontSize: 12, fontColor: AppColors.error),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PetTypeOption extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PetTypeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onPressed: onTap,
      child: AnimatedContainer(
        height: 104,
        width: 168,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        alignment: Alignment.center,
        //  padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondaryCTA : AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: isSelected ? AppColors.secondaryCTA : AppColors.neutral300,
              width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon,
              width: 52,
              height: 52,
              colorFilter: ColorFilter.mode(
                isSelected ? AppColors.white : AppColors.textPrimary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: AppTextStyles.mediumStyle500(
                fontSize: 16,
                fontColor: isSelected ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated checkmark that scales in/out
class AnimatedCheckmark extends StatelessWidget {
  final bool isVisible;

  const AnimatedCheckmark({super.key, required this.isVisible});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.elasticOut,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 150),
        child: const Icon(
          Icons.check,
          color: AppColors.primary,
          size: 20,
        ),
      ),
    );
  }
}
