import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
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
        final selectedId =
            state is PetListLoaded ? state.selectedPet?.id : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.myBabies,
                style: AppTextStyles.boldStyle700(
                    fontSize: 18, fontColor: AppColors.grey1000)),
            const SizedBox(height: 16),
            SizedBox(
              height: 136,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 4),
                children: [
                  ...pets.map((pet) => _PetAvatar(
                        pet: pet,
                        isSelected: pet.id == selectedId,
                      )),
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
  final bool isSelected;
  const _PetAvatar({required this.pet, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: ScaleButton(
        onPressed: () =>
            context.read<PetListBloc>().add(SelectPet(petId: pet.id)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    color: AppColors.iconBgLight,
                    borderRadius: BorderRadius.circular(24),
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 2.5)
                        : Border.all(color: Colors.transparent, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.shadowOverlay.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3)),
                      BoxShadow(
                          color: AppColors.shadowOverlay.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 8)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: pet.imagePath != null && pet.imagePath!.isNotEmpty
                        ? Image.network(pet.imagePath!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.pets,
                                color: AppColors.primary, size: 28))
                        : const Icon(Icons.pets,
                            color: AppColors.primary, size: 28),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    bottom: -4,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: 86,
              child: Text(
                pet.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.interMediumStyle500(
                    fontSize: 13,
                    fontColor: isSelected
                        ? AppColors.primary
                        : AppColors.grey1000),
              ),
            ),
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
      padding: const EdgeInsets.only(right: 4),
      child: ScaleButton(
        onPressed: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1.5),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.shadowOverlay.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3)),
                ],
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.primary, size: 30),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: 86,
              child: Text(
                AppStrings.addPet,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.interMediumStyle500(
                    fontSize: 13, fontColor: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
