import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

class HomeMyBabiesSection extends StatelessWidget {
  const HomeMyBabiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PetListBloc, PetListState>(
      builder: (context, state) {
        final pets = state is PetListLoaded ? state.pets : <PetModel>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.myBabies,
                style: AppTextStyles.boldStyle700(
                    fontSize: 18, fontColor: AppColors.grey1000)),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...pets.map((pet) => _PetAvatar(pet: pet)),
                  _AddPetButton(
                      onTap: () => context.pushNamed(AppRoutes.addPet)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PetAvatar extends StatelessWidget {
  final PetModel pet;
  const _PetAvatar({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ScaleButton(
        onPressed: () => context.pushNamed(AppRoutes.petOverview, extra: pet),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                  color: AppColors.iconBgLight,
                  borderRadius: BorderRadius.circular(24)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: pet.imagePath != null && pet.imagePath!.isNotEmpty
                    ? Image.network(pet.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.pets,
                            color: AppColors.primary, size: 28))
                    : const Icon(Icons.pets,
                        color: AppColors.primary, size: 28),
              ),
            ),
            Text(pet.name,
                style: AppTextStyles.interMediumStyle500(
                    fontSize: 16, fontColor: AppColors.grey1000),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _AddPetButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddPetButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: ScaleButton(
        onPressed: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: AppColors.iconBgLight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border, width: 1.5),
              ),
              child: const Icon(Icons.add, color: AppColors.primary, size: 32),
            ),
            Text(AppStrings.addPet,
                style: AppTextStyles.interMediumStyle500(
                    fontSize: 16, fontColor: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
