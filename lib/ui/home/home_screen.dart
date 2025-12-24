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
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/pets/action_type.dart';
import 'package:paw_around/models/pets/care_settings_model.dart';
import 'package:paw_around/models/community/lost_found_post.dart';
import 'package:paw_around/ui/home/action_card_detail_screen.dart';
import 'package:paw_around/ui/home/widgets/home_app_bar.dart';
import 'package:paw_around/ui/home/widgets/urgent_vaccine_card.dart';
import 'package:paw_around/ui/home/widgets/grooming_due_card.dart';
import 'package:paw_around/ui/home/widgets/care_progress_card.dart';
import 'package:paw_around/ui/home/widgets/care_summary_section.dart';
import 'package:paw_around/ui/home/widgets/secondary_action_card.dart';
import 'package:paw_around/ui/home/widgets/lost_pets_section.dart';
import 'package:paw_around/ui/home/widgets/welcome_card.dart';
import 'package:paw_around/ui/home/widgets/setup_reminder_card.dart';
import 'package:paw_around/ui/home/widgets/skeleton_card.dart';
import 'package:paw_around/ui/widgets/animated_card.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

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

  Future<void> _onRefresh() async {
    context.read<PetListBloc>().add(const LoadPetList());
    context.read<CommunityBloc>().add(LoadPosts());
    // Wait for the bloc to complete loading
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: BlocBuilder<PetListBloc, PetListState>(
          builder: (context, petState) {
            // Show skeleton while loading
            if (petState is PetListLoading) {
              return const Column(
                children: [
                  AppBarSkeleton(),
                  Expanded(child: HomeSkeletonLoader()),
                ],
              );
            }

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
                  petImageUrl: activePet?.imagePath,
                  onNotificationTap: () {
                    // TODO: Navigate to notifications
                  },
                ),

                // Content based on state with pull-to-refresh
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: AppColors.primary,
                    backgroundColor: AppColors.white,
                    child: _buildContent(pets, activePet),
                  ),
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

    // For "Other" pet types, skip vaccine and tick & flea setup
    final supportsMedicalCare = activePet!.supportsMedicalCare;

    // Check what's missing for setup
    final missingItems = _getMissingSetupItems(activePet, supportsMedicalCare);
    final totalItems = _getTotalSetupItems(supportsMedicalCare);

    // State 2: Pet exists but has missing setup items
    if (missingItems.isNotEmpty) {
      return _buildSetupReminderState(activePet, missingItems, totalItems);
    }

    // State 3 & 4: All setup complete
    final hasUpcomingVaccine = supportsMedicalCare && _hasUpcomingVaccine(pets);
    return _buildNormalState(pets, activePet, hasUpcomingVaccine);
  }

  List<SetupItem> _getMissingSetupItems(PetModel pet, bool supportsMedicalCare) {
    final List<SetupItem> missingItems = [];

    // Check vaccines (only for dog/cat)
    if (supportsMedicalCare && pet.vaccines.isEmpty) {
      missingItems.add(
        SetupItem(
          type: SetupItemType.vaccines,
          label: AppStrings.addVaccineDetails,
          subtitle: AppStrings.vaccineSubtitle,
          icon: Icons.vaccines_outlined,
          onTap: () => context.pushNamed(AppRoutes.addVaccine, extra: pet),
        ),
      );
    }

    // Check grooming (for all pet types)
    if (pet.groomingSettings?.hasReminder != true) {
      missingItems.add(
        SetupItem(
          type: SetupItemType.grooming,
          label: AppStrings.addGroomingDetails,
          subtitle: AppStrings.groomingSubtitle,
          icon: Icons.content_cut,
          onTap: () => context.pushNamed(AppRoutes.groomingSettings, extra: pet),
        ),
      );
    }

    // Check tick & flea (only for dog/cat)
    if (supportsMedicalCare && pet.tickFleaSettings?.hasReminder != true) {
      missingItems.add(
        SetupItem(
          type: SetupItemType.tickFlea,
          label: AppStrings.addTickFleaDetails,
          subtitle: AppStrings.tickFleaSubtitle,
          icon: Icons.shield_outlined,
          onTap: () => context.pushNamed(AppRoutes.tickFleaSettings, extra: pet),
        ),
      );
    }

    return missingItems;
  }

  int _getTotalSetupItems(bool supportsMedicalCare) {
    // Dog/Cat: 3 items (vaccines, grooming, tick & flea)
    // Other: 1 item (grooming only)
    return supportsMedicalCare ? 3 : 1;
  }

  // State 1: Welcome state for new users
  Widget _buildWelcomeState() {
    return const AnimatedCard(
      index: 0,
      child: WelcomeCard(),
    );
  }

  // State 2: Setup reminder for users with pets but missing setup items
  Widget _buildSetupReminderState(PetModel pet, List<SetupItem> missingItems, int totalItems) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedCard(
            index: 0,
            child: SetupReminderCard(
              petName: pet.name,
              missingItems: missingItems,
              totalItems: totalItems,
            ),
          ),
          const SizedBox(height: 24),
          // Still show lost pets section
          AnimatedCard(
            index: 1,
            child: _buildLostPetsSection(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // State 3 & 4: Normal state with action cards or all-set state
  Widget _buildNormalState(List<PetModel> pets, PetModel activePet, bool hasUpcomingVaccine) {
    // Check if pet supports medical care (vaccines, tick & flea)
    final supportsMedicalCare = activePet.supportsMedicalCare;

    // Check care settings (filter out snoozed)
    final hasGroomingSettings = activePet.groomingSettings?.hasReminder == true;
    final hasTickFleaSettings = supportsMedicalCare && activePet.tickFleaSettings?.hasReminder == true;
    final groomingSnoozed = activePet.groomingSettings?.isSnoozed == true;
    final tickFleaSnoozed = activePet.tickFleaSettings?.isSnoozed == true;
    final groomingDueSoon = !groomingSnoozed &&
        (activePet.groomingSettings?.isDueSoon == true || activePet.groomingSettings?.isOverdue == true);
    final tickFleaDueSoon = supportsMedicalCare &&
        !tickFleaSnoozed &&
        (activePet.tickFleaSettings?.isDueSoon == true || activePet.tickFleaSettings?.isOverdue == true);

    // Calculate stats for summary
    int activeTasks = 0;
    int urgentCount = 0;
    int scheduledCount = 0;

    if (hasUpcomingVaccine) {
      activeTasks++;
      urgentCount++;
    }
    if (hasGroomingSettings && !groomingSnoozed) {
      activeTasks++;
      if (groomingDueSoon) {
        urgentCount++;
      } else {
        scheduledCount++;
      }
    }
    if (hasTickFleaSettings && !tickFleaSnoozed) {
      activeTasks++;
      if (tickFleaDueSoon) {
        urgentCount++;
      } else {
        scheduledCount++;
      }
    }

    // Track card index for staggered animation
    int cardIndex = 0;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Urgent Vaccine Card (red gradient)
          if (hasUpcomingVaccine) ...[
            AnimatedCard(
              index: cardIndex++,
              child: ScaleButton(
                onPressed: () {
                  final vaccineData = _getUpcomingVaccine(pets);
                  if (vaccineData != null) {
                    context.pushNamed(
                      AppRoutes.actionDetail,
                      extra: ActionCardData(
                        actionType: ActionType.vaccine,
                        pet: vaccineData.$1,
                        vaccine: vaccineData.$2,
                        customTitle: vaccineData.$2.vaccineName,
                      ),
                    );
                  }
                },
                child: _buildUrgentVaccineCard(pets, activePet),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Grooming Card
          if (hasGroomingSettings && !groomingSnoozed) ...[
            AnimatedCard(
              index: cardIndex++,
              child: ScaleButton(
                onPressed: () {
                  if (groomingDueSoon) {
                    context.pushNamed(
                      AppRoutes.actionDetail,
                      extra: ActionCardData(
                        actionType: ActionType.grooming,
                        pet: activePet,
                      ),
                    );
                  } else {
                    context.pushNamed(AppRoutes.groomingSettings, extra: activePet);
                  }
                },
                child: groomingDueSoon
                    ? GroomingDueCard(
                        badgeText: _getGroomingBadgeText(activePet),
                      )
                    : CareProgressCard(
                        icon: Icons.content_cut,
                        title: AppStrings.grooming,
                        subtitle: _getGroomingSubtitle(activePet),
                        daysLeft: activePet.groomingSettings?.daysUntilDue ?? 30,
                        totalDays: _getGroomingTotalDays(activePet),
                      ),
              ),
            ),
            const SizedBox(height: 12),
          ] else if (!hasGroomingSettings) ...[
            // No grooming settings - show add card
            AnimatedCard(
              index: cardIndex++,
              child: ScaleButton(
                onPressed: () {
                  context.pushNamed(AppRoutes.groomingSettings, extra: activePet);
                },
                child: SecondaryActionCard(
                  icon: Icons.content_cut,
                  iconBackgroundColor: AppColors.iconBgLight,
                  iconColor: AppColors.primary,
                  title: AppStrings.addGroomingDetails,
                  subtitle: AppStrings.timeForFreshTrim,
                  onTap: () {},
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Tick & Flea Card (only for dogs and cats)
          if (supportsMedicalCare) ...[
            if (hasTickFleaSettings && !tickFleaSnoozed) ...[
              AnimatedCard(
                index: cardIndex++,
                child: ScaleButton(
                  onPressed: () {
                    if (tickFleaDueSoon) {
                      context.pushNamed(
                        AppRoutes.actionDetail,
                        extra: ActionCardData(
                          actionType: ActionType.tickFlea,
                          pet: activePet,
                        ),
                      );
                    } else {
                      context.pushNamed(AppRoutes.tickFleaSettings, extra: activePet);
                    }
                  },
                  child: CareProgressCard(
                    icon: Icons.shield_outlined,
                    title: AppStrings.tickFleaPrevention,
                    subtitle: tickFleaDueSoon ? AppStrings.reminderToProtect : AppStrings.protectionActive,
                    daysLeft: activePet.tickFleaSettings?.daysUntilDue ?? 30,
                    totalDays: _getTickFleaTotalDays(activePet),
                  ),
                ),
              ),
            ] else if (!hasTickFleaSettings) ...[
              // No tick/flea settings - show add card
              AnimatedCard(
                index: cardIndex++,
                child: ScaleButton(
                  onPressed: () {
                    context.pushNamed(AppRoutes.tickFleaSettings, extra: activePet);
                  },
                  child: SecondaryActionCard(
                    icon: Icons.shield_outlined,
                    iconBackgroundColor: AppColors.cardBlueIconBg,
                    iconColor: AppColors.cardBlueIcon,
                    title: AppStrings.addTickFleaDetails,
                    subtitle: AppStrings.reminderToProtect,
                    onTap: () {},
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],

          // Care Summary Section
          AnimatedCard(
            index: cardIndex++,
            child: CareSummarySection(
              activeTasks: activeTasks,
              urgentCount: urgentCount,
              scheduledCount: scheduledCount,
            ),
          ),

          const SizedBox(height: 24),

          // Lost & Found Section (from Firebase)
          AnimatedCard(
            index: cardIndex++,
            child: _buildLostPetsSection(),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getGroomingBadgeText(PetModel pet) {
    final settings = pet.groomingSettings;
    if (settings == null || settings.nextDueDate == null) {
      return AppStrings.thisWeek;
    }
    final daysUntil = settings.daysUntilDue ?? 0;
    if (daysUntil < 0) {
      return 'Overdue';
    } else if (daysUntil == 0) {
      return 'Today';
    } else if (daysUntil <= 7) {
      return AppStrings.thisWeek;
    }
    return 'In $daysUntil days';
  }

  int _getGroomingTotalDays(PetModel pet) {
    final settings = pet.groomingSettings;
    if (settings == null) {
      return 30;
    }
    switch (settings.frequency) {
      case CareFrequency.weekly:
        return 7;
      case CareFrequency.monthly:
        return 30;
      case CareFrequency.quarterly:
        return 90;
      default:
        return 30;
    }
  }

  int _getTickFleaTotalDays(PetModel pet) {
    final settings = pet.tickFleaSettings;
    if (settings == null) {
      return 30;
    }
    switch (settings.frequency) {
      case CareFrequency.monthly:
        return 30;
      case CareFrequency.quarterly:
        return 90;
      default:
        return 30;
    }
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

  Widget _buildUrgentVaccineCard(List<PetModel> pets, PetModel activePet) {
    // Find the next upcoming non-snoozed vaccine
    final vaccineData = _getUpcomingVaccine(pets);
    if (vaccineData == null) {
      return const SizedBox.shrink();
    }

    final vaccine = vaccineData.$2;
    final vaccineName = vaccine.vaccineName;
    final daysUntil = vaccine.nextDueDate.difference(DateTime.now()).inDays;

    return UrgentVaccineCard(
      vaccineName: vaccineName,
      daysUntilDue: daysUntil,
      nearbyVetsCount: 3,
      distanceKm: 2,
      onFindVetsPressed: () {
        // Navigate to map tab
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
    if (months == 0) {
      final days = difference.inDays;
      return '$days ${AppStrings.daysOld}';
    }
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
        // Skip snoozed vaccines
        if (vaccine.isSnoozed) {
          continue;
        }
        final daysUntilDue = vaccine.nextDueDate.difference(DateTime.now()).inDays;
        if (daysUntilDue >= 0 && daysUntilDue <= 30) {
          return true;
        }
      }
    }
    return false;
  }

  /// Get the first upcoming non-snoozed vaccine
  (PetModel, dynamic)? _getUpcomingVaccine(List<PetModel> pets) {
    for (final pet in pets) {
      for (final vaccine in pet.vaccines) {
        // Skip snoozed vaccines
        if (vaccine.isSnoozed) {
          continue;
        }
        final days = vaccine.nextDueDate.difference(DateTime.now()).inDays;
        if (days >= 0 && days <= 30) {
          return (pet, vaccine);
        }
      }
    }
    return null;
  }
}
