import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

class PetOverviewVaccinesSection extends StatelessWidget {
  final PetModel pet;

  const PetOverviewVaccinesSection({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final upcomingCount = pet.upcomingVaccinesCount;
    final headerText = upcomingCount > 0
        ? '${AppStrings.vaccines} ($upcomingCount ${AppStrings.comingUp})'
        : AppStrings.vaccines;

    return Container(
      decoration: smoothDecoration(
        cornerRadius: 24,
        color: AppColors.white,
        side: const BorderSide(color: AppColors.border),
        shadows: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(
                  Icons.vaccines_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  headerText,
                  style: AppTextStyles.semiBoldStyle600(
                    fontSize: 16,
                    fontColor: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (pet.vaccines.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                AppStrings.noVaccinesAdded,
                style: AppTextStyles.regularStyle400(
                  fontSize: 14,
                  fontColor: AppColors.textSecondary,
                ),
              ),
            )
          else
            ...pet.vaccines.asMap().entries.map((entry) {
              final index = entry.key;
              final vaccine = entry.value;
              final isLast = index == pet.vaccines.length - 1;

              return Column(
                children: [
                  _VaccineRow(pet: pet, vaccine: vaccine),
                  if (!isLast)
                    const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: AppColors.border,
                    ),
                ],
              );
            }),
          const Divider(height: 1, color: AppColors.border),
          _AddVaccineRow(pet: pet),
        ],
      ),
    );
  }
}

class _AddVaccineRow extends StatelessWidget {
  final PetModel pet;

  const _AddVaccineRow({required this.pet});

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onPressed: () {
        context.pushNamed(
          AppRoutes.addVaccine,
          extra: {'pet': pet},
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
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
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppStrings.addVaccine,
              style: AppTextStyles.mediumStyle500(
                fontSize: 15,
                fontColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VaccineRow extends StatelessWidget {
  final PetModel pet;
  final VaccineModel vaccine;

  const _VaccineRow({required this.pet, required this.vaccine});

  @override
  Widget build(BuildContext context) {
    final bool hasNextDueDate = vaccine.nextDueDate != null;
    final daysUntilDue =
        vaccine.nextDueDate?.difference(DateTime.now()).inDays ?? 0;
    final isOverdue = daysUntilDue < 0;
    final isDueSoon = daysUntilDue >= 0 && daysUntilDue <= 30;
    final isSnoozed = vaccine.isSnoozed;

    return ScaleButton(
      onPressed: () {
        context.pushNamed(
          AppRoutes.addVaccine,
          extra: {
            'pet': pet,
            'vaccine': vaccine,
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSnoozed
                    ? AppColors.warning
                    : isOverdue
                        ? AppColors.error
                        : isDueSoon
                            ? AppColors.warning
                            : AppColors.success,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        vaccine.vaccineName,
                        style: AppTextStyles.mediumStyle500(
                          fontSize: 15,
                          fontColor: AppColors.textPrimary,
                        ),
                      ),
                      if (isSnoozed) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: smoothDecoration(
                            cornerRadius: 4,
                            color: AppColors.warning.withValues(alpha: 0.15),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.snooze,
                                size: 10,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                AppStrings.snoozed,
                                style: AppTextStyles.semiBoldStyle600(
                                  fontSize: 10,
                                  fontColor: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (hasNextDueDate) ...[
                    const SizedBox(height: 2),
                    Text(
                      isSnoozed
                          ? AppStrings.tapToUnsnooze
                          : isOverdue
                              ? AppStrings.overdueByDays.replaceAll(
                                  '%s', daysUntilDue.abs().toString())
                              : daysUntilDue == 0
                                  ? AppStrings.dueToday
                                  : AppStrings.dueInDays.replaceAll(
                                      '%s', daysUntilDue.abs().toString()),
                      style: AppTextStyles.regularStyle400(
                        fontSize: 12,
                        fontColor: isOverdue && !isSnoozed
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
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
}
