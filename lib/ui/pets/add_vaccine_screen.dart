import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/pets/pets_bloc.dart';
import 'package:paw_around/bloc/pets/pets_event.dart';
import 'package:paw_around/bloc/pets/pets_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/ui/pets/widgets/vaccine_date_field.dart';
import 'package:paw_around/ui/pets/widgets/vaccine_reminder_section.dart';
import 'package:paw_around/ui/pets/widgets/vaccine_form_buttons.dart';
import 'package:paw_around/ui/widgets/common_form_field.dart';

class AddVaccineScreen extends StatelessWidget {
  const AddVaccineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AddVaccineView();
  }
}

class _AddVaccineView extends StatefulWidget {
  const _AddVaccineView();

  @override
  State<_AddVaccineView> createState() => _AddVaccineViewState();
}

class _AddVaccineViewState extends State<_AddVaccineView> {
  late TextEditingController _vaccineNameController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _vaccineNameController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _vaccineNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.addVaccine,
          style: const TextStyle(
            color: AppColors.navigationText,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.navigationBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pushNamed(AppRoutes.home),
        ),
      ),
      body: BlocListener<PetsBloc, PetsState>(
        listener: (context, state) {
          if (state is VaccineAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppStrings.vaccineAddedSuccessfully),
                backgroundColor: Colors.green,
              ),
            );
            context.pushNamed(AppRoutes.home);
          } else if (state is PetsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<PetsBloc, PetsState>(
          builder: (context, state) {
            if (state is VaccineFormState) {
              return _buildForm(context, state);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, VaccineFormState formState) {
    // Sync controllers with BLoC state
    if (_vaccineNameController.text != formState.vaccineName) {
      _vaccineNameController.text = formState.vaccineName;
    }
    if (_notesController.text != formState.notes) {
      _notesController.text = formState.notes;
    }

    return SingleChildScrollView(
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
            onChanged: (value) => context.read<PetsBloc>().add(
                  UpdateVaccineFormField(field: 'vaccineName', value: value),
                ),
            validator: (value) => formState.errors['vaccineName'],
          ),
          const SizedBox(height: 16),

          // Date Given
          VaccineDateField(
            label: AppStrings.dateGiven,
            selectedDate: formState.dateGiven,
            onTap: () => _selectDateGiven(context),
          ),
          const SizedBox(height: 16),

          // Next Due Date
          VaccineDateField(
            label: AppStrings.nextDueDate,
            selectedDate: formState.nextDueDate,
            onTap: () => _selectNextDueDate(context),
          ),
          const SizedBox(height: 16),

          // Notes
          CommonFormField(
            label: AppStrings.notes,
            controller: _notesController,
            hintText: 'Optional',
            maxLines: 3,
            onChanged: (value) => context.read<PetsBloc>().add(
                  UpdateVaccineFormField(field: 'notes', value: value),
                ),
          ),
          const SizedBox(height: 24),

          // Reminder Notification
          const VaccineReminderSection(),
          const SizedBox(height: 32),

          // Action Buttons
          const VaccineFormButtons(),
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
        Icons.medical_services,
        size: 40,
        color: AppColors.primary,
      ),
    );
  }

  void _selectDateGiven(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      context.read<PetsBloc>().add(SelectVaccineDateGiven(date: date));
    }
  }

  void _selectNextDueDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (date != null) {
      context.read<PetsBloc>().add(SelectVaccineNextDueDate(date: date));
    }
  }
}
