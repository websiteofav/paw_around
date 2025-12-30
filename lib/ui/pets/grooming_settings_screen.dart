import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/pets/care_settings_model.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/repositories/pet_repository.dart';
import 'package:paw_around/services/notification_service.dart';
import 'package:paw_around/ui/pets/widgets/care_app_bar.dart';
import 'package:paw_around/ui/pets/widgets/frequency_selector.dart';
import 'package:paw_around/ui/pets/widgets/date_picker_field.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

class GroomingSettingsScreen extends StatefulWidget {
  final PetModel pet;

  const GroomingSettingsScreen({
    super.key,
    required this.pet,
  });

  @override
  State<GroomingSettingsScreen> createState() => _GroomingSettingsScreenState();
}

class _GroomingSettingsScreenState extends State<GroomingSettingsScreen> {
  late CareFrequency _selectedFrequency;
  late DateTime? _lastDate;
  late bool _isSnoozed;
  bool _isSaving = false;
  bool _isUnsnoozeing = false;

  @override
  void initState() {
    super.initState();
    _selectedFrequency = widget.pet.groomingSettings?.frequency ?? CareFrequency.none;
    _lastDate = widget.pet.groomingSettings?.lastDate ?? DateTime.now();
    _isSnoozed = widget.pet.groomingSettings?.isSnoozed ?? false;
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
      await sl<PetRepository>().unsnoozeGrooming(widget.pet.id);

      if (mounted) {
        context.read<PetListBloc>().add(const LoadPetList());
        setState(() {
          _isSnoozed = false;
        });

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

      await sl<PetRepository>().updateGroomingSettings(widget.pet.id, settings);

      // Schedule notification if reminder is enabled
      if (settings.hasReminder && mounted) {
        final notificationService = NotificationService();
        final hasPermission = await notificationService.requestPermissionIfNeeded(
          context,
          widget.pet.name,
          ReminderType.grooming,
        );

        if (hasPermission) {
          await notificationService.scheduleCareReminder(
            petId: widget.pet.id,
            petName: widget.pet.name,
            type: ReminderType.grooming,
            settings: settings,
          );
        }
      } else {
        // Cancel existing reminders if frequency set to none
        await NotificationService().cancelCareReminder(
          petId: widget.pet.id,
          type: ReminderType.grooming,
        );
      }

      // Reload pet list to reflect changes
      if (mounted) {
        context.read<PetListBloc>().add(const LoadPetList());

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

  Widget _buildSnoozeBanner() {
    final snoozedUntil = widget.pet.groomingSettings?.snoozedUntil;
    final daysLeft = snoozedUntil != null ? snoozedUntil.difference(DateTime.now()).inDays : 0;

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
          Icon(
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$daysLeft ${daysLeft == 1 ? 'day' : 'days'} remaining',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
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
                    style: TextStyle(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Custom App Bar
          CareAppBar(
            pet: widget.pet,
            screenTitle: AppStrings.grooming,
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Snooze banner
                  if (_isSnoozed) _buildSnoozeBanner(),

                  // Frequency selector
                  FrequencySelector(
                    title: AppStrings.frequency,
                    selectedFrequency: _selectedFrequency,
                    options: const [
                      CareFrequency.none,
                      CareFrequency.weekly,
                      CareFrequency.monthly,
                      CareFrequency.quarterly,
                    ],
                    onChanged: _onFrequencyChanged,
                  ),

                  const SizedBox(height: 16),

                  // Date picker
                  DatePickerField(
                    label: AppStrings.lastGrooming,
                    selectedDate: _lastDate,
                    onDateSelected: _onDateChanged,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Save button
          Padding(
            padding: const EdgeInsets.all(16),
            child: CommonButton(
              text: AppStrings.save,
              onPressed: _isSaving ? null : _save,
              isLoading: _isSaving,
              size: ButtonSize.medium,
            ),
          ),
        ],
      ),
    );
  }
}
