import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/home/home_bloc.dart';
import 'package:paw_around/bloc/home/home_event.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/constants/analytics_constants.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/pets/action_type.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/places/service_type.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';
import 'package:paw_around/constants/vaccine_constants.dart';
import 'package:paw_around/repositories/pet_repository.dart';
import 'package:paw_around/services/analytics_service.dart';
import 'package:paw_around/services/notification_service.dart';
import 'package:paw_around/ui/home/widgets/action_info_card.dart';
import 'package:paw_around/ui/home/widgets/action_cta_card.dart';
import 'package:paw_around/ui/home/widgets/action_card_timeline.dart';
import 'package:paw_around/ui/home/widgets/mark_done_bottom_sheet.dart';
import 'package:paw_around/ui/home/widgets/snooze_bottom_sheet.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/ui/widgets/animated_card.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

/// Data class to hold action card details
class ActionCardData {
  final ActionType actionType;
  final PetModel pet;
  final VaccineModel? vaccine;
  final String? customTitle;

  const ActionCardData({
    required this.actionType,
    required this.pet,
    this.vaccine,
    this.customTitle,
  });
}

class ActionCardDetailScreen extends StatefulWidget {
  final ActionCardData data;

  const ActionCardDetailScreen({
    super.key,
    required this.data,
  });

  @override
  State<ActionCardDetailScreen> createState() => _ActionCardDetailScreenState();
}

class _ActionCardDetailScreenState extends State<ActionCardDetailScreen> {
  bool _isLoading = false;

  ActionType get actionType => widget.data.actionType;
  PetModel get pet => widget.data.pet;
  VaccineModel? get vaccine => widget.data.vaccine;

  String get _title {
    if (widget.data.customTitle != null) {
      return widget.data.customTitle!;
    }
    if (actionType == ActionType.vaccine && vaccine != null) {
      return vaccine!.vaccineName;
    }
    return actionType.title;
  }

  String get _subtitle {
    return '${AppStrings.forPet} ${pet.name} · ${pet.ageString}';
  }

  bool get _isOverdue {
    switch (actionType) {
      case ActionType.vaccine:
        return vaccine?.isOverdue ?? false;
      case ActionType.grooming:
        return pet.groomingSettings?.isOverdue ?? false;
      case ActionType.tickFlea:
        return pet.tickFleaSettings?.isOverdue ?? false;
    }
  }

  int get _daysUntilDue {
    switch (actionType) {
      case ActionType.vaccine:
        return vaccine?.daysUntilDue ?? 0;
      case ActionType.grooming:
        return pet.groomingSettings?.daysUntilDue ?? 0;
      case ActionType.tickFlea:
        return pet.tickFleaSettings?.daysUntilDue ?? 0;
    }
  }

  Color get _gradientStart {
    switch (actionType) {
      case ActionType.vaccine:
        return AppColors.urgentGradientStart;
      case ActionType.grooming:
        return AppColors.groomingGradientStart;
      case ActionType.tickFlea:
        return AppColors.cardBlueIcon;
    }
  }

  Color get _gradientEnd {
    switch (actionType) {
      case ActionType.vaccine:
        return AppColors.urgentGradientEnd;
      case ActionType.grooming:
        return AppColors.groomingGradientEnd;
      case ActionType.tickFlea:
        return const Color(0xFF1D4ED8);
    }
  }

  /// Get vaccine-specific "Why this matters" text, or fallback to generic
  String get _whyItMatters {
    if (actionType == ActionType.vaccine && vaccine != null) {
      // Look up vaccine-specific explanation from master data
      final vaccines = VaccineConstants.getVaccinesByPetType(pet.species);
      final match = vaccines
          .where(
              (v) => v.name.toLowerCase() == vaccine!.vaccineName.toLowerCase())
          .firstOrNull;
      if (match != null) {
        return match.why;
      }
    }
    return actionType.whyItMatters;
  }

