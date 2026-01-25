import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/constants/vaccine_constants.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/vaccines/vaccine_master_data.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';
import 'package:paw_around/repositories/pet_repository.dart';
import 'package:paw_around/services/notification_service.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/ui/widgets/common_form_field.dart';

class AddVaccineScreen extends StatefulWidget {
  final PetModel? pet;
  final VaccineModel? vaccineToEdit;

  const AddVaccineScreen({super.key, this.pet, this.vaccineToEdit});

  @override
  State<AddVaccineScreen> createState() => _AddVaccineScreenState();
}

class _AddVaccineScreenState extends State<AddVaccineScreen> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _customVaccineNameController =
      TextEditingController();

  VaccineMasterData? _selectedVaccine;
  bool _isOtherSelected = false;
  DateTime? _dateGiven;
  DateTime? _nextDueDate;
  bool _setReminder = true;

  final Map<String, String> _errors = {};
  bool _isEditMode = false;
  bool _isSaving = false;
  bool _isSnoozed = false;
  bool _isUnsnoozeing = false;

  List<VaccineMasterData> get _availableVaccines {
    if (widget.pet != null) {
      return VaccineConstants.getVaccinesByPetType(widget.pet!.species);
    }
    // Fallback to all vaccines if no pet specified
    return [...VaccineConstants.dogVaccines, ...VaccineConstants.catVaccines];
  }

  // Group vaccines by category
  List<VaccineMasterData> get _requiredCoreVaccines {
    return _availableVaccines
        .where((v) => v.category == 'mandatory' || v.category == 'core')
        .toList()
      ..sort((a, b) {
        // Mandatory always first, then core, then alphabetically
        if (a.category == 'mandatory' && b.category != 'mandatory') return -1;
        if (a.category != 'mandatory' && b.category == 'mandatory') return 1;
        return a.name.compareTo(b.name);
      });
  }

  List<VaccineMasterData> get _recommendedVaccines {
    return _availableVaccines
        .where((v) => v.category == 'recommended' || v.category == 'optional')
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  void initState() {
    super.initState();
    _initializeFromVaccine();
  }

  void _initializeFromVaccine() {
    if (widget.vaccineToEdit != null) {
      _isEditMode = true;
      final vaccine = widget.vaccineToEdit!;

      // Try to find the matching VaccineMasterData
      try {
        _selectedVaccine = _availableVaccines.firstWhere(
          (v) => v.name.toLowerCase() == vaccine.vaccineName.toLowerCase(),
        );
        _isOtherSelected = false;
      } catch (e) {
        // Custom vaccine - not in master list
        _selectedVaccine = null;
        _isOtherSelected = true;
        _customVaccineNameController.text = vaccine.vaccineName;
      }

      _dateGiven = vaccine.dateGiven;
      _nextDueDate = vaccine.nextDueDate;
      _notesController.text = vaccine.notes;
      _setReminder = vaccine.setReminder;
      _isSnoozed = vaccine.isSnoozed;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _customVaccineNameController.dispose();
    super.dispose();
  }

  void _onVaccineSelected(VaccineMasterData? vaccine) {
    setState(() {
      _selectedVaccine = vaccine;
      _isOtherSelected = false;
      _customVaccineNameController.clear();
      _errors.remove('vaccineName');
      _errors.remove('customVaccineName');

      // Auto-calculate next due date if date given is set
      if (_dateGiven != null && vaccine != null) {
        _nextDueDate = vaccine.calculateNextDueDate(_dateGiven!);
      }
    });
  }

  void _onOtherSelected() {
    setState(() {
      _selectedVaccine = null;
      _isOtherSelected = true;
      _errors.remove('vaccineName');
    });
  }

  void _onDateGivenSelected(DateTime date) {
    setState(() {
      _dateGiven = date;
      _errors.remove('dateGiven');

      // Auto-calculate next due date based on vaccine frequency
      if (_selectedVaccine != null) {
        _nextDueDate = _selectedVaccine!.calculateNextDueDate(date);
        _errors.remove('nextDueDate');
      }
    });
  }

  bool _validate() {
    _errors.clear();

    if (_isOtherSelected) {
      if (_customVaccineNameController.text.trim().isEmpty) {
        _errors['customVaccineName'] = AppStrings.pleaseEnterVaccineName;
      }
    } else if (_selectedVaccine == null) {
      _errors['vaccineName'] = AppStrings.pleaseEnterVaccineName;
    }
    if (_dateGiven == null) {
      _errors['dateGiven'] = AppStrings.pleaseSelectDateGiven;
    }
    if (_nextDueDate == null && _setReminder) {
      _errors['nextDueDate'] = AppStrings.pleaseSelectNextDueDate;
    }
    // Validate nextDueDate is after dateGiven
    if (_dateGiven != null &&
        _nextDueDate != null &&
        _nextDueDate!.isBefore(_dateGiven!) &&
        _setReminder) {
      _errors['nextDueDate'] = AppStrings.nextDueDateAfterDateGiven;
    }

    setState(() {});
    return _errors.isEmpty;
  }

  Future<void> _saveVaccine() async {
    if (!_validate()) {
      return;
    }

    // Validate pet is available
    if (widget.pet == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.petRequiredForVaccine),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      final vaccineName = _isOtherSelected
          ? _customVaccineNameController.text.trim()
          : _selectedVaccine!.name;

      VaccineModel vaccine;
      if (_isEditMode && widget.vaccineToEdit != null) {
        // Edit mode: update completion history if dateGiven changed
        List<DateTime> updatedHistory =
            List<DateTime>.from(widget.vaccineToEdit!.completionHistory);

        // Check if dateGiven actually changed (compare year, month, day only)
        final oldDateGiven = widget.vaccineToEdit!.dateGiven;
        final newDateGiven = _dateGiven!;
        final dateChanged = oldDateGiven.year != newDateGiven.year ||
            oldDateGiven.month != newDateGiven.month ||
            oldDateGiven.day != newDateGiven.day;

        // Calculate original interval from stored nextDueDate and dateGiven
        // Ensure interval is non-negative (nextDueDate should be after dateGiven)
        final originalInterval = widget.vaccineToEdit!.nextDueDate != null
            ? (widget.vaccineToEdit!.nextDueDate!
                    .difference(widget.vaccineToEdit!.dateGiven)
                    .inDays)
                .clamp(0, double.infinity)
                .toInt()
            : 0;

        // If dateGiven changed, update the latest history entry
        if (dateChanged) {
          // Sort history descending first to ensure latest is at index 0
          updatedHistory.sort((a, b) => b.compareTo(a));

          // Remove only the first (latest) entry that matches oldDateGiven
          final indexToRemove = updatedHistory.indexWhere((d) =>
              d.year == oldDateGiven.year &&
              d.month == oldDateGiven.month &&
              d.day == oldDateGiven.day);
          if (indexToRemove != -1) {
            updatedHistory.removeAt(indexToRemove);
          }

          // Add the new dateGiven as the latest entry
          updatedHistory.add(newDateGiven);

          // Sort descending again (most recent first)
          updatedHistory.sort((a, b) => b.compareTo(a));
        }

        // Recalculate nextDueDate from new dateGiven and original interval
   // Check if nextDueDate was manually changed
final nextDueDateChanged = widget.vaccineToEdit!.nextDueDate != null &&
    _nextDueDate != null &&
    widget.vaccineToEdit!.nextDueDate!.difference(_nextDueDate!).inDays != 0;

// Use manual value if user changed it, otherwise recalculate
final calculatedNextDueDate = _setReminder && originalInterval > 0 && !nextDueDateChanged
    ? newDateGiven.add(Duration(days: originalInterval))
    : (_setReminder ? _nextDueDate : null);

        vaccine = widget.vaccineToEdit!.copyWith(
          vaccineName: vaccineName,
          dateGiven: _dateGiven!,
          nextDueDate: calculatedNextDueDate,
          notes: _notesController.text,
          setReminder: _setReminder,
          updatedAt: DateTime.now(),
          completionHistory: updatedHistory, // Updated history
        );
      } else {
        // New vaccine
        vaccine = VaccineModel.create(
          vaccineName: vaccineName,
          dateGiven: _dateGiven!,
          nextDueDate: _setReminder ? _nextDueDate : null,
          notes: _notesController.text,
          setReminder: _setReminder,
        );
      }

      await sl<PetRepository>().updateVaccine(widget.pet!.id, vaccine);

      // Schedule or cancel notification based on reminder setting
      if (mounted) {
        if (_setReminder) {
          // Schedule notification if reminder is enabled
          final notificationService = NotificationService();
          final hasPermission =
              await notificationService.requestPermissionIfNeeded(
            context,
            widget.pet!.name,
            ReminderType.vaccine,
          );

          if (hasPermission) {
            await notificationService.scheduleVaccineReminder(
              petId: widget.pet!.id,
              petName: widget.pet!.name,
              vaccine: vaccine,
            );
          }
        } else {
          // Cancel existing reminders if reminder is disabled
          await NotificationService().cancelVaccineReminder(
            petId: widget.pet!.id,
            vaccineId: vaccine.id,
          );
        }
      }

      // Refresh pet list so Home screen and other screens update
      if (mounted) {
        context.read<PetListBloc>().add(const LoadPetList());
      }

      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode
                ? AppStrings.vaccineSaved
                : AppStrings.vaccineAddedSuccessfully),
            backgroundColor: AppColors.success,
          ),
        );

        // Return the vaccine to the parent screen
        context.pop(vaccine);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEditMode ? AppStrings.editVaccine : AppStrings.addVaccine,
          style:
              AppTextStyles.boldStyle700(fontColor: AppColors.navigationText),
        ),
        backgroundColor: AppColors.navigationBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Snooze Banner (only in edit mode when snoozed)
            if (_isEditMode && _isSnoozed) _buildSnoozeBanner(),

            // Syringe Icon
            _buildSyringeIcon(),
            const SizedBox(height: 24),

            // Vaccine Name Dropdown
            _buildVaccineSelector(),
            const SizedBox(height: 16),

            // Date Given
            _buildDateField(
              label: AppStrings.dateGiven,
              selectedDate: _dateGiven,
              error: _errors['dateGiven'],
              onTap: () => _selectDateGiven(),
            ),
            const SizedBox(height: 16),

            // Next Due Date
            _buildDateField(
              label: AppStrings.nextDueDate,
              selectedDate: _nextDueDate,
              error: _errors['nextDueDate'],
              onTap: () => _selectNextDueDate(),
              helperText: _selectedVaccine != null
                  ? AppStrings.autoCalculatedHelperText
                  : null,
            ),
            const SizedBox(height: 16),

            // Notes
            _buildNotesField(),
            const SizedBox(height: 24),

            // Reminder Toggle
            _buildReminderSection(),
            const SizedBox(height: 32),

            // Save Button
            CommonButton(
              text: AppStrings.saveVaccine,
              onPressed: _saveVaccine,
              variant: ButtonVariant.primary,
              size: ButtonSize.medium,
              isLoading: _isSaving,
            ),

            // Delete Button (only in edit mode)
            if (_isEditMode) ...[
              const SizedBox(height: 12),
              _buildDeleteButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: _showDeleteConfirmation,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.error),
        ),
        child: Center(
          child: Text(
            AppStrings.deleteVaccine,
            style: AppTextStyles.semiBoldStyle600(
                fontSize: 16, fontColor: AppColors.error),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    bool isDeleting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.vaccines_outlined,
                  size: 32,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.deleteVaccineConfirmTitle,
                style: AppTextStyles.semiBoldStyle600(
                  fontSize: 18,
                  fontColor: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.deleteVaccineConfirmMessage,
                style: AppTextStyles.regularStyle400(
                    fontSize: 14, fontColor: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      text: AppStrings.cancel,
                      variant: ButtonVariant.secondary,
                      size: ButtonSize.small,
                      onPressed: isDeleting
                          ? null
                          : () => Navigator.of(dialogContext).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CommonButton(
                      text: AppStrings.delete,
                      variant: ButtonVariant.danger,
                      size: ButtonSize.small,
                      isLoading: isDeleting,
                      onPressed: isDeleting
                          ? null
                          : () async {
                              setDialogState(() => isDeleting = true);
                              await _deleteVaccine(dialogContext);
                            },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteVaccine(BuildContext dialogContext) async {
    if (widget.pet == null || widget.vaccineToEdit == null) {
      return;
    }

    try {
      await sl<PetRepository>()
          .deleteVaccine(widget.pet!.id, widget.vaccineToEdit!.id);
      if (mounted) {
        Navigator.of(dialogContext).pop();
        context.read<PetListBloc>().add(const LoadPetList());
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.vaccineDeletedSuccessfully),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _unsnooze() async {
    if (_isUnsnoozeing || widget.pet == null || widget.vaccineToEdit == null) {
      return;
    }

    setState(() {
      _isUnsnoozeing = true;
    });

    try {
      await sl<PetRepository>()
          .unsnoozeVaccine(widget.pet!.id, widget.vaccineToEdit!.id);

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

  Widget _buildSnoozeBanner() {
    final snoozedUntil = widget.vaccineToEdit?.snoozedUntil;
    final daysLeft = snoozedUntil != null
        ? snoozedUntil.difference(DateTime.now()).inDays
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
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

  Widget _buildSyringeIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.vaccines_outlined,
        size: 40,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildVaccineSelector() {
    final displayName = _isOtherSelected
        ? _customVaccineNameController.text.isNotEmpty
            ? _customVaccineNameController.text
            : AppStrings.otherVaccine
        : _selectedVaccine?.name ?? AppStrings.selectVaccine;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppStrings.vaccineName,
              style: AppTextStyles.mediumStyle500(
                  fontSize: 14, fontColor: AppColors.textPrimary),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: AppTextStyles.mediumStyle500(
                  fontSize: 16, fontColor: AppColors.error),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showVaccineSelectorBottomSheet(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _errors['vaccineName'] != null ||
                        _errors['customVaccineName'] != null
                    ? AppColors.error
                    : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.vaccines_outlined,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName,
                        style: AppTextStyles.mediumStyle500(
                          fontSize: 16,
                          fontColor: _isOtherSelected &&
                                  _customVaccineNameController.text.isEmpty
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (_selectedVaccine != null)
                        Text(
                          _selectedVaccine!.helperText,
                          style: AppTextStyles.regularStyle400(
                            fontSize: 12,
                            fontColor: AppColors.textSecondary,
                          ),
                        )
                      else if (_isOtherSelected)
                        Text(
                          AppStrings.enterCustomVaccine,
                          style: AppTextStyles.regularStyle400(
                            fontSize: 12,
                            fontColor: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (_errors['vaccineName'] != null ||
            _errors['customVaccineName'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _errors['vaccineName'] ?? _errors['customVaccineName'] ?? '',
              style: AppTextStyles.regularStyle400(
                  fontSize: 12, fontColor: AppColors.error),
            ),
          ),
        if (_selectedVaccine != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _selectedVaccine!.why,
              style: AppTextStyles.regularStyle400(
                  fontSize: 13, fontColor: AppColors.textSecondary),
            ),
          ),
        // Custom vaccine name field (shown when "Other" is selected)
        if (_isOtherSelected) ...[
          const SizedBox(height: 16),
          CommonFormField(
            controller: _customVaccineNameController,
            label: AppStrings.customVaccineName,
            hintText: AppStrings.enterCustomVaccine,
            isRequired: true,
            enabled: !_isSaving,
            onChanged: (value) {
              setState(() {
                _errors.remove('customVaccineName');
              });
            },
            errorText: _errors['customVaccineName'],
          ),
        ],
      ],
    );
  }

  void _showVaccineSelectorBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                AppStrings.selectVaccine,
                style: AppTextStyles.semiBoldStyle600(
                  fontSize: 20,
                  fontColor: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Scrollable vaccine list
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Required / Core section
                    if (_requiredCoreVaccines.isNotEmpty) ...[
                      _buildSectionHeader(AppStrings.requiredCore),
                      const SizedBox(height: 12),
                      ..._requiredCoreVaccines
                          .map((vaccine) => _buildVaccineOption(vaccine)),
                      const SizedBox(height: 24),
                    ],
                    // Recommended section
                    if (_recommendedVaccines.isNotEmpty) ...[
                      _buildSectionHeader(AppStrings.recommendedVaccines),
                      const SizedBox(height: 12),
                      ..._recommendedVaccines
                          .map((vaccine) => _buildVaccineOption(vaccine)),
                      const SizedBox(height: 24),
                    ],
                    // Other option
                    _buildVaccineOption(null), // null indicates "Other"
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.mediumStyle500(
          fontSize: 12,
          fontColor: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildVaccineOption(VaccineMasterData? vaccine) {
    final isOther = vaccine == null;
    final isSelected =
        isOther ? _isOtherSelected : _selectedVaccine?.id == vaccine.id;

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        if (isOther) {
          _onOtherSelected();
        } else {
          _onVaccineSelected(vaccine);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isOther
                    ? AppColors.textSecondary.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isOther ? Icons.add_circle_outline : Icons.vaccines_outlined,
                color: isOther ? AppColors.textSecondary : AppColors.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        isOther ? AppStrings.otherVaccine : vaccine.name,
                        style: AppTextStyles.mediumStyle500(
                          fontSize: 16,
                          fontColor: AppColors.textPrimary,
                        ),
                      ),
                      if (!isOther && vaccine.category == 'mandatory') ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            AppStrings.requiredBadge,
                            style: AppTextStyles.regularStyle400(
                              fontSize: 10,
                              fontColor: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isOther
                        ? AppStrings.enterCustomVaccine
                        : vaccine.helperText,
                    style: AppTextStyles.regularStyle400(
                      fontSize: 12,
                      fontColor: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? selectedDate,
    required String? error,
    required VoidCallback onTap,
    String? helperText,
  }) {
    if (label == AppStrings.nextDueDate && !_setReminder) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.mediumStyle500(
                  fontSize: 14, fontColor: AppColors.textPrimary),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: AppTextStyles.mediumStyle500(
                  fontSize: 16, fontColor: AppColors.error),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: error != null ? AppColors.error : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? _formatDate(selectedDate)
                        : AppStrings.selectDate,
                    style: AppTextStyles.regularStyle400(
                      fontSize: 16,
                      fontColor: selectedDate != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today_outlined,
                    color: AppColors.primary, size: 20),
              ],
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              error,
              style: AppTextStyles.regularStyle400(
                  fontSize: 12, fontColor: AppColors.error),
            ),
          ),
        if (helperText != null && error == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              helperText,
              style: AppTextStyles.regularStyle400(
                  fontSize: 12, fontColor: AppColors.textSecondary),
            ),
          ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.notes,
          style: AppTextStyles.mediumStyle500(
              fontSize: 14, fontColor: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: AppStrings.optionalNotesHint,
              hintStyle: AppTextStyles.regularStyle400(
                  fontSize: 16, fontColor: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.reminderNotification,
                  style: AppTextStyles.mediumStyle500(
                      fontSize: 16, fontColor: AppColors.textPrimary),
                ),
                Text(
                  AppStrings.getNotifiedBeforeNextDose,
                  style: AppTextStyles.regularStyle400(
                      fontSize: 12, fontColor: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: _setReminder,
            onChanged: (value) => setState(() => _setReminder = value),
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _selectDateGiven() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateGiven ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      _onDateGivenSelected(date);
    }
  }

  Future<void> _selectNextDueDate() async {
    final now = DateTime.now();
    // Ensure initialDate is not before firstDate
    final initialDate = _nextDueDate != null && _nextDueDate!.isAfter(now)
        ? _nextDueDate!
        : now.add(const Duration(days: 30));

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _nextDueDate = date;
        _errors.remove('nextDueDate');
      });
    }
  }
}
