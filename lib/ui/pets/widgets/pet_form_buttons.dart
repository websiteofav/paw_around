import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/pets/pets_bloc.dart';
import 'package:paw_around/bloc/pets/pets_event.dart';
import 'package:paw_around/bloc/pets/pets_state.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/services/image_service.dart';

class PetFormButtons extends StatelessWidget {
  final PetModel? petToEdit;

  const PetFormButtons({super.key, this.petToEdit});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PetsBloc, PetsState>(
      builder: (context, state) {
        if (state is PetFormState) {
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
                  onPressed: () => _savePet(context, state),
                  variant: ButtonVariant.primary,
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _savePet(BuildContext context, PetFormState formState) {
    // Always dispatch AddPet - let the bloc handle validation internally
    context.read<PetsBloc>().add(AddPet(petToEdit: petToEdit));
  }

  void _deletePet(BuildContext context) {
    if (petToEdit == null) return;

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context2) {
        return AlertDialog(
          title: const Text('Delete Pet'),
          content: Text('Are you sure you want to delete ${petToEdit!.name}? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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

  void _confirmDelete(BuildContext context) async {
    if (petToEdit == null) return;

    try {
      // Delete pet image if it exists
      if (petToEdit!.imagePath != null) {
        await ImageService.deletePetImage(petToEdit!.imagePath);
      }

      // Delete pet from database
      context.read<PetsBloc>().add(DeletePet(petId: petToEdit!.id));

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${petToEdit!.name} has been deleted'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to home
      context.pushNamed(AppRoutes.home);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting pet: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
