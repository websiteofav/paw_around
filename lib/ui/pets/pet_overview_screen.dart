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
import 'package:paw_around/ui/widgets/animated_card.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

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
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pet Info Card
              AnimatedCard(
                index: 0,
                child: _buildPetInfoCard(pet),
              ),

              const SizedBox(height: 16),

              // Vaccines Section (only for dogs and cats)
              if (pet.supportsMedicalCare) ...[
                AnimatedCard(
                  index: 1,
                  child: _buildVaccinesSection(context, pet),
                ),
                const SizedBox(height: 16),
              ],

              // Grooming Card
              AnimatedCard(
                index: 2,
                child: _buildCareCard(
                  context: context,
                  icon: Icons.content_cut,
                  title: AppStrings.grooming,
                  subtitle: _getGroomingStatus(pet),
                  status: _getGroomingStatusType(pet),
                  onTap: () {
                    context.pushNamed(
                      AppRoutes.groomingSettings,
                      extra: pet,
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Tick & Flea Card (only for dogs and cats)
              if (pet.supportsMedicalCare) ...[
                AnimatedCard(
                  index: 3,
                  child: _buildCareCard(
                    context: context,
                    icon: Icons.shield_outlined,
                    title: AppStrings.tickFleaPrevention,
                    subtitle: _getTickFleaStatus(pet),
                    status: _getTickFleaStatusType(pet),
                    onTap: () {
                      context.pushNamed(
                        AppRoutes.tickFleaSettings,
                        extra: pet,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              if (!pet.supportsMedicalCare) const SizedBox(height: 16),

              // Edit Pet Details Button
              AnimatedCard(
                index: 4,
                child: _buildEditButton(context, pet),
              ),

              const SizedBox(height: 12),

              // Delete Pet Button
              AnimatedCard(
                index: 5,
                child: _buildDeleteButton(context, pet),
              ),

              const SizedBox(height: 20),
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
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                size: 32,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.deletePetConfirmTitle,
              style: AppTextStyles.semiBoldStyle600(
                fontSize: 18,
                fontColor: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.deletePetConfirmMessage,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Buttons row
            Row(
              children: [
                Expanded(
                  child: CommonButton(
                    text: AppStrings.cancel,
                    variant: ButtonVariant.secondary,
                    size: ButtonSize.small,
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CommonButton(
                    text: AppStrings.delete,
                    variant: ButtonVariant.danger,
                    size: ButtonSize.small,
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();
                      await _deletePet(context, pet);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
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
      child: Row(
        children: [
          // Circular pet photo with gradient
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.8),
                  AppColors.primaryLight,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getSpeciesColor(pet.species),
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: ClipOval(
                  child: pet.imagePath != null && pet.imagePath!.startsWith('http')
                      ? Image.network(
                          pet.imagePath!,
                          width: 82,
                          height: 82,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultPetIcon();
                          },
                        )
                      : _buildDefaultPetIcon(),
                ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppStrings.someCareDue,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
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
              style: AppTextStyles.mediumStyle500(fontSize: 15, fontColor: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccineRow(BuildContext context, VaccineModel vaccine) {
    final daysUntilDue = vaccine.nextDueDate.difference(DateTime.now()).inDays;
    final isOverdue = daysUntilDue < 0;
    final isDueSoon = daysUntilDue >= 0 && daysUntilDue <= 30;

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
            // Status indicator dot
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOverdue
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
                  Text(
                    vaccine.vaccineName,
                    style: AppTextStyles.mediumStyle500(fontSize: 15, fontColor: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isOverdue
                        ? 'Overdue by ${-daysUntilDue} days'
                        : daysUntilDue == 0
                            ? 'Due today'
                            : 'Due in $daysUntilDue days',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue ? AppColors.error : AppColors.textSecondary,
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

  Widget _buildCareCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? status,
  }) {
    return ScaleButton(
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (status != null) ...[
                        const SizedBox(width: 8),
                        _buildStatusBadge(status),
                      ],
                    ],
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
    return CommonButton(
      text: AppStrings.editPetDetails,
      variant: ButtonVariant.primary,
      icon: Icons.edit_outlined,
      onPressed: () {
        context.pushNamed(AppRoutes.addPet, extra: pet);
      },
    );
  }

  Widget _buildDeleteButton(BuildContext context, PetModel pet) {
    return CommonButton(
      text: AppStrings.deletePet,
      variant: ButtonVariant.danger,
      icon: Icons.delete_outline,
      onPressed: () => _showDeleteConfirmation(context, pet),
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

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case 'overdue':
        bgColor = AppColors.error.withValues(alpha: 0.15);
        textColor = AppColors.error;
        label = 'Overdue';
        icon = Icons.warning_amber_rounded;
        break;
      case 'soon':
        bgColor = AppColors.warning.withValues(alpha: 0.15);
        textColor = AppColors.warning;
        label = 'Due Soon';
        icon = Icons.schedule;
        break;
      case 'good':
      default:
        bgColor = AppColors.success.withValues(alpha: 0.15);
        textColor = AppColors.success;
        label = 'All Good';
        icon = Icons.check_circle_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
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

  String? _getGroomingStatusType(PetModel pet) {
    if (pet.groomingSettings == null || !pet.groomingSettings!.hasReminder) {
      return null;
    }

    if (pet.groomingSettings!.isOverdue) {
      return 'overdue';
    }

    if (pet.groomingSettings!.isDueSoon) {
      return 'soon';
    }

    return 'good';
  }

  String? _getTickFleaStatusType(PetModel pet) {
    if (pet.tickFleaSettings == null || !pet.tickFleaSettings!.hasReminder) {
      return null;
    }

    if (pet.tickFleaSettings!.isOverdue) {
      return 'overdue';
    }

    if (pet.tickFleaSettings!.isDueSoon) {
      return 'soon';
    }

    return 'good';
  }
}
