import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_bloc.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_event.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_state.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

class PetFormButtons extends StatelessWidget {
  final PetModel? petToEdit;

  const PetFormButtons({super.key, this.petToEdit});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PetFormBloc, PetFormState>(
      builder: (context, state) {
        return Row(
          children: [
            // Show Delete button when editing, Cancel when adding
            Expanded(
              child: CommonButton(
                text: petToEdit != null ? 'Delete Pet' : AppStrings.cancel,
                onPressed: petToEdit != null ? () => _deletePet(context) : () => context.pushNamed(AppRoutes.home),
                variant: petToEdit != null ? ButtonVariant.danger : ButtonVariant.outline,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CommonButton(
                text: AppStrings.savePet,
                onPressed: state.status == PetFormStatus.saving ? null : () => _savePet(context),
                variant: ButtonVariant.primary,
              ),
            ),
          ],
        );
      },
    );
  }

  void _savePet(BuildContext context) {
    context.read<PetFormBloc>().add(SubmitForm(petToEdit: petToEdit));
  }

  void _deletePet(BuildContext context) {
    if (petToEdit == null) {
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Pet'),
          content: Text('Are you sure you want to delete ${petToEdit!.name}? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _confirmDelete(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    if (petToEdit == null) {
      return;
    }

    // Delete pet using PetListBloc
    context.read<PetListBloc>().add(DeletePet(petId: petToEdit!.id));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${petToEdit!.name} has been deleted'),
        backgroundColor: Colors.green,
      ),
    );

    context.pushNamed(AppRoutes.home);
  }
}
