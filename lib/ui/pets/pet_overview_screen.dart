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

  const PetOverviewScreen({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PetListBloc, PetListState>(
      builder: (context, state) {
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
          style: AppTextStyles.semiBoldStyle600(
            fontSize: 20,
            fontColor: AppColors.textPrimary,
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
              AnimatedCard(index: 0, child: PetOverviewInfoCard(pet: pet)),
              const SizedBox(height: 16),
              AnimatedCard(index: 1, child: PetOverviewQrCard(pet: pet)),
              const SizedBox(height: 16),
              AnimatedCard(index: 2, child: PetOverviewLostToggle(pet: pet)),
              const SizedBox(height: 16),
              if (pet.supportsMedicalCare) ...[
                AnimatedCard(
                  index: 3,
                  child: PetOverviewVaccinesSection(pet: pet),
                ),
                const SizedBox(height: 16),
              ],
              AnimatedCard(
                index: 4,
                child: PetOverviewCareCard(
                  icon: Icons.content_cut,
                  title: AppStrings.grooming,
                  subtitle: _getGroomingStatusText(pet),
                  status: pet.groomingStatusType,
                  onTap: () {
                    context.pushNamed(
                      AppRoutes.groomingSettings,
                      extra: pet,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (pet.supportsMedicalCare) ...[
                AnimatedCard(
                  index: 5,
                  child: PetOverviewCareCard(
                    icon: Icons.shield_outlined,
                    title: AppStrings.tickFleaPrevention,
                    subtitle: _getTickFleaStatusText(pet),
                    status: pet.tickFleaStatusType,
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
              AnimatedCard(
                index: 6,
                child: PetOverviewEditButton(pet: pet),
              ),
              const SizedBox(height: 12),
              AnimatedCard(
                index: 7,
                child: PetOverviewDeleteButton(pet: pet),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  static String _getGroomingStatusText(PetModel pet) {
    final statusType = pet.groomingStatusType;
    if (statusType == null) return AppStrings.notSet;
    if (statusType == 'overdue' || statusType == 'soon') {
      return AppStrings.upcomingSoon;
    }
    return AppStrings.allGood;
  }

  static String _getTickFleaStatusText(PetModel pet) {
    final statusType = pet.tickFleaStatusType;
    if (statusType == null) return AppStrings.notSet;
    if (statusType == 'overdue' || statusType == 'soon') {
      return AppStrings.nextDoseSoon;
    }
    return AppStrings.allGood;
  }
}
