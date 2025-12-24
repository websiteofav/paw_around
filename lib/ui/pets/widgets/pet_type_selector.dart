import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_bloc.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_event.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_strings.dart';
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
                const Text(
                  AppStrings.petType,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Dog and Cat row
            Row(
              children: [
                Expanded(
                  child: _PetTypeOption(
                    label: AppStrings.dog,
                    icon: AppIcons.dogIcon,
                    isSelected: selectedSpecies == 'dog',
                    onTap: () {
                      context.read<PetFormBloc>().add(const SelectSpecies('Dog'));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PetTypeOption(
                    label: AppStrings.cat,
                    icon: AppIcons.catIcon,
                    isSelected: selectedSpecies == 'cat',
                    onTap: () {
                      context.read<PetFormBloc>().add(const SelectSpecies('Cat'));
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Other option (full width)
            _PetTypeOption(
              label: AppStrings.other,
              icon: AppIcons.otherPetIcon,
              isSelected: selectedSpecies == 'other',
              showCheckmark: true,
              onTap: () {
                context.read<PetFormBloc>().add(const SelectSpecies('Other'));
              },
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
                child: const Text(
                  AppStrings.petTypeOtherHelper,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],

            // Error message
            if (state.errors['species'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  state.errors['species']!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
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
  final bool showCheckmark;
  final VoidCallback onTap;

  const _PetTypeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    this.showCheckmark = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onPressed: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: showCheckmark ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            if (showCheckmark) ...[
              AnimatedCheckmark(isVisible: isSelected),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: SizedBox(width: isSelected ? 8 : 0),
              ),
            ],
            SvgPicture.asset(
              icon,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                isSelected ? AppColors.primary : AppColors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
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
