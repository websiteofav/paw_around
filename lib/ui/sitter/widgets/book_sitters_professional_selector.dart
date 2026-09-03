import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/sitters/professional_model.dart';

/// "Select Professional" row on the Book Sitters screen — mock data only,
/// see ProfessionalModel's doc comment.
class BookSittersProfessionalSelector extends StatelessWidget {
  final String? selectedId;
  final ValueChanged<String> onSelect;

  const BookSittersProfessionalSelector({
    super.key,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.selectProfessional,
          style: AppTextStyles.interRegularStyle400(
            fontSize: 14,
            fontColor: AppColors.grey1000,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: ProfessionalModel.mockProfessionals
              .map((professional) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _ProfessionalCard(
                      professional: professional,
                      isSelected: professional.id == selectedId,
                      onTap: () => onSelect(professional.id),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _ProfessionalCard extends StatelessWidget {
  final ProfessionalModel professional;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProfessionalCard({
    required this.professional,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = professional.isAvailable;

    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Container(
        height: 180,
        decoration: smoothDecoration(
            side: BorderSide(
                color: isSelected ? AppColors.secondaryCTA : AppColors.grey100),
            borderRadius: AppSmoothRadius.custom(24)),
        width: 110,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: [
                    Icon(
                      Icons.person,
                      size: 116,
                      color: isAvailable
                          ? AppColors.secondaryCTA
                          : AppColors.textDisabled,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      professional.name,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.interBoldStyle700(
                        fontSize: 16,
                        fontColor: AppColors.grey1000,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!isAvailable)
                      Text(
                        AppStrings.unavailable,
                        style: AppTextStyles.interMediumStyle500(
                          fontSize: 14,
                          fontColor: AppColors.grey1000,
                        ).copyWith(decoration: TextDecoration.underline),
                      ),
                  ],
                ),
                // if (isSelected)
                //   Positioned(
                //     right: -2,
                //     top: -2,
                //     child: Container(
                //       padding: const EdgeInsets.all(2),
                //       decoration: const BoxDecoration(
                //         color: AppColors.white,
                //         shape: BoxShape.circle,
                //       ),
                //       child: const Icon(Icons.check_circle, size: 20, color: AppColors.secondaryCTA),
                //     ),
                //   ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
