import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/ui/widgets/common_form_field.dart';

class AddVaccineScreen extends StatefulWidget {
  const AddVaccineScreen({super.key});

  @override
  State<AddVaccineScreen> createState() => _AddVaccineScreenState();
}

class _AddVaccineScreenState extends State<AddVaccineScreen> {
  final TextEditingController _vaccineNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _dateGiven;
  DateTime? _nextDueDate;
  bool _setReminder = true;

  final Map<String, String> _errors = {};

  @override
  void dispose() {
    _vaccineNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool _validate() {
    _errors.clear();

    if (_vaccineNameController.text.isEmpty) {
      _errors['vaccineName'] = 'Please enter vaccine name';
    }
    if (_dateGiven == null) {
      _errors['dateGiven'] = 'Please select date given';
    }
    if (_nextDueDate == null) {
      _errors['nextDueDate'] = 'Please select next due date';
    }

    setState(() {});
    return _errors.isEmpty;
  }

  void _saveVaccine() {
    if (!_validate()) {
      return;
    }

    final vaccine = VaccineModel.create(
      vaccineName: _vaccineNameController.text,
      dateGiven: _dateGiven!,
      nextDueDate: _nextDueDate!,
      notes: _notesController.text,
      setReminder: _setReminder,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.vaccineAddedSuccessfully),
        backgroundColor: Colors.green,
      ),
    );

    // Return the vaccine to the parent screen
    context.pop(vaccine);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.addVaccine,
          style: TextStyle(
            color: AppColors.navigationText,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.navigationBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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

            // Vaccine Name
            CommonFormField(
              label: AppStrings.vaccineName,
              controller: _vaccineNameController,
              onChanged: (_) => setState(() => _errors.remove('vaccineName')),
              validator: (value) => _errors['vaccineName'],
            ),
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
            ),
            const SizedBox(height: 16),

            // Notes
            CommonFormField(
              label: AppStrings.notes,
              controller: _notesController,
              hintText: 'Optional',
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Reminder Toggle
            _buildReminderSection(),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CommonButton(
                    text: AppStrings.cancel,
                    onPressed: () => context.pop(),
                    variant: ButtonVariant.outline,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CommonButton(
                    text: AppStrings.saveVaccine,
                    onPressed: _saveVaccine,
                    variant: ButtonVariant.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
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
        Icons.medical_services,
        size: 40,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? selectedDate,
    required String? error,
    required VoidCallback onTap,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: error != null ? Colors.red : const Color(0xFFE0E0E0),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate != null ? _formatDate(selectedDate) : 'Select Date',
                    style: TextStyle(
                      color: selectedDate != null ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today, color: AppColors.primary),
              ],
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              error,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildReminderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
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
              Icons.notifications_active,
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
                    fontWeight: FontWeight.w600,
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
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _dateGiven = date;
        _errors.remove('dateGiven');
      });
    }
  }

  Future<void> _selectNextDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (date != null) {
      setState(() {
        _nextDueDate = date;
        _errors.remove('nextDueDate');
      });
    }
  }
}
