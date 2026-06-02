import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/ui/pets/widgets/pet_overview_actions.dart';
import 'package:paw_around/ui/pets/widgets/pet_overview_care_card.dart';
import 'package:paw_around/ui/pets/widgets/pet_overview_info_card.dart';
import 'package:paw_around/ui/pets/widgets/pet_overview_lost_toggle.dart';
import 'package:paw_around/ui/pets/widgets/pet_overview_qr_card.dart';
import 'package:paw_around/ui/pets/widgets/pet_overview_vaccines_section.dart';
import 'package:paw_around/ui/widgets/animated_card.dart';

class PetOverviewScreen extends StatelessWidget {
  final PetModel pet;

  const PetOverviewScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PetListBloc, PetListState>(
      builder: (context, state) {
        final currentPet = state is PetListLoaded
            ? state.pets.firstWhere((p) => p.id == pet.id, orElse: () => pet)
            : pet;
        return _buildContent(context, currentPet);
      },
    );
  }

  Widget _buildContent(BuildContext context, PetModel pet) {
    final hasImage = pet.imagePath != null && pet.imagePath!.startsWith('http');
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── Hero photo ──────────────────────────────────────────
            Stack(
              children: [
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: hasImage
                      ? Image.network(
                          pet.imagePath!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const _PhotoPlaceholder(),
                        )
                      : const _PhotoPlaceholder(),
                ),
                // Gradient so back button is always visible
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: const Alignment(0, -0.3),
                        colors: [
                          AppColors.shadowOverlay.withValues(alpha: 0.45),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Back button
                Positioned(
                  top: topPad + 8,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.white,
                      size: 22,
                    ),
                  ),
                ),
                // Pet name over photo
                Positioned(
                  bottom: 16,
                  left: 20,
                  child: Text(
                    pet.name,
                    style: AppTextStyles.boldStyle700(
                        fontSize: 28, fontColor: AppColors.white),
                  ),
                ),
              ],
            ),
            // ─── Body cards ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  AnimatedCard(index: 0, child: PetOverviewInfoCard(pet: pet)),
                  const SizedBox(height: 16),
                  AnimatedCard(index: 1, child: PetOverviewQrCard(pet: pet)),
                  const SizedBox(height: 16),
                  AnimatedCard(index: 2, child: PetOverviewLostToggle(pet: pet)),
                  const SizedBox(height: 16),
                  if (pet.supportsMedicalCare) ...[
                    AnimatedCard(
                        index: 3,
                        child: PetOverviewVaccinesSection(pet: pet)),
                    const SizedBox(height: 16),
                  ],
                  AnimatedCard(
                    index: 4,
                    child: PetOverviewCareCard(
                      icon: Icons.content_cut,
                      title: AppStrings.grooming,
                      subtitle: _groomingStatus(pet),
                      status: pet.groomingStatusType,
                      onTap: () => context.pushNamed(
                          AppRoutes.groomingSettings,
                          extra: pet),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (pet.supportsMedicalCare) ...[
                    AnimatedCard(
                      index: 5,
                      child: PetOverviewCareCard(
                        icon: Icons.shield_outlined,
                        title: AppStrings.tickFleaPrevention,
                        subtitle: _tickFleaStatus(pet),
                        status: pet.tickFleaStatusType,
                        onTap: () => context.pushNamed(
                            AppRoutes.tickFleaSettings,
                            extra: pet),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (!pet.supportsMedicalCare) const SizedBox(height: 0),
                  AnimatedCard(
                      index: 6, child: PetOverviewEditButton(pet: pet)),
                  const SizedBox(height: 16),
                  AnimatedCard(
                      index: 7, child: PetOverviewDeleteButton(pet: pet)),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _groomingStatus(PetModel pet) {
    final s = pet.groomingStatusType;
    if (s == null) return AppStrings.notSet;
    return (s == 'overdue' || s == 'soon')
        ? AppStrings.upcomingSoon
        : AppStrings.allGood;
  }

  static String _tickFleaStatus(PetModel pet) {
    final s = pet.tickFleaStatusType;
    if (s == null) return AppStrings.notSet;
    return (s == 'overdue' || s == 'soon')
        ? AppStrings.nextDoseSoon
        : AppStrings.allGood;
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.iconBgLight,
      child: Center(
        child: Icon(
          Icons.pets,
          size: 64,
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
