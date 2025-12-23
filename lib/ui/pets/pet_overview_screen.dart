import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';
import 'package:paw_around/repositories/pet_repository.dart';

class PetOverviewScreen extends StatelessWidget {
  final PetModel pet;

  const PetOverviewScreen({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PetListBloc, PetListState>(
      builder: (context, state) {
        // Get updated pet from state, fallback to passed pet
        final currentPet = state is PetListLoaded
            ? state.pets.firstWhere(
                (p) => p.id == pet.id,
                orElse: () => pet,
              )
            : pet;

        return _buildContent(context, currentPet);
      },
    );
  }

  Widget _buildContent(BuildContext context, PetModel pet) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          pet.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pet Info Card
              _buildPetInfoCard(pet),

              const SizedBox(height: 16),

              // Vaccines Section (only for dogs and cats)
              if (pet.supportsMedicalCare) ...[
                _buildVaccinesSection(context, pet),
                const SizedBox(height: 12),
              ],

              // Grooming Card
              _buildCareCard(
                context: context,
                icon: Icons.content_cut,
                title: AppStrings.grooming,
                subtitle: _getGroomingStatus(pet),
                onTap: () {
                  context.pushNamed(
                    AppRoutes.groomingSettings,
                    extra: pet,
                  );
                },
              ),

              const SizedBox(height: 12),

              // Tick & Flea Card (only for dogs and cats)
              if (pet.supportsMedicalCare) ...[
                _buildCareCard(
                  context: context,
                  icon: Icons.shield_outlined,
                  title: AppStrings.tickFleaPrevention,
                  subtitle: _getTickFleaStatus(pet),
                  onTap: () {
                    context.pushNamed(
                      AppRoutes.tickFleaSettings,
                      extra: pet,
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],

              if (!pet.supportsMedicalCare) const SizedBox(height: 12),

              // Edit Pet Details Button
              _buildEditButton(context, pet),

              const SizedBox(height: 12),

              // Delete Pet Button
              _buildDeleteButton(context, pet),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, PetModel pet) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.deletePetConfirmTitle),
        content: const Text(AppStrings.deletePetConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _deletePet(context, pet);
            },
            child: Text(
              AppStrings.delete,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePet(BuildContext context, PetModel pet) async {
    try {
      await sl<PetRepository>().deletePet(pet.id);
      if (context.mounted) {
        context.read<PetListBloc>().add(const LoadPetList());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.petDeletedSuccessfully),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildPetInfoCard(PetModel pet) {
    final bool hasCareDue = _hasCareDue(pet);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Circular pet photo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getSpeciesColor(pet.species),
            ),
            child: ClipOval(
              child: pet.imagePath != null && pet.imagePath!.startsWith('http')
                  ? Image.network(
                      pet.imagePath!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultPetIcon();
                      },
                    )
                  : _buildDefaultPetIcon(),
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
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatAge(pet.dateOfBirth),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (hasCareDue) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE68A).withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppStrings.someCareDue,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinesSection(BuildContext context, PetModel pet) {
    final upcomingCount = _getUpcomingVaccinesCount(pet);
    final headerText =
        upcomingCount > 0 ? '${AppStrings.vaccines} ($upcomingCount ${AppStrings.comingUp})' : AppStrings.vaccines;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Vaccine list
          if (pet.vaccines.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                AppStrings.noVaccinesAdded,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
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
                  _buildVaccineRow(context, vaccine),
                  if (!isLast) const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.border),
                ],
              );
            }),

          // Add vaccine row
          const Divider(height: 1, color: AppColors.border),
          _buildAddVaccineRow(context),
        ],
      ),
    );
  }

  Widget _buildAddVaccineRow(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamed(
          AppRoutes.addVaccine,
          extra: {'pet': pet},
        );
      },
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
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
            const SizedBox(width: 12),
            Text(
              AppStrings.addVaccine,
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

  Widget _buildVaccineRow(BuildContext context, VaccineModel vaccine) {
    return InkWell(
      onTap: () {
        context.pushNamed(
          AppRoutes.addVaccine,
          extra: {
            'pet': pet,
            'vaccine': vaccine,
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                vaccine.vaccineName,
                style: AppTextStyles.mediumStyle500(fontSize: 16, fontColor: AppColors.textPrimary),
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

  Widget _buildCareCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
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

  Widget _buildEditButton(BuildContext context, PetModel pet) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(AppRoutes.addPet, extra: pet);
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text(
            AppStrings.editPetDetails,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context, PetModel pet) {
    return GestureDetector(
      onTap: () => _showDeleteConfirmation(context, pet),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.error),
        ),
        child: const Center(
          child: Text(
            AppStrings.deletePet,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultPetIcon() {
    return Container(
      width: 80,
      height: 80,
      alignment: Alignment.center,
      child: Icon(
        Icons.pets,
        size: 40,
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
        return const Color(0xFFFFF3E0);
      case 'cat':
        return const Color(0xFFFCE4EC);
      case 'bird':
        return const Color(0xFFE3F2FD);
      case 'fish':
        return const Color(0xFFE0F7FA);
      default:
        return const Color(0xFFF3E5F5);
    }
  }

  bool _hasCareDue(PetModel pet) {
    // Check vaccines
    if (pet.supportsMedicalCare) {
      for (final vaccine in pet.vaccines) {
        if (vaccine.nextDueDate.isBefore(DateTime.now().add(const Duration(days: 30)))) {
          return true;
        }
      }
    }

    // Check grooming
    if (pet.groomingSettings != null && (pet.groomingSettings!.isDueSoon || pet.groomingSettings!.isOverdue)) {
      return true;
    }

    // Check tick & flea
    if (pet.supportsMedicalCare && pet.tickFleaSettings != null) {
      if (pet.tickFleaSettings!.isDueSoon || pet.tickFleaSettings!.isOverdue) {
        return true;
      }
    }

    return false;
  }

  int _getUpcomingVaccinesCount(PetModel pet) {
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));

    return pet.vaccines.where((vaccine) {
      return vaccine.nextDueDate.isAfter(now) && vaccine.nextDueDate.isBefore(thirtyDaysFromNow);
    }).length;
  }

  String _getGroomingStatus(PetModel pet) {
    if (pet.groomingSettings == null || !pet.groomingSettings!.hasReminder) {
      return AppStrings.notSet;
    }

    if (pet.groomingSettings!.isOverdue) {
      return AppStrings.upcomingSoon;
    }

    if (pet.groomingSettings!.isDueSoon) {
      return AppStrings.upcomingSoon;
    }

    return AppStrings.allGood;
  }

  String _getTickFleaStatus(PetModel pet) {
    if (pet.tickFleaSettings == null || !pet.tickFleaSettings!.hasReminder) {
      return AppStrings.notSet;
    }

    if (pet.tickFleaSettings!.isOverdue) {
      return AppStrings.nextDoseSoon;
    }

    if (pet.tickFleaSettings!.isDueSoon) {
      return AppStrings.nextDoseSoon;
    }

    return AppStrings.allGood;
  }
}
