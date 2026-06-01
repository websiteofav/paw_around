import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/pets/care_settings_model.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/repositories/pet_repository.dart';
import 'package:paw_around/services/notification_service.dart';
import 'package:paw_around/ui/pets/widgets/frequency_selector.dart';
import 'package:paw_around/ui/pets/widgets/date_picker_field.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

class TickFleaSettingsScreen extends StatefulWidget {
  final PetModel pet;

  const TickFleaSettingsScreen({
    super.key,
    required this.pet,
  });

  @override
  State<TickFleaSettingsScreen> createState() => _TickFleaSettingsScreenState();
}

class _TickFleaSettingsScreenState extends State<TickFleaSettingsScreen> {
  late CareFrequency _selectedFrequency;
  late DateTime? _lastDate;
  late bool _isSnoozed;
  bool _isSaving = false;
  bool _isUnsnoozeing = false;

  @override
  void initState() {
    super.initState();
    _selectedFrequency =
        widget.pet.tickFleaSettings?.frequency ?? CareFrequency.monthly;
    _lastDate = widget.pet.tickFleaSettings?.lastDate ?? DateTime.now();
    _isSnoozed = widget.pet.tickFleaSettings?.isSnoozed ?? false;
  }

  void _onFrequencyChanged(CareFrequency frequency) {
    setState(() {
      _selectedFrequency = frequency;
    });
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _lastDate = date;
    });
  }

  Future<void> _unsnooze() async {
    if (_isUnsnoozeing) return;

    setState(() {
      _isUnsnoozeing = true;
    });

    try {
      await sl<PetRepository>().unsnoozeTickFlea(widget.pet.id);

      if (mounted) {
        context.read<PetListBloc>().add(const LoadPetList());
        setState(() {
          _isSnoozed = false;
        });

        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.reminderUnsnoozed),
            backgroundColor: AppColors.success,
          ),
        );
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
          _isUnsnoozeing = false;
        });
      }
    }
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final settings = CareSettingsModel(
        frequency: _selectedFrequency,
        lastDate: _lastDate,
        updatedAt: DateTime.now(),
      );

      await sl<PetRepository>().updateTickFleaSettings(widget.pet.id, settings);

      // Schedule notification if reminder is enabled
      if (settings.hasReminder && mounted) {
        final notificationService = NotificationService();
        final hasPermission =
            await notificationService.requestPermissionIfNeeded(
          context,
          widget.pet.name,
          ReminderType.tickFlea,
        );

        if (hasPermission) {
          await notificationService.scheduleCareReminder(
            petId: widget.pet.id,
            petName: widget.pet.name,
            type: ReminderType.tickFlea,
            settings: settings,
          );
        }
      } else {
        // Cancel existing reminders if frequency set to none
        await NotificationService().cancelCareReminder(
          petId: widget.pet.id,
          type: ReminderType.tickFlea,
        );
      }

      // Reload pet list to reflect changes
      if (mounted) {
        context.read<PetListBloc>().add(const LoadPetList());

        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.settingsSaved),
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
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildHero() {
    return Image.asset(
      AppIcons.bugIcon,
      height: 64,
      width: 64,
      color: AppColors.grey150,
    );
  }

  Widget _buildSnoozeBanner() {
    final snoozedUntil = widget.pet.tickFleaSettings?.snoozedUntil;
    final daysLeft = snoozedUntil != null
        ? snoozedUntil.difference(DateTime.now()).inDays
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.snooze,
            color: AppColors.warning,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.reminderSnoozed,
                  style: AppTextStyles.semiBoldStyle600(
                      fontColor: AppColors.textPrimary),
                ),
                Text(
                  '$daysLeft ${daysLeft == 1 ? 'day' : 'days'} remaining',
                  style: AppTextStyles.regularStyle400(
                      fontSize: 12, fontColor: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _isUnsnoozeing ? null : _unsnooze,
            child: _isUnsnoozeing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    AppStrings.unsnooze,
                    style: AppTextStyles.semiBoldStyle600(
                        fontColor: AppColors.warning),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(AppStrings.addTickFleaProtection,
            style: AppTextStyles.boldStyle700(fontColor: AppColors.grey1000)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.grey1000),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (_isSnoozed) _buildSnoozeBanner(),
            _buildHero(),
            const SizedBox(height: 36),
            FrequencySelector(
              title: AppStrings.frequency,
              selectedFrequency: _selectedFrequency,
              subtitle: AppStrings.mostPetsNeedMonthlyPrevention,
              options: const [
                CareFrequency.none,
                CareFrequency.monthly,
                CareFrequency.quarterly,
              ],
              onChanged: _onFrequencyChanged,
            ),
            const SizedBox(height: 24),
            DatePickerField(
              label: AppStrings.lastTreatment,
              selectedDate: _lastDate,
              onDateSelected: _onDateChanged,
            ),
            const SizedBox(height: 32),
            CommonButton(
              text: AppStrings.save,
              onPressed: _isSaving ? null : _save,
              isLoading: _isSaving,
              variant: ButtonVariant.primary,
              textStyle: AppTextStyles.interBoldStyle700(
                fontSize: 16,
                fontColor: AppColors.grey1000,
              ),
              borderRadius: 44,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
