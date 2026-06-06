import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/care_settings_model.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

class PetOverviewCareSection extends StatelessWidget {
  final PetModel pet;
  const PetOverviewCareSection({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.careSection,
              style: AppTextStyles.boldStyle700(
                  fontSize: 18, fontColor: AppColors.grey1100)),
          const SizedBox(height: 12),
          _CareCard(
            bgColor: AppColors.quickActionVaccines,
            iconPath: AppIcons.vaccineIcon,
            categoryLabel: AppStrings.vaccines,
            categoryIconPath: AppIcons.syringIcon,
            vaccines: pet.vaccines,
            recommendLabel: pet.vaccines.isEmpty
                ? AppStrings.getRecommedationText(pet.name)
                : null,
            title: pet.vaccines.isEmpty
                ? AppStrings.startVaccinationJourney
                : AppStrings.vaccinations,
            subtitle: AppStrings.protectFromSeriousDiseases,
            ctaText: pet.vaccines.isEmpty
                ? AppStrings.startVaccination
                : AppStrings.addVaccine,
            onTap: () =>
                context.pushNamed(AppRoutes.addVaccine, extra: {'pet': pet}),
            onVaccineTap: (vaccine) => context.pushNamed(AppRoutes.addVaccine,
                extra: {'pet': pet, 'vaccine': vaccine}),
          ),
          const SizedBox(height: 12),
          _CareCard(
            bgColor: AppColors.quickActionTickFlea,
            iconPath: AppIcons.tickAndFleaIcon,
            categoryLabel: AppStrings.tickAndFlea,
            categoryIconPath: AppIcons.bugIcon,
            careSettings: pet.tickFleaSettings,
            title: AppStrings.preventTicksFleasEarly,
            subtitle: AppStrings.keepPetSafeItchFree,
            ctaText: pet.tickFleaSettings == null
                ? AppStrings.addProtection
                : AppStrings.viewSchedule,
            onTap: () =>
                context.pushNamed(AppRoutes.tickFleaSettings, extra: pet),
          ),
          const SizedBox(height: 12),
          _CareCard(
            bgColor: AppColors.quickActionGrooming,
            iconPath: AppIcons.groomingIcon,
            categoryLabel: AppStrings.grooming,
            categoryIconPath: AppIcons.scissorIcon,
            careSettings: pet.groomingSettings,
            title: AppStrings.keepPetCleanHappy,
            subtitle: AppStrings.bookFirstGroomingSession,
            ctaText: pet.groomingSettings == null
                ? AppStrings.addGrooming
                : AppStrings.viewSchedule,
            onTap: () =>
                context.pushNamed(AppRoutes.groomingSettings, extra: pet),
          ),
        ],
      ),
    );
  }
}

class _CareCard extends StatelessWidget {
  final Color bgColor;
  final String iconPath;
  final String categoryLabel;
  final String categoryIconPath;
  final List<VaccineModel>? vaccines;
  final CareSettingsModel? careSettings;
  final String? recommendLabel;
  final String title;
  final String subtitle;
  final String ctaText;
  final VoidCallback onTap;
  final void Function(VaccineModel)? onVaccineTap;

  const _CareCard({
    required this.bgColor,
    required this.iconPath,
    required this.categoryLabel,
    required this.categoryIconPath,
    this.vaccines,
    this.careSettings,
    this.recommendLabel,
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.onTap,
    this.onVaccineTap,
  });

