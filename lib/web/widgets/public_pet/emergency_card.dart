import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/pet_model.dart';

/// Shows pet notes. Only build when [pet.notes] is non-empty.
class PublicPetEmergencyCard extends StatelessWidget {
  final PetModel pet;

  const PublicPetEmergencyCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    if (pet.notes.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: AppEdgeInsets.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.lg,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.emergencyInfo,
            style: AppTextStyles.semiBoldStyle600(
              fontSize: 18,
              fontColor: AppColors.textPrimary,
            ),
          ),
          AppSpacing.vertical16,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.note_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  pet.notes,
                  style: AppTextStyles.regularStyle400(
                    fontSize: 14,
                    fontColor: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
