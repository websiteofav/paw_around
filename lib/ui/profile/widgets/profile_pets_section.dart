import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_spacing.dart';
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              AppStrings.myPets,
              style: AppTextStyles.semiBoldStyle600(fontSize: 16, fontColor: AppColors.textPrimary),
            ),
          ),

          // Pet List or Empty State
          if (pets.isEmpty)
            _buildEmptyState(context)
          else ...[
            _buildPetList(context),
            if (pets.length > 2) ...[
              _buildViewAllPetsRow(context),
              const Divider(height: 1, color: AppColors.border),
            ],
            _buildAddPetRow(context),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.space24,
          vertical: AppConstants.space40,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Decorative icon with gradient
            Container(
              width: AppConstants.avatarSizeXLarge,
              height: AppConstants.avatarSizeXLarge,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0.05),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.pets_rounded,
                    size: 44,
                    color: AppColors.primary.withValues(alpha: 0.7),
                  ),
                  Positioned(
                    right: 18,
                    top: 18,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 14,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.vertical24,
            Text(
              AppStrings.noPetsAddedYet,
              style: AppTextStyles.semiBoldStyle600(
                fontSize: 18,
                fontColor: AppColors.textPrimary,
              ),
            ),
            AppSpacing.vertical8,
            Text(
              AppStrings.addFirstPetToStart,
              textAlign: TextAlign.center,
              style: AppTextStyles.regularStyle400(
                fontSize: 14,
                fontColor: AppColors.textSecondary.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
            AppSpacing.vertical24,
            CommonButton(
              text: AppStrings.addPet,
              variant: ButtonVariant.primary,
              size: ButtonSize.medium,
              icon: Icons.add_rounded,
              isFullWidth: false,
              onPressed: () => context.pushNamed(AppRoutes.addPet),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetList(BuildContext context) {
    // Show only first 2 pets if there are more than 2
    final displayPets = pets.length > 2 ? pets.take(2).toList() : pets;

    return Column(
      children: displayPets.asMap().entries.map((entry) {
        final index = entry.key;
        final pet = entry.value;
        final isLast = index == displayPets.length - 1;

        return Column(
          children: [
            _buildPetRow(context, pet),
            if (!isLast)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  height: 1,
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildViewAllPetsRow(BuildContext context) {
    return ScaleButton(
      onPressed: () => _showAllPetsBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.iconBgLight,
              ),
              child: const Icon(
                Icons.pets_rounded,
                size: 22,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'View all ${pets.length} pets',
                style: AppTextStyles.mediumStyle500(
                  fontSize: 15,
                  fontColor: AppColors.primary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllPetsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${AppStrings.myPets} (${pets.length})',
                style: AppTextStyles.semiBoldStyle600(fontSize: 18, fontColor: AppColors.textPrimary),
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            // Pet list
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: pets.length,
                separatorBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    height: 1,
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
                itemBuilder: (context, index) {
                  final pet = pets[index];
                  return _buildPetRow(context, pet);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetRow(BuildContext context, PetModel pet) {
    final speciesColor = _getSpeciesColor(pet.species);
    final hasImage = pet.imagePath != null && pet.imagePath!.startsWith('http');

    return ScaleButton(
      onPressed: () => context.pushNamed(AppRoutes.petOverview, extra: pet),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Pet avatar with shadow - wrapped in Hero for smooth transition
            Hero(
              tag: 'pet-avatar-${pet.id}',
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: speciesColor,
                  border: Border.all(
                    color: hasImage ? AppColors.white : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getSpeciesAccentColor(pet.species).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: hasImage
                      ? Image.network(
                          pet.imagePath!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildDefaultPetIcon(pet.species),
                        )
                      : _buildDefaultPetIcon(pet.species),
                ),
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
                    style: AppTextStyles.semiBoldStyle600(
                      fontSize: 17,
                      fontColor: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Species badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: speciesColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getSpeciesIcon(pet.species),
                              size: 12,
                              color: _getSpeciesAccentColor(pet.species),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              pet.species,
                              style: AppTextStyles.semiBoldStyle600(
                                fontSize: 12,
                                fontColor: _getSpeciesAccentColor(pet.species),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Age
                      Text(
                        _formatAge(pet.dateOfBirth),
                        style: AppTextStyles.regularStyle400(
                          fontSize: 13,
                          fontColor: AppColors.textSecondary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Chevron with circle
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPetRow(BuildContext context) {
    return ScaleButton(
      onPressed: () => context.pushNamed(AppRoutes.addPet),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.primary.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 24,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                AppStrings.addAnotherPet,
                style: AppTextStyles.mediumStyle500(
                  fontSize: 15,
                  fontColor: AppColors.primary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultPetIcon(String species) {
    return Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      child: Icon(
        _getSpeciesIcon(species),
        size: 28,
        color: _getSpeciesAccentColor(species),
      ),
    );
  }

  IconData _getSpeciesIcon(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return Icons.pets_rounded;
      case 'cat':
        return Icons.pets_rounded;
      case 'bird':
        return Icons.flutter_dash_rounded;
      case 'fish':
        return Icons.water_rounded;
      case 'rabbit':
        return Icons.cruelty_free_rounded;
      default:
        return Icons.pets_rounded;
    }
  }

  Color _getSpeciesAccentColor(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return const Color(0xFFE65100); // Deep orange
      case 'cat':
        return const Color(0xFFC2185B); // Deep pink
      case 'bird':
        return const Color(0xFF1565C0); // Deep blue
      case 'fish':
        return const Color(0xFF00838F); // Deep cyan
      case 'rabbit':
        return const Color(0xFF6A1B9A); // Deep purple
      default:
        return const Color(0xFF7B1FA2); // Purple
    }
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
