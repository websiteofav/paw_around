import 'package:flutter/material.dart';
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
import 'package:paw_around/ui/widgets/common_button.dart';

class AddVaccineScreen extends StatefulWidget {
  final PetModel? pet;
  final VaccineModel? vaccineToEdit;

  const AddVaccineScreen({super.key, this.pet, this.vaccineToEdit});

  @override
  State<AddVaccineScreen> createState() => _AddVaccineScreenState();
}

class _AddVaccineScreenState extends State<AddVaccineScreen> {
  final TextEditingController _notesController = TextEditingController();

  VaccineMasterData? _selectedVaccine;
  DateTime? _dateGiven;
  DateTime? _nextDueDate;
  bool _setReminder = true;

  final Map<String, String> _errors = {};
  bool _isEditMode = false;

  List<VaccineMasterData> get _availableVaccines {
    if (widget.pet != null) {
      return VaccineConstants.getVaccinesByPetType(widget.pet!.species);
    }
    // Fallback to all vaccines if no pet specified
    return [...VaccineConstants.dogVaccines, ...VaccineConstants.catVaccines];
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

      // Find the matching VaccineMasterData
      _selectedVaccine = _availableVaccines.firstWhere(
        (v) => v.name.toLowerCase() == vaccine.vaccineName.toLowerCase(),
        orElse: () => _availableVaccines.first,
      );

      _dateGiven = vaccine.dateGiven;
      _nextDueDate = vaccine.nextDueDate;
      _notesController.text = vaccine.notes;
      _setReminder = vaccine.setReminder;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _onVaccineSelected(VaccineMasterData? vaccine) {
    setState(() {
      _selectedVaccine = vaccine;
      _errors.remove('vaccineName');

      // Auto-calculate next due date if date given is set
      if (_dateGiven != null && vaccine != null) {
        _nextDueDate = vaccine.calculateNextDueDate(_dateGiven!);
      }
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

    if (_selectedVaccine == null) {
      _errors['vaccineName'] = AppStrings.pleaseEnterVaccineName;
    }
    if (_dateGiven == null) {
      _errors['dateGiven'] = AppStrings.pleaseSelectDateGiven;
    }
    if (_nextDueDate == null) {
      _errors['nextDueDate'] = AppStrings.pleaseSelectNextDueDate;
    }

    setState(() {});
    return _errors.isEmpty;
  }

  void _saveVaccine() async {
    if (!_validate()) {
      return;
    }

    final vaccine = VaccineModel.create(
      vaccineName: _selectedVaccine!.name,
      dateGiven: _dateGiven!,
      nextDueDate: _nextDueDate!,
      notes: _notesController.text,
      setReminder: _setReminder,
    );

    await sl<PetRepository>().updateVaccine(widget.pet!.id, vaccine);

    // Refresh pet list so Home screen and other screens update
    if (context.mounted) {
      context.read<PetListBloc>().add(const LoadPetList());
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.vaccineAddedSuccessfully),
          backgroundColor: AppColors.success,
        ),
      );

      // Return the vaccine to the parent screen
      context.pop(vaccine);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEditMode ? AppStrings.editVaccine : AppStrings.addVaccine,
          style: const TextStyle(
            color: AppColors.navigationText,
            fontWeight: FontWeight.bold,
          ),
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
              helperText: _selectedVaccine != null ? 'Auto-calculated based on vaccine frequency' : null,
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
        child: const Center(
          child: Text(
            AppStrings.deleteVaccine,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.deleteVaccineConfirmTitle),
        content: const Text(AppStrings.deleteVaccineConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _deleteVaccine();
            },
            child: Text(
              AppStrings.delete,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVaccine() async {
    if (widget.pet == null || widget.vaccineToEdit == null) {
      return;
    }

    try {
      await sl<PetRepository>().deleteVaccine(widget.pet!.id, widget.vaccineToEdit!.id);
      if (mounted) {
        context.read<PetListBloc>().add(const LoadPetList());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.vaccineDeletedSuccessfully),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
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
    }
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.vaccineName,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _errors['vaccineName'] != null ? AppColors.error : AppColors.border,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<VaccineMasterData>(
              isExpanded: true,
              value: _selectedVaccine,
              hint: Text(
                AppStrings.selectVaccine,
                style: AppTextStyles.regularStyle400(fontSize: 16, fontColor: AppColors.textSecondary),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: BorderRadius.circular(14),
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
              items: _availableVaccines.map((vaccine) {
                return DropdownMenuItem<VaccineMasterData>(
                  value: vaccine,
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
                              vaccine.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              vaccine.helperText,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _onVaccineSelected,
            ),
          ),
        ),
        if (_errors['vaccineName'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _errors['vaccineName']!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
        if (_selectedVaccine != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _selectedVaccine!.why,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? selectedDate,
    required String? error,
    required VoidCallback onTap,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
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
                    selectedDate != null ? _formatDate(selectedDate) : 'Select date',
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedDate != null ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20),
              ],
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              error,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
        if (helperText != null && error == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              helperText,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.notes,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
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
              hintStyle: AppTextStyles.regularStyle400(fontSize: 16, fontColor: AppColors.textSecondary),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.reminderNotification,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  AppStrings.getNotifiedBeforeNextDose,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _setReminder,
            onChanged: (value) => setState(() => _setReminder = value),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
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
    final date = await showDatePicker(
      context: context,
      initialDate: _nextDueDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
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
