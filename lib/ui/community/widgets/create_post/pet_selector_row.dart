import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/pet_model.dart';

/// Horizontal row of the user's pets to pick which one this lost report is
/// about, plus a trailing tile to add a new pet.
class PetSelectorRow extends StatelessWidget {
  final List<PetModel> pets;
  final String? selectedPetId;
  final ValueChanged<PetModel> onSelect;
  final VoidCallback onAddPet;

  const PetSelectorRow({
    super.key,
    required this.pets,
    required this.selectedPetId,
    required this.onSelect,
    required this.onAddPet,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.selectYourPet,
          style: AppTextStyles.interRegularStyle400(
              fontSize: 14, fontColor: AppColors.grey1000),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 84,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final pet in pets) _buildPetTile(pet),
              _buildAddTile(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPetTile(PetModel pet) {
    final isSelected = pet.id == selectedPetId;
    final hasImage = pet.imagePath != null && pet.imagePath!.startsWith('http');
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () => onSelect(pet),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: smoothDecoration(
                    cornerRadius: 16,
                    color: AppColors.iconBgLight,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.secondaryCTA
                          : Colors.transparent,
                      width: 2,
                    ),
                    image: hasImage
                        ? DecorationImage(
                            image: NetworkImage(pet.imagePath!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: hasImage
                      ? null
                      : const Icon(Icons.pets,
                          color: AppColors.secondaryCTA, size: 24),
                ),
                if (isSelected)
                  Positioned(
                    right: 0,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.secondaryCTA, width: 1),
                      ),
                      child: const Icon(Icons.check,
                          size: 12, color: AppColors.secondaryCTA),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              pet.name,
              style: AppTextStyles.mediumStyle500(
                fontSize: 12,
                fontColor:
                    isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTile() {
    return GestureDetector(
      onTap: onAddPet,
      child: Column(
        children: [
          DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(16),
            color: AppColors.neutral300,
            strokeWidth: 1.5,
            dashPattern: const [5, 4],
            padding: EdgeInsets.zero,
            child: const SizedBox(
              width: 56,
              height: 56,
              child: Center(
                child: Icon(Icons.add, color: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const SizedBox(width: 56, height: 14),
        ],
      ),
    );
  }
}
