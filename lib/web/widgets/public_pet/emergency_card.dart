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
      decoration: BoxDecoration(
        color: AppColors.surface,
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.only(
                  topLeft: AppBorderRadius.lg.topLeft,
                  bottomLeft: AppBorderRadius.lg.bottomLeft,
                ),
              ),
            ),
          ),
          Padding(
            padding: AppEdgeInsets.cardPadding,
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
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
