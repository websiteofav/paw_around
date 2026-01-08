import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/pet_model.dart';

/// Bottom sheet for selecting between multiple pets
class PetSelectorBottomSheet extends StatelessWidget {
  final List<PetModel> pets;
  final String? selectedPetId;
  final void Function(PetModel pet) onPetSelected;

  const PetSelectorBottomSheet({
    super.key,
    required this.pets,
    required this.selectedPetId,
    required this.onPetSelected,
  });

  /// Show the bottom sheet and return selected pet
  static Future<void> show({
    required BuildContext context,
    required List<PetModel> pets,
    required String? selectedPetId,
    required void Function(PetModel pet) onPetSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PetSelectorBottomSheet(
        pets: pets,
        selectedPetId: selectedPetId,
        onPetSelected: onPetSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    AppStrings.switchPet,
                    style: AppTextStyles.boldStyle700(
                      fontSize: 20,
                      fontColor: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Spacer(),
                if (pets.length < 5)
                  Semantics(
                    button: true,
                    label: AppStrings.addPet,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                          context.pushNamed(AppRoutes.addPet);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppStrings.addPet,
                                style: AppTextStyles.mediumStyle500(
                                  fontSize: 14,
                                  fontColor: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Pet list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
              itemCount: pets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final pet = pets[index];
                final isSelected = pet.id == selectedPetId || (selectedPetId == null && index == 0);
                return _PetListTile(
                  pet: pet,
                  isSelected: isSelected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onPetSelected(pet);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PetListTile extends StatelessWidget {
  final PetModel pet;
  final bool isSelected;
  final VoidCallback onTap;

  const _PetListTile({
    required this.pet,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${pet.name}, ${_capitalize(pet.species)}${isSelected ? ', ${AppStrings.currentlySelected}' : ''}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.progressBarBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                // Pet avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.groomingGradientStart,
                        AppColors.groomingGradientEnd,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: pet.imagePath != null && pet.imagePath!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            pet.imagePath!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPawIcon(),
                          ),
                        )
                      : _buildPawIcon(),
                ),

                const SizedBox(width: 14),

                // Pet info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: AppTextStyles.boldStyle700(
                          fontSize: 16,
                          fontColor: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_capitalize(pet.species)} • ${pet.breed.isNotEmpty ? pet.breed : AppStrings.unknownBreed}',
                        style: AppTextStyles.regularStyle400(
                          fontSize: 13,
                          fontColor: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Selected indicator
                if (isSelected)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.white,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPawIcon() {
    return Center(
      child: SvgPicture.asset(
        AppIcons.pawPrintIcon,
        width: 24,
        height: 24,
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