  bool get _hasItems {
    if (vaccines != null) return vaccines!.isNotEmpty;
    return careSettings != null && careSettings!.hasReminder;
  }

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: smoothDecoration(cornerRadius: 20, color: bgColor),
      child: _hasItems ? _filledView() : _emptyView(),
    );
    if (_hasItems) return card;
    return ScaleButton(onPressed: onTap, child: card);
  }

  Widget _categoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: smoothDecoration(cornerRadius: 20, color: AppColors.grey1100),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          categoryIconPath.contains('.png')
              ? Image.asset(categoryIconPath,
                  width: 16, height: 16, color: AppColors.white)
              : SvgPicture.asset(categoryIconPath,
                  width: 16,
                  height: 16,
                  colorFilter:
                      const ColorFilter.mode(AppColors.white, BlendMode.srcIn)),
          const SizedBox(width: 6),
          Text(categoryLabel,
              style: AppTextStyles.interSemiBoldStyle600(
                  fontSize: 12, fontColor: AppColors.white)),
        ],
      ),
    );
  }

  Widget _ctaButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: smoothDecoration(
        cornerRadius: 44,
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
          BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 23)),
          BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0.01),
              blurRadius: 16,
              offset: const Offset(0, 41)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_circle, size: 24, color: AppColors.grey1000),
          const SizedBox(width: 8),
          Text(ctaText,
              style: AppTextStyles.interBoldStyle700(
                  fontSize: 16, fontColor: AppColors.grey1000)),
        ],
      ),
    );
  }

  Widget _emptyView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.asset(iconPath,
                  width: double.infinity, height: 160, fit: BoxFit.contain),
            ),
            Positioned(top: 12, left: 12, child: _categoryChip()),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recommendLabel != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: smoothDecoration(
                      cornerRadius: 20,
                      color: AppColors.primary.withValues(alpha: 0.15)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle,
                          size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(recommendLabel!,
                          style: AppTextStyles.interSemiBoldStyle600(
                              fontSize: 10, fontColor: AppColors.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(title,
                  style: AppTextStyles.interBoldStyle700(
                      fontSize: 15, fontColor: AppColors.grey1100)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: AppTextStyles.interMediumStyle500(
                      fontSize: 14, fontColor: AppColors.grey1000)),
              const SizedBox(height: 24),
              _ctaButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filledView() {
    final rows = _buildItemRows();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _categoryChip(),
          const SizedBox(height: 12),
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1) const SizedBox(height: 8),
          ],
          const SizedBox(height: 12),
          _ctaButton(),
        ],
      ),
    );
  }

  List<Widget> _buildItemRows() {
    if (vaccines != null) {
      final sorted = [...vaccines!.where((v) => v.nextDueDate != null)]
        ..sort((a, b) => a.daysUntilDue.compareTo(b.daysUntilDue));
      return sorted.map(_vaccineRow).toList();
    }
    if (careSettings != null) {
      return _careSettingsRows(careSettings!);
    }
    return [];
  }

  Widget _vaccineRow(VaccineModel v) {
    final days = v.daysUntilDue;
    final isOverdue = days < 0;
    final total = v.nextDueDate!.difference(v.dateGiven).inDays;
    final elapsed = DateTime.now().difference(v.dateGiven).inDays;
    final progress = total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 1.0;
    final freq = _vaccineFrequency(v);
    final daysText = _daysText(days);
    return GestureDetector(
      onTap: onVaccineTap != null ? () => onVaccineTap!(v) : null,
      child: _itemRow(
        name: v.vaccineName,
        daysText: freq.isNotEmpty ? '$daysText ($freq)' : daysText,
        progress: progress,
        isOverdue: isOverdue,
      ),
    );
  }

  List<Widget> _careSettingsRows(CareSettingsModel s) {
    final days = s.daysUntilDue ?? 0;
    final daysText = _daysText(days);
    final freq = _shortFrequency(s.frequency);
    final label = freq.isNotEmpty ? '$daysText ($freq)' : daysText;
    final progress = _careProgress(s);
    final isOverdue = s.isOverdue;

    if (s.groomingTypes.isNotEmpty) {
      return s.groomingTypes
          .map((type) => _itemRow(
                name: type,
                daysText: label,
                progress: progress,
                isOverdue: isOverdue,
              ))
          .toList();
    }
    return [
      _itemRow(
        name: AppStrings.spotOnTreatment,
        daysText: label,
        progress: progress,
        isOverdue: isOverdue,
      ),
    ];
  }

  Widget _itemRow({
    required String name,
    required String daysText,
    required double progress,
    required bool isOverdue,
  }) {
    final textColor =
        isOverdue ? AppColors.requiredIndicator : AppColors.textSecondary;
    return Container(
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
                    shape: BoxShape.circle),
                child: const Icon(Icons.error_outline,
                    size: 16, color: AppColors.requiredIndicator),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: AppTextStyles.semiBoldStyle600(
                            fontSize: 14, fontColor: AppColors.grey1100)),
                    Text(daysText,
                        style: AppTextStyles.regularStyle400(
                            fontSize: 12, fontColor: textColor)),
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
    );
  }

  static String _daysText(int days) => days < 0
      ? 'Overdue by ${days.abs()} ${days.abs() == 1 ? "day" : "days"}'
      : 'Due in $days ${days == 1 ? "day" : "days"}';

  static String _shortFrequency(CareFrequency f) {
    switch (f) {
      case CareFrequency.weekly:
        return 'Weekly';
      case CareFrequency.monthly:
        return 'Monthly';
      case CareFrequency.quarterly:
        return 'Quarterly';
      case CareFrequency.none:
        return '';
    }
  }

  static String _vaccineFrequency(VaccineModel v) {
    if (v.nextDueDate == null) return '';
    final days = v.nextDueDate!.difference(v.dateGiven).inDays;
    if (days <= 31) return 'Monthly';
    if (days <= 95) return 'Quarterly';
    if (days <= 200) return 'Every 6 months';
    return 'Yearly';
  }

  static double _careProgress(CareSettingsModel s) {
    final total = s.frequency.days;
    if (total == 0) return 0;
    final days = s.daysUntilDue ?? 0;
    return ((total - days) / total).clamp(0.0, 1.0);
  }
}
