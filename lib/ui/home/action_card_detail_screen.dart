import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/home/home_bloc.dart';
import 'package:paw_around/bloc/home/home_event.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/pets/action_type.dart';
import 'package:paw_around/models/pets/care_settings_model.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';
import 'package:paw_around/repositories/pet_repository.dart';
import 'package:paw_around/ui/home/widgets/action_info_card.dart';
import 'package:paw_around/ui/home/widgets/action_cta_card.dart';
import 'package:paw_around/ui/home/widgets/care_history_card.dart';
import 'package:paw_around/ui/home/widgets/mark_done_bottom_sheet.dart';
import 'package:paw_around/ui/home/widgets/snooze_bottom_sheet.dart';
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

  DateTime? get _lastDate {
    switch (actionType) {
      case ActionType.vaccine:
        return vaccine?.dateGiven;
      case ActionType.grooming:
        return pet.groomingSettings?.lastDate;
      case ActionType.tickFlea:
        return pet.tickFleaSettings?.lastDate;
    }
  }

  DateTime? get _nextDueDate {
    switch (actionType) {
      case ActionType.vaccine:
        return vaccine?.nextDueDate;
      case ActionType.grooming:
        return pet.groomingSettings?.nextDueDate;
      case ActionType.tickFlea:
        return pet.tickFleaSettings?.nextDueDate;
    }
  }

  String? get _frequencyText {
    switch (actionType) {
      case ActionType.vaccine:
        return null;
      case ActionType.grooming:
        return pet.groomingSettings?.frequency.displayName;
      case ActionType.tickFlea:
        return pet.tickFleaSettings?.frequency.displayName;
    }
  }

  Future<void> _handleMarkAsDone() async {
    final confirmed = await MarkDoneBottomSheet.show(context, _title);
    if (confirmed != true || !mounted) {
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
            await repo.markVaccineAsDone(pet.id, vaccine!.id);
          }
          break;
        case ActionType.grooming:
          await repo.markGroomingAsDone(pet.id);
          break;
        case ActionType.tickFlea:
          await repo.markTickFleaAsDone(pet.id);
          break;
      }

      if (mounted) {
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
    // Navigate to Map screen with filters
    context.read<HomeBloc>().add(HomeTabChanged(1));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
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
                          description: actionType.whyItMatters,
                          icon: Icons.lightbulb_outline,
                          iconColor: AppColors.warning,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Care History Card
                      AnimatedCard(
                        index: 1,
                        child: CareHistoryCard(
                          lastDate: _lastDate,
                          nextDueDate: _nextDueDate,
                          frequency: _frequencyText,
                          actionType: actionType,
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
                ],
              ),

              const SizedBox(height: 16),

              // Countdown circle
              _buildCountdownCircle(days, isOverdue),

              const SizedBox(height: 20),

              // Title
              Text(
                _title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                _subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.white.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isOverdue ? AppStrings.overdue : AppStrings.dueSoon,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
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
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              Text(
                isOverdue ? AppStrings.overdue.toUpperCase() : 'DAYS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white.withValues(alpha: 0.9),
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
            color: Colors.black.withValues(alpha: 0.08),
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
