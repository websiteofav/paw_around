import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
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
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/pets/action_type.dart';
import 'package:paw_around/models/pets/care_settings_model.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';
import 'package:paw_around/models/community/lost_found_post.dart';
import 'package:paw_around/models/places/service_type.dart';
import 'package:paw_around/services/location_service.dart';
import 'package:paw_around/ui/home/action_card_detail_screen.dart';
import 'package:paw_around/ui/home/widgets/urgent_vaccine_card.dart';
import 'package:paw_around/ui/home/widgets/pet_selector_bottom_sheet.dart';
import 'package:paw_around/ui/widgets/dashboard_app_bar.dart';
import 'package:paw_around/ui/home/widgets/grooming_due_card.dart';
import 'package:paw_around/ui/home/widgets/care_progress_card.dart';
import 'package:paw_around/ui/home/widgets/care_due_card.dart';
import 'package:paw_around/ui/home/widgets/care_summary_section.dart';
import 'package:paw_around/ui/home/widgets/secondary_action_card.dart';
import 'package:paw_around/ui/home/widgets/lost_pets_section.dart';
import 'package:paw_around/ui/home/widgets/welcome_card.dart';
import 'package:paw_around/ui/home/widgets/skeleton_card.dart';
import 'package:paw_around/ui/widgets/animated_card.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = sl<LocationService>();
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    // Load community posts for lost pets section
    context.read<CommunityBloc>().add(LoadPosts());
    // Load user location for distance calculation
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    final result = await _locationService.getCurrentLocation();
    if (result.isSuccess && result.position != null && mounted) {
      setState(() {
        _userPosition = result.position;
      });
    }
  }

  void _showPetSelector(List<PetModel> pets, String? selectedPetId) {
    PetSelectorBottomSheet.show(
      context: context,
      pets: pets,
      selectedPetId: selectedPetId,
      onPetSelected: (pet) {
        context.read<PetListBloc>().add(SelectPet(petId: pet.id));
      },
    );
  }

  Future<void> _onRefresh() async {
    context.read<PetListBloc>().add(const LoadPetList());
    context.read<CommunityBloc>().add(LoadPosts());
    // Refresh user location as well
    _loadUserLocation();
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
            PetModel? activePet;
            String? selectedPetId;

            if (petState is PetListLoaded) {
              pets = petState.pets;
              activePet = petState.selectedPet;
              selectedPetId = petState.selectedPetId;
            }

            final petAge = activePet != null ? _calculateAge(activePet.dateOfBirth) : null;
            final hasMultiplePets = pets.length > 1;

            return Column(
              children: [
                // Custom App Bar
                DashboardAppBar(
                  title: activePet?.name ?? AppStrings.yourPet,
                  subtitle: petAge,
                  avatarImageUrl: activePet?.imagePath,
                  hasMultiplePets: hasMultiplePets,
                  onAvatarTap: hasMultiplePets ? () => _showPetSelector(pets, selectedPetId) : null,
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

    // Progressive state: Show available cards + setup prompts for missing items
    return _buildProgressiveState(pets, activePet!);
  }

  // State 1: Welcome state for new users
  Widget _buildWelcomeState() {
    return const AnimatedCard(
      index: 0,
      child: WelcomeCard(),
    );
  }

  // Progressive state: Shows available due cards + setup prompts for missing items
  Widget _buildProgressiveState(List<PetModel> pets, PetModel activePet) {
    // Check if pet supports medical care (vaccines, tick & flea)
    final supportsMedicalCare = activePet.supportsMedicalCare;

    // Check for vaccines
    final hasVaccines = activePet.vaccines.isNotEmpty;
    final hasUpcomingVaccine = supportsMedicalCare && _hasUpcomingVaccine(activePet);

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

    return Stack(
      children: [
        // Scrollable content
        SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 140), // Extra bottom padding for floating card
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vaccine Section
              if (supportsMedicalCare) ...[
                if (hasUpcomingVaccine) ...[
                  // Urgent Vaccine Card (red gradient) - due within 30 days
                  AnimatedCard(
                    index: cardIndex++,
                    child: ScaleButton(
                      onPressed: () {
                        final vaccine = _getUpcomingVaccine(activePet);
                        if (vaccine != null) {
                          context.pushNamed(
                            AppRoutes.actionDetail,
                            extra: ActionCardData(
                              actionType: ActionType.vaccine,
                              pet: activePet,
                              vaccine: vaccine,
                              customTitle: vaccine.vaccineName,
                            ),
                          );
                        }
                      },
                      child: _buildUrgentVaccineCard(activePet),
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else if (hasVaccines) ...[
                  // Vaccines exist but not due soon - show progress card
                  AnimatedCard(
                    index: cardIndex++,
                    child: ScaleButton(
                      onPressed: () {
                        final nextVaccine = _getNextVaccine(activePet);
                        if (nextVaccine != null) {
                          context.pushNamed(
                            AppRoutes.actionDetail,
                            extra: ActionCardData(
                              actionType: ActionType.vaccine,
                              pet: activePet,
                              vaccine: nextVaccine,
                              customTitle: nextVaccine.vaccineName,
                            ),
                          );
                        }
                      },
                      child: _buildVaccineProgressCard(activePet),
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  // No vaccines - show add card
                  AnimatedCard(
                    index: cardIndex++,
                    child: ScaleButton(
                      onPressed: () {
                        context.pushNamed(AppRoutes.addVaccine, extra: activePet);
                      },
                      child: const SecondaryActionCard(
                        icon: Icons.vaccines_outlined,
                        iconBackgroundColor: AppColors.cardRedIconBg,
                        iconColor: AppColors.cardRedIcon,
                        title: AppStrings.addVaccineDetails,
                        subtitle: AppStrings.vaccineSubtitle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
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
                            isOverdue: activePet.groomingSettings?.isOverdue ?? false,
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
                      child: tickFleaDueSoon
                          ? CareDueCard.tickFlea(
                              badgeText: _getTickFleaBadgeText(activePet),
                              subtitle: '${AppStrings.reminderToProtect} 🛡️',
                              actionText: AppStrings.viewTreatmentOptions,
                              isOverdue: activePet.tickFleaSettings?.isOverdue ?? false,
                            )
                          : CareProgressCard(
                              icon: Icons.shield_outlined,
                              title: AppStrings.tickFleaPrevention,
                              subtitle: AppStrings.protectionActive,
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
                      child: const SecondaryActionCard(
                        icon: Icons.shield_outlined,
                        iconBackgroundColor: AppColors.cardBlueIconBg,
                        iconColor: AppColors.cardBlueIcon,
                        title: AppStrings.addTickFleaDetails,
                        subtitle: AppStrings.reminderToProtect,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 24),

              // Lost & Found Section (from Firebase)
              AnimatedCard(
                index: cardIndex++,
                child: _buildLostPetsSection(),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),

        // Floating Care Summary Section at bottom
        Positioned(
          left: 16,
          right: 16,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowOverlay.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CareSummarySection(
              activeTasks: activeTasks,
              urgentCount: urgentCount,
              scheduledCount: scheduledCount,
            ),
          ),
        ),
      ],
    );
  }

  String _getGroomingBadgeText(PetModel pet) {
    final settings = pet.groomingSettings;
    if (settings == null || settings.nextDueDate == null) {
      return AppStrings.thisWeek;
    }
    final daysUntil = settings.daysUntilDue ?? 0;
    if (daysUntil < 0) {
      return 'Overdue by ${-daysUntil} days';
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

  String _getTickFleaBadgeText(PetModel pet) {
    final settings = pet.tickFleaSettings;
    if (settings == null || settings.nextDueDate == null) {
      return AppStrings.thisWeek;
    }
    final daysUntil = settings.daysUntilDue ?? 0;
    if (daysUntil < 0) {
      return 'Overdue by ${-daysUntil} days';
    } else if (daysUntil == 0) {
      return 'Today';
    } else if (daysUntil <= 7) {
      return AppStrings.thisWeek;
    }
    return 'In $daysUntil days';
  }

  Widget _buildUrgentVaccineCard(PetModel activePet) {
    // Find the next upcoming non-snoozed vaccine for active pet
    final vaccine = _getUpcomingVaccine(activePet);
    if (vaccine == null) {
      return const SizedBox.shrink();
    }
    final vaccineName = vaccine.vaccineName;
    final daysUntil = vaccine.nextDueDate.difference(DateTime.now()).inDays;

    return UrgentVaccineCard(
      vaccineName: vaccineName,
      daysUntilDue: daysUntil,
      nearbyVetsCount: 3,
      distanceKm: 2,
      onFindVetsPressed: () {
        // Navigate to map tab with vet filter
        context.read<HomeBloc>().add(NavigateToMapWithFilter(ServiceType.vet));
      },
    );
  }

  Widget _buildVaccineProgressCard(PetModel pet) {
    // Find the next upcoming vaccine (any date, not just within 30 days)
    final nextVaccine = _getNextVaccine(pet);
    if (nextVaccine == null) {
      return const SizedBox.shrink();
    }

    final daysUntil = nextVaccine.nextDueDate.difference(DateTime.now()).inDays;
    final vaccineName = nextVaccine.vaccineName;

    return CareProgressCard(
      icon: Icons.vaccines_outlined,
      title: vaccineName,
      subtitle: 'Next in $daysUntil days',
      daysLeft: daysUntil,
      totalDays: 365, // Vaccines typically yearly
    );
  }

  /// Get the next upcoming vaccine for a pet (regardless of due date)
  VaccineModel? _getNextVaccine(PetModel pet) {
    if (pet.vaccines.isEmpty) {
      return null;
    }

    // Find the vaccine with the nearest due date
    VaccineModel? nextVaccine;
    int minDays = 999999;

    for (final vaccine in pet.vaccines) {
      if (vaccine.isSnoozed) {
        continue;
      }
      final days = vaccine.nextDueDate.difference(DateTime.now()).inDays;
      if (days >= 0 && days < minDays) {
        minDays = days;
        nextVaccine = vaccine;
      }
    }

    return nextVaccine;
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
                    id: p.id,
                    name: p.petName,
                    distance: _getDistanceText(p),
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
            context.push('/community/${pet.id}');
          },
        );
      },
    );
  }

  String _getDistanceText(LostFoundPost post) {
    if (_userPosition == null) {
      return 'Nearby';
    }
    return '${_formatDistance(post)} ${AppStrings.kmAway}';
  }

  String _formatDistance(LostFoundPost post) {
    if (_userPosition == null) {
      return '';
    }

    final distanceInMeters = _locationService.calculateDistance(
      startLatitude: _userPosition!.latitude,
      startLongitude: _userPosition!.longitude,
      endLatitude: post.latitude,
      endLongitude: post.longitude,
    );

    // Convert to km and format
    final distanceInKm = distanceInMeters / 1000;
    if (distanceInKm < 1) {
      return '< 1';
    }
    return distanceInKm.toStringAsFixed(1);
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

  /// Check if the active pet has an upcoming or overdue vaccine that needs attention
  bool _hasUpcomingVaccine(PetModel pet) {
    for (final vaccine in pet.vaccines) {
      // Skip snoozed vaccines
      if (vaccine.isSnoozed) {
        continue;
      }
      final daysUntilDue = vaccine.nextDueDate.difference(DateTime.now()).inDays;
      // Include overdue (negative) and due soon (0-30 days)
      if (daysUntilDue <= 30) {
        return true;
      }
    }
    return false;
  }

  /// Get the first non-snoozed vaccine for active pet (overdue first, then due soon)
  VaccineModel? _getUpcomingVaccine(PetModel pet) {
    VaccineModel? overdueVaccine;
    VaccineModel? upcomingVaccine;

    for (final vaccine in pet.vaccines) {
      // Skip snoozed vaccines
      if (vaccine.isSnoozed) {
        continue;
      }
      final days = vaccine.nextDueDate.difference(DateTime.now()).inDays;

      // Overdue takes priority
      if (days < 0 && overdueVaccine == null) {
        overdueVaccine = vaccine;
      } else if (days >= 0 && days <= 30 && upcomingVaccine == null) {
        upcomingVaccine = vaccine;
      }
    }

    return overdueVaccine ?? upcomingVaccine;
  }
}
