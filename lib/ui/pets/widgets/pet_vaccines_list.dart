import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_bloc.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_event.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';
import 'package:paw_around/utils/date_utils.dart';
import 'package:paw_around/constants/vaccine_constants.dart';

class PetVaccinesList extends StatelessWidget {
  const PetVaccinesList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PetFormBloc, PetFormState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.vaccinations,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                _buildVaccineDropdown(context),
              ],
            ),
            const SizedBox(height: 12),

            // Vaccines List
            if (state.vaccines.isEmpty) _buildEmptyState() else _buildVaccinesList(context, state.vaccines),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.patternColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            AppStrings.noVaccinesAddedYet,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.selectVaccineFromDropdown,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccineDropdown(BuildContext context) {
    final vaccineNames = VaccineConstants.allVaccines;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            hint: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                AppStrings.addVaccine,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            items: [
              // Add Vaccine option
              const DropdownMenuItem<String>(
                value: 'add_new',
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      AppStrings.addVaccine,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              const DropdownMenuItem<String>(
                value: 'divider',
                enabled: false,
                child: Divider(height: 1),
              ),
              // Existing vaccines
              ...vaccineNames.map((vaccineName) {
                return DropdownMenuItem<String>(
                  value: vaccineName,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.medical_services,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          vaccineName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            onChanged: (String? value) {
              if (value == null) {
                return;
              }

              if (value == 'add_new') {
                _navigateToAddVaccine(context);
              } else if (value != 'divider') {
                _addExistingVaccine(context, value);
              }
            },
            icon: const Icon(
              Icons.arrow_drop_down,
              color: AppColors.primary,
            ),
            style: const TextStyle(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVaccinesList(BuildContext context, List<VaccineModel> vaccines) {
    return Column(
      children: vaccines.map((vaccine) => _buildVaccineCard(context, vaccine)).toList(),
    );
  }

  Widget _buildVaccineCard(BuildContext context, VaccineModel vaccine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.patternColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Vaccine Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.medical_services,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Vaccine Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccine.vaccineName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${AppStrings.given}: ${AppDateUtils.formatDateShort(vaccine.dateGiven)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Next: ${AppDateUtils.formatDateShort(vaccine.nextDueDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Remove Button
          IconButton(
            onPressed: () => _removeVaccine(context, vaccine.id),
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: 20,
            ),
            tooltip: AppStrings.removeVaccine,
          ),
        ],
      ),
    );
  }

  void _addExistingVaccine(BuildContext context, String vaccineName) {
    final now = DateTime.now();
    final nextYear = DateTime(now.year + 1, now.month, now.day);

    final newVaccine = VaccineModel.create(
      vaccineName: vaccineName,
      dateGiven: now,
      nextDueDate: nextYear,
      notes: '',
      setReminder: true,
    );

    context.read<PetFormBloc>().add(AddVaccine(newVaccine));
  }

  void _navigateToAddVaccine(BuildContext context) async {
    final result = await context.pushNamed(AppRoutes.addVaccine);

    if (result is VaccineModel) {
      context.read<PetFormBloc>().add(AddVaccine(result));
    }
  }

  void _removeVaccine(BuildContext context, String vaccineId) {
    context.read<PetFormBloc>().add(RemoveVaccine(vaccineId));
  }
}
