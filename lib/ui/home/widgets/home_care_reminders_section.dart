import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/pets/care_settings_model.dart';
import 'package:paw_around/models/pets/action_type.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';
import 'package:paw_around/repositories/pet_repository.dart';
import 'package:paw_around/ui/home/action_card_detail_screen.dart';

class HomeCareRemindersSection extends StatefulWidget {
  final PetModel pet;
  final VoidCallback onVaccinesTap;
  final VoidCallback onTickFleaTap;
  final VoidCallback onGroomingTap;

  const HomeCareRemindersSection({
    super.key,
    required this.pet,
    required this.onVaccinesTap,
    required this.onTickFleaTap,
    required this.onGroomingTap,
  });

  @override
  State<HomeCareRemindersSection> createState() =>
      _HomeCareRemindersSectionState();
}

class _HomeCareRemindersSectionState extends State<HomeCareRemindersSection> {
  final _dismissed = <String>{};
  bool _markingDone = false;

  Future<void> _markVaccineDone(String vaccineId) async {
    if (_markingDone) return;
    setState(() => _markingDone = true);
    try {
      await sl<PetRepository>().markVaccineAsDone(widget.pet.id, vaccineId);
      if (!mounted) return;
      context.read<PetListBloc>().add(const LoadPetList());
    } finally {
      if (mounted) setState(() => _markingDone = false);
    }
  }

  Future<void> _markGroomingDone(String? groomingType) async {
    if (_markingDone) return;
    setState(() => _markingDone = true);
    try {
      await sl<PetRepository>()
          .markGroomingAsDone(widget.pet.id, groomingType: groomingType);
      if (!mounted) return;
      context.read<PetListBloc>().add(const LoadPetList());
    } finally {
      if (mounted) setState(() => _markingDone = false);
    }
  }

  Future<void> _markTickFleaDone() async {
    if (_markingDone) return;
    setState(() => _markingDone = true);
    try {
      await sl<PetRepository>().markTickFleaAsDone(widget.pet.id);
      if (!mounted) return;
      context.read<PetListBloc>().add(const LoadPetList());
    } finally {
      if (mounted) setState(() => _markingDone = false);
    }
  }

  VaccineModel? _mostUrgentVaccine() {
    final upcoming = widget.pet.vaccines
        .where((v) => v.nextDueDate != null && v.setReminder)
        .toList();
    if (upcoming.isEmpty) return null;
    upcoming.sort((a, b) => a.daysUntilDue.compareTo(b.daysUntilDue));
    return upcoming.first;
  }

