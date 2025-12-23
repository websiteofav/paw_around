import 'package:flutter/material.dart';
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
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';
import 'package:paw_around/repositories/pet_repository.dart';
import 'package:paw_around/ui/home/widgets/action_summary_card.dart';
import 'package:paw_around/ui/home/widgets/action_info_card.dart';
import 'package:paw_around/ui/home/widgets/action_cta_card.dart';
import 'package:paw_around/ui/home/widgets/mark_done_bottom_sheet.dart';
import 'package:paw_around/ui/home/widgets/snooze_bottom_sheet.dart';
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

  String get _summaryTitle {
    switch (actionType) {
      case ActionType.vaccine:
        if (vaccine != null) {
          return vaccine!.timeUntilDue;
        }
        return 'Vaccine due';
      case ActionType.grooming:
        final settings = pet.groomingSettings;
        if (settings != null && settings.daysUntilDue != null) {
          final days = settings.daysUntilDue!;
          if (days < 0) {
            return 'Grooming ${-days} days overdue';
          }
          return 'Grooming due in $days days';
        }
        return 'Grooming due';
      case ActionType.tickFlea:
        final settings = pet.tickFleaSettings;
        if (settings != null && settings.daysUntilDue != null) {
          final days = settings.daysUntilDue!;
          if (days < 0) {
            return 'Treatment ${-days} days overdue';
          }
          return 'Treatment due in $days days';
        }
        return 'Treatment due';
    }
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Summary Card
                  ActionSummaryCard(
                    title: _summaryTitle,
                    subtitle: _subtitle,
                    petImageUrl: pet.imagePath,
                    isOverdue: _isOverdue,
                  ),
                  const SizedBox(height: 16),

                  // Why This Matters Card
                  ActionInfoCard(
                    title: AppStrings.whyThisMatters,
                    description: actionType.whyItMatters,
                    onLearnMoreTap: () {
                      // TODO: Navigate to learn more
                    },
                  ),
                  const SizedBox(height: 16),

                  // What You Can Do Now Card
                  ActionCtaCard(
                    title: AppStrings.whatYouCanDoNow,
                    description: actionType.whyItMatters,
                    buttonText: actionType.ctaText,
                    helperText: actionType.helperText,
                    onButtonPressed: _handleCta,
                    onLearnMoreTap: () {
                      // TODO: Navigate to learn more
                    },
                  ),
                  const SizedBox(height: 16),

                  // Secondary Actions
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CommonButton(
                            size: ButtonSize.small,
                            text: AppStrings.snooze,
                            variant: ButtonVariant.outline,
                            customColor: AppColors.warning,
                            customTextColor: AppColors.warning,
                            onPressed: _handleSnooze,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CommonButton(
                            size: ButtonSize.small,
                            text: AppStrings.markAsDone,
                            customColor: AppColors.authPrimaryButton,
                            customTextColor: AppColors.authPrimaryButton,
                            variant: ButtonVariant.outline,
                            onPressed: _handleMarkAsDone,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