  Future<void> _handleMarkAsDone() async {
    final completionDate = await MarkDoneBottomSheet.show(context, _title);
    if (completionDate == null || !mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repo = sl<PetRepository>();
      final notificationService = NotificationService();

      switch (actionType) {
        case ActionType.vaccine:
          if (vaccine != null) {
            await repo.markVaccineAsDone(pet.id, vaccine!.id,
                completionDate: completionDate);

            // Fetch updated pet to get new nextDueDate
            final updatedPet = await repo.getPetById(pet.id);
            if (updatedPet != null && mounted) {
              VaccineModel? updatedVaccine;
              try {
                updatedVaccine = updatedPet.vaccines.firstWhere(
                  (v) => v.id == vaccine!.id,
                );
              } catch (_) {
                // If vaccine not found, use first vaccine if available
                updatedVaccine = updatedPet.vaccines.isNotEmpty
                    ? updatedPet.vaccines.first
                    : null;
              }

              // Reschedule notifications for the new nextDueDate
              if (updatedVaccine != null && updatedVaccine.setReminder) {
                final hasPermission =
                    await notificationService.requestPermissionIfNeeded(
                  context,
                  updatedPet.name,
                  ReminderType.vaccine,
                );

                if (hasPermission) {
                  await notificationService.scheduleVaccineReminder(
                    petId: updatedPet.id,
                    petName: updatedPet.name,
                    vaccine: updatedVaccine,
                  );
                }
              }
            }
          }
          break;
        case ActionType.grooming:
          await repo.markGroomingAsDone(pet.id, completionDate: completionDate);

          // Fetch updated pet to get new settings
          final updatedPet = await repo.getPetById(pet.id);
          if (updatedPet != null &&
              updatedPet.groomingSettings != null &&
              mounted) {
            final settings = updatedPet.groomingSettings!;

            // Reschedule notifications for the new nextDueDate
            if (settings.hasReminder) {
              final hasPermission =
                  await notificationService.requestPermissionIfNeeded(
                context,
                updatedPet.name,
                ReminderType.grooming,
              );

              if (hasPermission) {
                await notificationService.scheduleCareReminder(
                  petId: updatedPet.id,
                  petName: updatedPet.name,
                  type: ReminderType.grooming,
                  settings: settings,
                );
              }
            }
          }
          break;
        case ActionType.tickFlea:
          await repo.markTickFleaAsDone(pet.id, completionDate: completionDate);

          // Fetch updated pet to get new settings
          final updatedPet = await repo.getPetById(pet.id);
          if (updatedPet != null &&
              updatedPet.tickFleaSettings != null &&
              mounted) {
            final settings = updatedPet.tickFleaSettings!;

            // Reschedule notifications for the new nextDueDate
            if (settings.hasReminder) {
              final hasPermission =
                  await notificationService.requestPermissionIfNeeded(
                context,
                updatedPet.name,
                ReminderType.tickFlea,
              );

              if (hasPermission) {
                await notificationService.scheduleCareReminder(
                  petId: updatedPet.id,
                  petName: updatedPet.name,
                  type: ReminderType.tickFlea,
                  settings: settings,
                );
              }
            }
          }
          break;
      }

      if (mounted) {
        AnalyticsService.logEvent(
          name: AnalyticsEvents.actionCardMarkDone,
          parameters: {
            AnalyticsParams.actionType: actionType.name,
            AnalyticsParams.petType: pet.species,
          },
        );

        context.read<PetListBloc>().add(const LoadPetList());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.markedAsDone),
            backgroundColor: AppColors.success,
          ),
        );

        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSnooze() async {
    final days = await SnoozeBottomSheet.show(context);
    if (days == null || !mounted) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repo = sl<PetRepository>();

      switch (actionType) {
        case ActionType.vaccine:
          if (vaccine != null) {
            await repo.snoozeVaccine(pet.id, vaccine!.id, days);
          }
          break;
        case ActionType.grooming:
          await repo.snoozeGrooming(pet.id, days);
          break;
        case ActionType.tickFlea:
          await repo.snoozeTickFlea(pet.id, days);
          break;
      }

      if (mounted) {
        AnalyticsService.logEvent(
          name: AnalyticsEvents.actionCardSnoozed,
          parameters: {
            AnalyticsParams.actionType: actionType.name,
            AnalyticsParams.petType: pet.species,
          },
        );

        context.read<PetListBloc>().add(const LoadPetList());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Snoozed for $days days'),
            backgroundColor: AppColors.primary,
          ),
        );

        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleCta() {
    // Navigate to Map screen with appropriate filter based on action type
    final ServiceType filter = switch (actionType) {
      ActionType.vaccine => ServiceType.vet,
      ActionType.grooming => ServiceType.groomer,
      ActionType.tickFlea => ServiceType.petStore,
    };

    AnalyticsService.logEvent(
      name: AnalyticsEvents.ctaFindNearbyClicked,
      parameters: {AnalyticsParams.actionType: actionType.name},
    );

    context.read<HomeBloc>().add(NavigateToMapWithFilter(filter));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : CustomScrollView(
              slivers: [
                // Gradient Hero Header
                SliverToBoxAdapter(
                  child: _buildGradientHeader(context),
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Why This Matters Card
                      AnimatedCard(
                        index: 0,
                        child: ActionInfoCard(
                          title: AppStrings.whyThisMatters,
                          description: _whyItMatters,
                          icon: Icons.lightbulb_outline,
                          iconColor: AppColors.warning,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Action Timeline Card
                      AnimatedCard(
                        index: 1,
                        child: ActionCardTimeline(
                          pet: pet,
                          filterByActionType: actionType,
                          filterByVaccineName:
                              actionType == ActionType.vaccine &&
                                      vaccine != null
                                  ? vaccine!.vaccineName
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // What You Can Do Now Card
                      AnimatedCard(
                        index: 2,
                        child: ActionCtaCard(
                          title: AppStrings.whatYouCanDoNow,
                          buttonText: actionType.ctaText,
                          helperText: actionType.helperText,
                          icon: actionType == ActionType.vaccine
                              ? Icons.location_on_outlined
                              : Icons.calendar_today_outlined,
                          iconColor: _gradientStart,
                          onButtonPressed: _handleCta,
                        ),
                      ),
                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),
      // Sticky Bottom Action Bar
      bottomNavigationBar: _isLoading ? null : _buildBottomActionBar(),
    );
  }

  Widget _buildGradientHeader(BuildContext context) {
    final days = _daysUntilDue;
    final isOverdue = _isOverdue;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_gradientStart, _gradientEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: _gradientStart.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              // Back button row
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.white),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  // Edit/Settings button (only for grooming and tick & flea)

                  IconButton(
                    icon: const Icon(Icons.settings, color: AppColors.white),
                    onPressed: () async {
                      switch (actionType) {
                        case ActionType.grooming:
                          context.pushNamed(AppRoutes.groomingSettings,
                              extra: pet);
                          break;
                        case ActionType.tickFlea:
                          context.pushNamed(AppRoutes.tickFleaSettings,
                              extra: pet);
                          break;
                        case ActionType.vaccine:
                          final result =
                              await context.pushNamed(AppRoutes.addVaccine, extra: {
                            'pet': pet,
                            'vaccine': vaccine,
                          });
                          if (!mounted) return;
                          if (result is Map<String, dynamic> &&
                              result['deleted'] == true) {
                            context.goNamed(AppRoutes.home);
                          }
                          break;
                        // Vaccines are managed individually, no general settings
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Countdown circle
              _buildCountdownCircle(days, isOverdue),

              const SizedBox(height: 20),

              // Title
              Text(
                _title,
                style: AppTextStyles.boldStyle700(
                    fontSize: 24, fontColor: AppColors.white),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                _subtitle,
                style: AppTextStyles.regularStyle400(
                  fontSize: 14,
                  fontColor: AppColors.white.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: smoothDecoration(
                  cornerRadius: 20,
                  color: AppColors.white.withValues(alpha: 0.2),
                ),
                child: Text(
                  isOverdue ? AppStrings.overdue : AppStrings.dueSoon,
                  style: AppTextStyles.semiBoldStyle600(
                      fontSize: 13, fontColor: AppColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownCircle(int days, bool isOverdue) {
    final displayDays = days.abs();
    final progress = isOverdue ? 1.0 : (30 - days.clamp(0, 30)) / 30;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress ring
          SizedBox(
            width: 90,
            height: 90,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4,
              backgroundColor: AppColors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          ),
          // Days text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$displayDays',
                style: AppTextStyles.boldStyle700(
                    fontSize: 32, fontColor: AppColors.white),
              ),
              Text(
                isOverdue ? AppStrings.overdue.toUpperCase() : 'DAYS',
                style: AppTextStyles.semiBoldStyle600(
                  fontSize: 10,
                  fontColor: AppColors.white.withValues(alpha: 0.9),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Snooze button (secondary)
            Expanded(
              child: CommonButton(
                size: ButtonSize.medium,
                text: AppStrings.snooze,
                variant: ButtonVariant.outline,
                customColor: AppColors.warning,
                customTextColor: AppColors.warning,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _handleSnooze();
                },
              ),
            ),
            const SizedBox(width: 16),
            // Mark as Done button (primary)
            Expanded(
              child: CommonButton(
                size: ButtonSize.medium,
                text: AppStrings.markAsDone,
                variant: ButtonVariant.primary,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _handleMarkAsDone();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
