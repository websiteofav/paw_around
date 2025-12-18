import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/home/home_bloc.dart';
import 'package:paw_around/bloc/home/home_event.dart';
import 'package:paw_around/bloc/community/community_bloc.dart';
import 'package:paw_around/bloc/community/community_event.dart';
import 'package:paw_around/bloc/community/community_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_state.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/community/lost_found_post.dart';
import 'package:paw_around/ui/home/widgets/home_app_bar.dart';
import 'package:paw_around/ui/home/widgets/primary_action_card.dart';
import 'package:paw_around/ui/home/widgets/secondary_action_card.dart';
import 'package:paw_around/ui/home/widgets/lost_pets_section.dart';
import 'package:paw_around/ui/home/widgets/empty_state_card.dart';
import 'package:paw_around/ui/home/widgets/welcome_card.dart';
import 'package:paw_around/ui/home/widgets/setup_reminder_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load community posts for lost pets section
    context.read<CommunityBloc>().add(LoadPosts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<PetListBloc, PetListState>(
          builder: (context, petState) {
            List<PetModel> pets = [];
            if (petState is PetListLoaded) {
              pets = petState.pets;
            }

            // Get active pet info
            final activePet = pets.isNotEmpty ? pets.first : null;
            final petAge = activePet != null ? _calculateAge(activePet.dateOfBirth) : null;

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

                // Content based on state
                Expanded(
                  child: _buildContent(pets, activePet),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(List<PetModel> pets, PetModel? activePet) {
    // State 1: No pets exist
    if (pets.isEmpty) {
      return _buildWelcomeState();
    }

    // State 2: Pet exists but no vaccines
    final hasVaccines = activePet!.vaccines.isNotEmpty;
    if (!hasVaccines) {
      return _buildSetupReminderState(activePet);
    }

    // State 3 & 4: Pet and vaccines exist
    final hasUpcomingVaccine = _hasUpcomingVaccine(pets);
    return _buildNormalState(pets, activePet, hasUpcomingVaccine);
  }

  // State 1: Welcome state for new users
  Widget _buildWelcomeState() {
    return const Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(32),
        child: WelcomeCard(),
      ),
    );
  }

  // State 2: Setup reminder for users with pets but no vaccines
  Widget _buildSetupReminderState(PetModel pet) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SetupReminderCard(
            petName: pet.name,
            onAddVaccinePressed: () {
              context.push(AppRoutes.addVaccine);
            },
          ),
          const SizedBox(height: 24),
          // Still show lost pets section
          _buildLostPetsSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // State 3 & 4: Normal state with action cards or all-set state
  Widget _buildNormalState(List<PetModel> pets, PetModel activePet, bool hasUpcomingVaccine) {
    // Check care settings
    final hasGroomingSettings = activePet.groomingSettings?.hasReminder == true;
    final hasTickFleaSettings = activePet.tickFleaSettings?.hasReminder == true;
    final groomingDueSoon =
        activePet.groomingSettings?.isDueSoon == true || activePet.groomingSettings?.isOverdue == true;
    final tickFleaDueSoon =
        activePet.tickFleaSettings?.isDueSoon == true || activePet.tickFleaSettings?.isOverdue == true;

    // Determine if we have any urgent actions
    final hasUrgentActions = hasUpcomingVaccine || groomingDueSoon || tickFleaDueSoon;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary Action Card - Vaccine reminder (only if upcoming)
          if (hasUpcomingVaccine) ...[
            _buildPrimaryVaccineCard(pets),
            const SizedBox(height: 16),
          ],

          // Grooming Card
          if (hasGroomingSettings) ...[
            SecondaryActionCard(
              icon: Icons.pets,
              iconBackgroundColor: groomingDueSoon ? AppColors.iconBgLight : AppColors.border,
              iconColor: groomingDueSoon ? AppColors.primary : AppColors.textSecondary,
              title: groomingDueSoon ? AppStrings.groomingDueThisWeek : AppStrings.grooming,
              subtitle: groomingDueSoon ? AppStrings.timeForFreshTrim : _getGroomingSubtitle(activePet),
              onTap: () {
                context.push(AppRoutes.groomingSettings, extra: activePet);
              },
            ),
            const SizedBox(height: 8),
          ] else ...[
            // No grooming settings - show add card
            SecondaryActionCard(
              icon: Icons.pets,
              iconBackgroundColor: AppColors.iconBgLight,
              iconColor: AppColors.primary,
              title: AppStrings.addGroomingDetails,
              subtitle: AppStrings.timeForFreshTrim,
              onTap: () {
                context.push(AppRoutes.groomingSettings, extra: activePet);
              },
            ),
            const SizedBox(height: 8),
          ],

          // Tick & Flea Card
          if (hasTickFleaSettings) ...[
            SecondaryActionCard(
              icon: Icons.shield_outlined,
              iconBackgroundColor: tickFleaDueSoon ? AppColors.iconBgBeige : AppColors.border,
              iconColor: tickFleaDueSoon ? const Color(0xFF8B7355) : AppColors.textSecondary,
              title: tickFleaDueSoon ? AppStrings.tickFleaPrevention : AppStrings.tickFleaPrevention,
              subtitle: tickFleaDueSoon ? AppStrings.reminderToProtect : _getTickFleaSubtitle(activePet),
              onTap: () {
                context.push(AppRoutes.tickFleaSettings, extra: activePet);
              },
            ),
          ] else ...[
            // No tick/flea settings - show add card
            SecondaryActionCard(
              icon: Icons.shield_outlined,
              iconBackgroundColor: AppColors.iconBgBeige,
              iconColor: const Color(0xFF8B7355),
              title: AppStrings.addTickFleaDetails,
              subtitle: AppStrings.reminderToProtect,
              onTap: () {
                context.push(AppRoutes.tickFleaSettings, extra: activePet);
              },
            ),
          ],

          const SizedBox(height: 24),

          // Lost & Found Section (from Firebase)
          _buildLostPetsSection(),

          const SizedBox(height: 16),

          // Empty state (shown when no urgent actions)
          if (!hasUrgentActions) const EmptyStateCard(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getGroomingSubtitle(PetModel pet) {
    final settings = pet.groomingSettings;
    if (settings == null || settings.nextDueDate == null) {
      return '';
    }
    final daysUntil = settings.daysUntilDue ?? 0;
    if (daysUntil < 0) {
      return 'Overdue by ${-daysUntil} days';
    }
    return 'Next in $daysUntil days';
  }

  String _getTickFleaSubtitle(PetModel pet) {
    final settings = pet.tickFleaSettings;
    if (settings == null || settings.nextDueDate == null) {
      return '';
    }
    final daysUntil = settings.daysUntilDue ?? 0;
    if (daysUntil < 0) {
      return 'Overdue by ${-daysUntil} days';
    }
    return 'Next in $daysUntil days';
  }

  Widget _buildPrimaryVaccineCard(List<PetModel> pets) {
    // Find the next upcoming vaccine
    String vaccineName = 'Vaccine';
    int daysUntil = 7;

    for (final pet in pets) {
      for (final vaccine in pet.vaccines) {
        final days = vaccine.nextDueDate.difference(DateTime.now()).inDays;
        if (days >= 0 && days <= 30) {
          vaccineName = vaccine.vaccineName;
          daysUntil = days;
          break;
        }
      }
    }

    return PrimaryActionCard(
      icon: Icons.vaccines_outlined,
      title: '$vaccineName ${AppStrings.vaccineDueIn} $daysUntil ${AppStrings.daysUntilDue}',
      subtitle: AppStrings.importantForHealth,
      buttonText: AppStrings.findNearbyVets,
      helperText: '3 ${AppStrings.vetsWithinDistance}',
      onButtonPressed: () {
        context.read<HomeBloc>().add(HomeTabChanged(1));
      },
    );
  }

  Widget _buildLostPetsSection() {
    return BlocBuilder<CommunityBloc, CommunityState>(
      builder: (context, communityState) {
        List<LostPetItem> lostPets = [];

        if (communityState is CommunityLoaded) {
          lostPets = communityState.posts
              .where((p) => p.type == PostType.lost && !p.isResolved)
              .take(2)
              .map((p) => LostPetItem(
                    name: p.petName,
                    distance: '${_formatDistance(p)} ${AppStrings.kmAway}',
                    imageUrl: p.imagePath,
                  ))
              .toList();
        }

        if (lostPets.isEmpty) {
          return const SizedBox.shrink();
        }

        return LostPetsSection(
          pets: lostPets,
          onSeeAllTap: () {
            context.read<HomeBloc>().add(HomeTabChanged(2));
          },
          onPetTap: (pet) {
            context.read<HomeBloc>().add(HomeTabChanged(2));
          },
        );
      },
    );
  }

  String _formatDistance(LostFoundPost post) {
    // TODO: Calculate actual distance from user location
    // For now, return a placeholder
    return '2';
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
    for (final pet in pets) {
      for (final vaccine in pet.vaccines) {
        final daysUntilDue = vaccine.nextDueDate.difference(DateTime.now()).inDays;
        if (daysUntilDue >= 0 && daysUntilDue <= 30) {
          return true;
        }
      }
    }
    return false;
  }
}
