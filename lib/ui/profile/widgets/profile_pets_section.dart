import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/models/pets/pet_model.dart';

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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              AppStrings.myPets,
              style: const TextStyle(
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.pets,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            AppStrings.noPetsAddedYet,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            AppStrings.addFirstPetToStart,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
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
    return InkWell(
      onTap: () {
        context.pushNamed(AppRoutes.petOverview, extra: pet);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
            const SizedBox(width: 16),

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
                  const SizedBox(height: 2),
                  Text(
                    _formatAge(pet.dateOfBirth),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
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
    return InkWell(
      onTap: () {
        context.pushNamed(AppRoutes.addPet);
      },
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
              child: const Icon(
                Icons.add,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              AppStrings.addAnotherPet,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
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

    if (months < 12) {
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
