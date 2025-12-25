import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

class ProfilePetsSection extends StatelessWidget {
  final List<PetModel> pets;

  const ProfilePetsSection({
    super.key,
    required this.pets,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              AppStrings.myPets,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Pet List
          if (pets.isEmpty) _buildEmptyState(context) else _buildPetList(context),

          // Divider
          const Divider(height: 1, color: AppColors.border),

          // Add another pet row
          _buildAddPetRow(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pets,
              size: 40,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            AppStrings.noPetsAddedYet,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            AppStrings.addFirstPetToStart,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          CommonButton(
            text: AppStrings.addPet,
            variant: ButtonVariant.primary,
            size: ButtonSize.small,
            icon: Icons.add,
            isFullWidth: false,
            onPressed: () => context.pushNamed(AppRoutes.addPet),
          ),
        ],
      ),
    );
  }

  Widget _buildPetList(BuildContext context) {
    return Column(
      children: [
        // Pet card container with border
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: pets.asMap().entries.map((entry) {
              final index = entry.key;
              final pet = entry.value;
              final isLast = index == pets.length - 1;

              return Column(
                children: [
                  _buildPetRow(context, pet),
                  if (!isLast) const Divider(height: 1, indent: 80, color: AppColors.border),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPetRow(BuildContext context, PetModel pet) {
    return ScaleButton(
      onPressed: () {
        context.pushNamed(AppRoutes.petOverview, extra: pet);
      },
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Circular pet avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getSpeciesColor(pet.species),
              ),
              child: ClipOval(
                child: pet.imagePath != null && pet.imagePath!.startsWith('http')
                    ? Image.network(
                        pet.imagePath!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultPetIcon(pet.species);
                        },
                      )
                    : _buildDefaultPetIcon(pet.species),
              ),
            ),
            const SizedBox(width: 18),

            // Pet info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _formatAge(pet.dateOfBirth),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getSpeciesColor(pet.species),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          pet.species,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Chevron
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPetRow(BuildContext context) {
    return ScaleButton(
      onPressed: () {
        context.pushNamed(AppRoutes.addPet);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.add,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppStrings.addAnotherPet,
              style: AppTextStyles.mediumStyle500(fontSize: 15, fontColor: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultPetIcon(String species) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      child: Icon(
        Icons.pets,
        size: 28,
        color: AppColors.primary,
      ),
    );
  }

  String _formatAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    final months = (now.year - dateOfBirth.year) * 12 + (now.month - dateOfBirth.month);

    if (months == 0) {
      final days = now.difference(dateOfBirth).inDays;
      return '$days ${AppStrings.daysOld}';
    } else if (months < 12) {
      return '$months ${AppStrings.monthsOld}';
    } else {
      final years = months ~/ 12;
      return '$years ${AppStrings.yearsOld}';
    }
  }

  Color _getSpeciesColor(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return const Color(0xFFFFF3E0); // Light orange/cream
      case 'cat':
        return const Color(0xFFFCE4EC); // Light pink
      case 'bird':
        return const Color(0xFFE3F2FD); // Light blue
      case 'fish':
        return const Color(0xFFE0F7FA); // Light cyan
      default:
        return const Color(0xFFF3E5F5); // Light purple
    }
  }
}
