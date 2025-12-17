import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/home/home_bloc.dart';
import 'package:paw_around/bloc/home/home_event.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_state.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/ui/home/widgets/home_app_bar.dart';
import 'package:paw_around/ui/home/widgets/primary_action_card.dart';
import 'package:paw_around/ui/home/widgets/secondary_action_card.dart';
import 'package:paw_around/ui/home/widgets/lost_pets_section.dart';
import 'package:paw_around/ui/home/widgets/empty_state_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<PetListBloc, PetListState>(
          builder: (context, state) {
            List<PetModel> pets = [];
            if (state is PetListLoaded) {
              pets = state.pets;
            }

            // Get active pet info
            final activePet = pets.isNotEmpty ? pets.first : null;
            final petAge = activePet != null ? _calculateAge(activePet.dateOfBirth) : null;

            // Check if there are any urgent actions (vaccines due soon)
            final hasUrgentVaccine = _hasUpcomingVaccine(pets);

            return Column(
              children: [
                // Custom App Bar
                HomeAppBar(
                  petName: activePet?.name,
                  petAge: petAge,
                  onNotificationTap: () {
                    // TODO: Navigate to notifications
                  },
                ),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Primary Action Card - Vaccine reminder
                        if (hasUrgentVaccine)
                          PrimaryActionCard(
                            icon: Icons.vaccines_outlined,
                            title: 'Rabies ${AppStrings.vaccineDueIn} 7 ${AppStrings.daysUntilDue}',
                            subtitle: AppStrings.importantForHealth,
                            buttonText: AppStrings.findNearbyVets,
                            helperText: '3 ${AppStrings.vetsWithinDistance}',
                            onButtonPressed: () {
                              // Navigate to Map tab
                              context.read<HomeBloc>().add(HomeTabChanged(1));
                            },
                          ),

                        if (hasUrgentVaccine) const SizedBox(height: 16),

                        // Secondary Action Cards
                        SecondaryActionCard(
                          icon: Icons.pets,
                          iconBackgroundColor: AppColors.iconBgLight,
                          iconColor: AppColors.primary,
                          title: AppStrings.groomingDueThisWeek,
                          subtitle: AppStrings.timeForFreshTrim,
                          onTap: () {
                            // Navigate to Map tab for groomers
                            context.read<HomeBloc>().add(HomeTabChanged(1));
                          },
                        ),

                        const SizedBox(height: 8),

                        SecondaryActionCard(
                          icon: Icons.shield_outlined,
                          iconBackgroundColor: AppColors.iconBgBeige,
                          iconColor: const Color(0xFF8B7355),
                          title: AppStrings.tickFleaPrevention,
                          subtitle: AppStrings.reminderToProtect,
                          onTap: () {
                            // Navigate to Map tab for vets
                            context.read<HomeBloc>().add(HomeTabChanged(1));
                          },
                        ),

                        const SizedBox(height: 24),

                        // Lost & Found Section
                        LostPetsSection(
                          pets: const [
                            LostPetItem(name: 'Bruno', distance: '2 km away'),
                            LostPetItem(name: 'Coco', distance: '1.5 km away'),
                          ],
                          onSeeAllTap: () {
                            // Navigate to Community tab
                            context.read<HomeBloc>().add(HomeTabChanged(2));
                          },
                          onPetTap: (pet) {
                            // Navigate to Community tab
                            context.read<HomeBloc>().add(HomeTabChanged(2));
                          },
                        ),

                        const SizedBox(height: 16),

                        // Empty state (shown when no urgent actions)
                        if (!hasUrgentVaccine) const EmptyStateCard(),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _calculateAge(DateTime? dateOfBirth) {
    if (dateOfBirth == null) {
      return '';
    }

    final now = DateTime.now();
    final difference = now.difference(dateOfBirth);
    final months = (difference.inDays / 30).floor();

    if (months < 12) {
      return '$months ${AppStrings.months}';
    } else {
      final years = (months / 12).floor();
      final remainingMonths = months % 12;
      if (remainingMonths == 0) {
        return '$years year${years > 1 ? 's' : ''}';
      }
      return '$years year${years > 1 ? 's' : ''} $remainingMonths mo';
    }
  }

  bool _hasUpcomingVaccine(List<PetModel> pets) {
    // Check if any pet has a vaccine due within 30 days
    for (final pet in pets) {
      if (pet.vaccines != null) {
        for (final vaccine in pet.vaccines!) {
          if (vaccine.nextDueDate != null) {
            final daysUntilDue = vaccine.nextDueDate!.difference(DateTime.now()).inDays;
            if (daysUntilDue >= 0 && daysUntilDue <= 30) {
              return true;
            }
          }
        }
      }
    }
    // Default to true to show the demo UI
    return true;
  }
}