  void _openActionDetail({
    required ActionType actionType,
    VaccineModel? vaccine,
    String? customTitle,
  }) {
    context.pushNamed(
      AppRoutes.actionDetail,
      extra: ActionCardData(
        actionType: actionType,
        pet: widget.pet,
        vaccine: vaccine,
        customTitle: customTitle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[];

    final urgentVaccine = _mostUrgentVaccine();
    if (urgentVaccine != null && !_dismissed.contains('vaccines')) {
      final total =
          urgentVaccine.nextDueDate!.difference(urgentVaccine.dateGiven).inDays;
      final elapsed = DateTime.now().difference(urgentVaccine.dateGiven).inDays;
      final days = urgentVaccine.daysUntilDue;
      cards.add(_CareReminderCard(
        title: AppStrings.vaccinationDue,
        itemName: urgentVaccine.vaccineName,
        daysText: days < 0
            ? 'Overdue by ${days.abs()} days'
            : 'Due in $days ${days == 1 ? 'day' : 'days'}',
        bgColor: AppColors.quickActionVaccines,
        actionLabel: AppStrings.addVaccine,
        progress: total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 1.0,
        isOverdue: days < 0,
        onCardTap: () => _openActionDetail(
          actionType: ActionType.vaccine,
          vaccine: urgentVaccine,
          customTitle: urgentVaccine.vaccineName,
        ),
        onActionTap: widget.onVaccinesTap,
        onMarkDone: () => _markVaccineDone(urgentVaccine.id),
        onDismiss: () => setState(() => _dismissed.add('vaccines')),
      ));
    }

    final tickFlea = widget.pet.tickFleaSettings;
    if (tickFlea != null &&
        tickFlea.hasReminder &&
        !_dismissed.contains('tickFlea')) {
      final days = tickFlea.daysUntilDue ?? 0;
      cards.add(_CareReminderCard(
        title: AppStrings.tickFleaDue,
        itemName: AppStrings.spotOnTreatment,
        daysText: days < 0
            ? 'Overdue by ${days.abs()} days'
            : 'Due in $days ${days == 1 ? 'day' : 'days'}',
        frequencyLabel: tickFlea.frequency.displayName,
        bgColor: AppColors.quickActionTickFlea,
        actionLabel: AppStrings.addProtection,
        progress: _careProgress(tickFlea),
        isOverdue: days < 0,
        onCardTap: () => _openActionDetail(actionType: ActionType.tickFlea),
        onActionTap: widget.onTickFleaTap,
        onMarkDone: _markTickFleaDone,
        onDismiss: () => setState(() => _dismissed.add('tickFlea')),
      ));
    }

    // Grooming: single card with all active types as separate rows.
    final groomingActive = widget.pet.groomingSettings
        .where((s) => s.hasReminder)
        .toList()
      ..sort((a, b) => (a.daysUntilDue ?? 0).compareTo(b.daysUntilDue ?? 0));
    if (groomingActive.isNotEmpty && !_dismissed.contains('grooming')) {
      cards.add(_GroomingReminderCard(
        items: groomingActive,
        careProgress: _careProgress,
        onItemTap: (item) => _openActionDetail(
          actionType: ActionType.grooming,
          customTitle: item.groomingType ?? AppStrings.grooming,
        ),
        onMarkDone: () => _markGroomingDone(null),
        onActionTap: widget.onGroomingTap,
        onDismiss: () => setState(() => _dismissed.add('grooming')),
      ));
    }

    if (cards.isEmpty) return const SizedBox.shrink();

    return Column(
      children: cards.expand((c) => [c, const SizedBox(height: 16)]).toList()
        ..removeLast(),
    );
  }

  double _careProgress(CareSettingsModel settings) {
    final total = settings.frequency.days;
    if (total == 0) return 0;
    final days = settings.daysUntilDue ?? 0;
    return ((total - days) / total).clamp(0.0, 1.0);
  }
}

class _CareReminderCard extends StatelessWidget {
  final String title;
  final String itemName;
  final String daysText;
  final String? frequencyLabel;
  final Color bgColor;
  final String actionLabel;
  final double progress;
  final bool isOverdue;
  final VoidCallback onCardTap;
  final VoidCallback onActionTap;
  final VoidCallback onMarkDone;
  final VoidCallback onDismiss;

  const _CareReminderCard({
    required this.title,
    required this.itemName,
    required this.daysText,
    this.frequencyLabel,
    required this.bgColor,
    required this.actionLabel,
    required this.progress,
    required this.isOverdue,
    required this.onCardTap,
    required this.onActionTap,
    required this.onMarkDone,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: smoothDecoration(
        cornerRadius: 20,
        color: bgColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: AppTextStyles.boldStyle700(
                      fontSize: 16, fontColor: AppColors.grey1000)),
              GestureDetector(
                onTap: onDismiss,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.grey1000,
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.close, size: 14, color: AppColors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onCardTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: smoothDecoration(
                cornerRadius: 14,
                color: AppColors.white,
                shadows: [
                  BoxShadow(
                      color: AppColors.shadowOverlay.withValues(alpha: 0.10),
                      blurRadius: 6,
                      offset: const Offset(0, 3)),
                  BoxShadow(
                      color: AppColors.shadowOverlay.withValues(alpha: 0.09),
                      blurRadius: 10,
                      offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.requiredIndicator
                              .withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.error_outline,
                            size: 16, color: AppColors.requiredIndicator),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(itemName,
                                style: AppTextStyles.semiBoldStyle600(
                                    fontSize: 14,
                                    fontColor: AppColors.grey1000)),
                            Text(
                              frequencyLabel != null
                                  ? '$daysText ($frequencyLabel)'
                                  : daysText,
                              style: AppTextStyles.regularStyle400(
                                  fontSize: 12,
                                  fontColor: isOverdue
                                      ? AppColors.requiredIndicator
                                      : AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          size: 20, color: AppColors.neutral300),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipSmoothRect(
                    radius: AppSmoothRadius.custom(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.neutral100,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.requiredIndicator),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onMarkDone,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: smoothDecoration(
                      cornerRadius: 20,
                      color: AppColors.white,
                      side: const BorderSide(color: AppColors.neutral300),
                      shadows: [
                        BoxShadow(
                            color:
                                AppColors.shadowOverlay.withValues(alpha: 0.10),
                            blurRadius: 6,
                            offset: const Offset(0, 3)),
                        BoxShadow(
                            color:
                                AppColors.shadowOverlay.withValues(alpha: 0.09),
                            blurRadius: 10,
                            offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Text(AppStrings.markAsDone,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.mediumStyle500(
                            fontSize: 13, fontColor: AppColors.grey1000)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onActionTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: smoothDecoration(
                      cornerRadius: 20,
                      color: AppColors.grey1000,
                      shadows: [
                        BoxShadow(
                            color:
                                AppColors.shadowOverlay.withValues(alpha: 0.10),
                            blurRadius: 6,
                            offset: const Offset(0, 3)),
                        BoxShadow(
                            color:
                                AppColors.shadowOverlay.withValues(alpha: 0.09),
                            blurRadius: 10,
                            offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(actionLabel,
                            style: AppTextStyles.mediumStyle500(
                                fontSize: 12, fontColor: AppColors.white)),
                        const SizedBox(width: 6),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                              color: AppColors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_forward_ios,
                              size: 10, color: AppColors.grey1000),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GroomingReminderCard extends StatelessWidget {
  final List<CareSettingsModel> items;
  final double Function(CareSettingsModel) careProgress;
  final void Function(CareSettingsModel) onItemTap;
  final VoidCallback onMarkDone;
  final VoidCallback onActionTap;
  final VoidCallback onDismiss;

  const _GroomingReminderCard({
    required this.items,
    required this.careProgress,
    required this.onItemTap,
    required this.onMarkDone,
    required this.onActionTap,
    required this.onDismiss,
  });

  Widget _itemRow(CareSettingsModel item) {
    final days = item.daysUntilDue ?? 0;
    final isOverdue = item.isOverdue;
    final daysText = days < 0
        ? 'Overdue by ${days.abs()} days'
        : 'Due in $days ${days == 1 ? 'day' : 'days'}';
    final label = '$daysText (${item.frequency.displayName})';
    return GestureDetector(
      onTap: () => onItemTap(item),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: smoothDecoration(
          cornerRadius: 14,
          color: AppColors.white,
          shadows: [
            BoxShadow(
                color: AppColors.shadowOverlay.withValues(alpha: 0.10),
                blurRadius: 6,
                offset: const Offset(0, 3)),
            BoxShadow(
                color: AppColors.shadowOverlay.withValues(alpha: 0.09),
                blurRadius: 10,
                offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.requiredIndicator.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.error_outline,
                      size: 16, color: AppColors.requiredIndicator),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.groomingType ?? AppStrings.groomingSession,
                          style: AppTextStyles.semiBoldStyle600(
                              fontSize: 14, fontColor: AppColors.grey1000)),
                      Text(label,
                          style: AppTextStyles.regularStyle400(
                              fontSize: 12,
                              fontColor: isOverdue
                                  ? AppColors.requiredIndicator
                                  : AppColors.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    size: 20, color: AppColors.neutral300),
              ],
            ),
            const SizedBox(height: 10),
            ClipSmoothRect(
              radius: AppSmoothRadius.custom(4),
              child: LinearProgressIndicator(
                value: careProgress(item),
                minHeight: 6,
                backgroundColor: AppColors.neutral100,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.requiredIndicator),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: smoothDecoration(
          cornerRadius: 20, color: AppColors.quickActionGrooming),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.groomingDue,
                  style: AppTextStyles.boldStyle700(
                      fontSize: 16, fontColor: AppColors.grey1000)),
              GestureDetector(
                onTap: onDismiss,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                      color: AppColors.grey1000, shape: BoxShape.circle),
                  child:
                      const Icon(Icons.close, size: 14, color: AppColors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < items.length; i++) ...[
            _itemRow(items[i]),
            if (i < items.length - 1) const SizedBox(height: 8),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onMarkDone,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: smoothDecoration(
                      cornerRadius: 20,
                      color: AppColors.white,
                      side: const BorderSide(color: AppColors.neutral300),
                      shadows: [
                        BoxShadow(
                            color:
                                AppColors.shadowOverlay.withValues(alpha: 0.10),
                            blurRadius: 6,
                            offset: const Offset(0, 3)),
                        BoxShadow(
                            color:
                                AppColors.shadowOverlay.withValues(alpha: 0.09),
                            blurRadius: 10,
                            offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Text(AppStrings.markAsDone,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.mediumStyle500(
                            fontSize: 13, fontColor: AppColors.grey1000)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onActionTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: smoothDecoration(
                      cornerRadius: 20,
                      color: AppColors.grey1000,
                      shadows: [
                        BoxShadow(
                            color:
                                AppColors.shadowOverlay.withValues(alpha: 0.10),
                            blurRadius: 6,
                            offset: const Offset(0, 3)),
                        BoxShadow(
                            color:
                                AppColors.shadowOverlay.withValues(alpha: 0.09),
                            blurRadius: 10,
                            offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppStrings.addGrooming,
                            style: AppTextStyles.mediumStyle500(
                                fontSize: 12, fontColor: AppColors.white)),
                        const SizedBox(width: 6),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                              color: AppColors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_forward_ios,
                              size: 10, color: AppColors.grey1000),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
