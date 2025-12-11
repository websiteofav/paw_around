import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/pets/pets_bloc.dart';
import 'package:paw_around/bloc/pets/pets_event.dart';
import 'package:paw_around/bloc/pets/pets_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';

class GenderSelection extends StatelessWidget {
  const GenderSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PetsBloc, PetsState>(
      builder: (context, state) {
        if (state is PetFormState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppStrings.gender,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildGenderButton(
                      context,
                      AppStrings.male,
                      state.gender == AppStrings.male,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGenderButton(
                      context,
                      AppStrings.female,
                      state.gender == AppStrings.female,
                    ),
                  ),
                ],
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildGenderButton(BuildContext context, String gender, bool isSelected) {
    return GestureDetector(
      onTap: () => context.read<PetsBloc>().add(SelectPetGender(gender: gender)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          gender,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
