import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/pets/pets_bloc.dart';
import 'package:paw_around/bloc/pets/pets_event.dart';
import 'package:paw_around/bloc/pets/pets_state.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/repositories/vaccine_repository.dart';

class VaccineFormButtons extends StatelessWidget {
  const VaccineFormButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PetsBloc, PetsState>(
      builder: (context, state) {
        if (state is VaccineFormState) {
          return Column(
            children: [
              // Save Vaccine Button
              CommonButton(
                text: AppStrings.saveVaccine,
                onPressed: state.isValid ? () => _saveVaccine(context, state) : null,
                variant: ButtonVariant.primary,
              ),
              const SizedBox(height: 16),

              // Cancel Button
              CommonButton(
                text: AppStrings.cancel,
                onPressed: () => context.pop(),
                variant: ButtonVariant.outline,
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _saveVaccine(BuildContext context, VaccineFormState formState) async {
    context.read<PetsBloc>().add(const ValidateVaccineForm());

    if (formState.isValid) {
      final vaccine = VaccineModel.create(
        vaccineName: formState.vaccineName,
        dateGiven: formState.dateGiven!,
        nextDueDate: formState.nextDueDate!,
        notes: formState.notes,
        setReminder: formState.setReminder,
      );

      try {
        // Save vaccine to master list (persistent storage)
        final vaccineRepository = sl<VaccineRepository>();
        await vaccineRepository.addVaccine(vaccine);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.vaccineAddedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );

        // Return vaccine data to the calling screen
        Navigator.of(context).pop(vaccine);
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving vaccine: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
