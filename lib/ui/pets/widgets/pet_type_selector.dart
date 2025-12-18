import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_bloc.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_event.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';

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
            const Text(
              AppStrings.petType,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Dog and Cat row
            Row(
              children: [
                Expanded(
                  child: _PetTypeOption(
                    label: AppStrings.dog,
                    icon: Icons.pets,
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
                    icon: Icons.pest_control_rodent_outlined,
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
              icon: Icons.cruelty_free_outlined,
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
          ],
        );
      },
    );
  }
}

class _PetTypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: showCheckmark ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            if (showCheckmark && isSelected) ...[
              Icon(
                Icons.check,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 20,
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
