import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/pets/pets_bloc.dart';
import 'package:paw_around/bloc/pets/pets_event.dart';
import 'package:paw_around/bloc/pets/pets_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/ui/pets/widgets/pet_photo_selection.dart';
import 'package:paw_around/ui/pets/widgets/species_dropdown.dart';
import 'package:paw_around/ui/pets/widgets/gender_selection.dart';
import 'package:paw_around/ui/pets/widgets/date_of_birth_field.dart';
import 'package:paw_around/ui/pets/widgets/pet_form_buttons.dart';
import 'package:paw_around/ui/pets/widgets/pet_vaccines_list.dart';
import 'package:paw_around/ui/widgets/common_form_field.dart';

class AddPetScreen extends StatelessWidget {
  final PetModel? petToEdit; // Optional pet for editing mode

  const AddPetScreen({super.key, this.petToEdit});

  @override
  Widget build(BuildContext context) {
    return _AddPetView(petToEdit: petToEdit);
  }
}

class _AddPetView extends StatefulWidget {
  final PetModel? petToEdit;

  const _AddPetView({this.petToEdit});

  @override
  State<_AddPetView> createState() => _AddPetViewState();
}

class _AddPetViewState extends State<_AddPetView> {
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _weightController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();

    // Pre-fill controllers with pet data if editing
    final pet = widget.petToEdit;
    _nameController = TextEditingController(text: pet?.name ?? '');
    _breedController = TextEditingController(text: pet?.breed ?? '');
    _weightController = TextEditingController(text: pet?.weight.toString() ?? '');
    _notesController = TextEditingController(text: pet?.notes ?? '');

    // Initialize form with pet data if editing
    if (pet != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<PetsBloc>().add(UpdatePetFormField(field: 'name', value: pet.name));
        context.read<PetsBloc>().add(UpdatePetFormField(field: 'breed', value: pet.breed));
        context.read<PetsBloc>().add(UpdatePetFormField(field: 'weight', value: pet.weight.toString()));
        context.read<PetsBloc>().add(UpdatePetFormField(field: 'notes', value: pet.notes));
        context.read<PetsBloc>().add(SelectPetSpecies(species: pet.species));
        context.read<PetsBloc>().add(SelectPetGender(gender: pet.gender));
        context.read<PetsBloc>().add(SelectPetDateOfBirth(date: pet.dateOfBirth));
        if (pet.imagePath != null) {
          context.read<PetsBloc>().add(SelectPetImage(imagePath: pet.imagePath));
        }
        // Add existing vaccines to form
        for (final vaccine in pet.vaccines) {
          context.read<PetsBloc>().add(AddVaccineToPetForm(vaccine: vaccine));
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

          // Handle back button/swipe gesture
          if (context.canPop()) {
            context.pop();
          } else {
            context.pushNamed(AppRoutes.home);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              widget.petToEdit != null ? 'Edit Pet' : AppStrings.addPet,
              style: const TextStyle(
                color: AppColors.navigationText,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppColors.navigationBackground,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.pushNamed(AppRoutes.home);
                }
              },
            ),
          ),
          body: BlocListener<PetsBloc, PetsState>(
            listener: (context, state) {
              if (state is PetAdded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(widget.petToEdit != null ? 'Pet updated successfully!' : AppStrings.petAddedSuccessfully),
                    backgroundColor: Colors.green,
                  ),
                );
                context.pushNamed(AppRoutes.home);
              } else if (state is PetUpdated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pet updated successfully!'),
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
                if (state is PetFormState) {
                  return _buildForm(context, state);
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ));
  }

  Widget _buildForm(BuildContext context, PetFormState formState) {
    // Sync controllers with BLoC state
    if (_nameController.text != formState.name) {
      _nameController.text = formState.name;
    }
    if (_breedController.text != formState.breed) {
      _breedController.text = formState.breed;
    }
    if (_weightController.text != formState.weight) {
      _weightController.text = formState.weight;
    }
    if (_notesController.text != formState.notes) {
      _notesController.text = formState.notes;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Pet Photo Section
          const PetPhotoSelection(),
          const SizedBox(height: 24),

          // Pet Name
          CommonFormField(
            label: AppStrings.petName,
            controller: _nameController,
            onChanged: (value) => context.read<PetsBloc>().add(
                  UpdatePetFormField(field: 'name', value: value),
                ),
            validator: (value) => formState.errors['name'],
          ),
          const SizedBox(height: 16),

          // Species Dropdown
          const SpeciesDropdown(),
          const SizedBox(height: 16),

          // Breed
          CommonFormField(
            label: AppStrings.breed,
            controller: _breedController,
            onChanged: (value) => context.read<PetsBloc>().add(
                  UpdatePetFormField(field: 'breed', value: value),
                ),
            validator: (value) => formState.errors['breed'],
          ),
          const SizedBox(height: 16),

          // Gender Selection
          const GenderSelection(),
          const SizedBox(height: 16),

          // Date of Birth
          const DateOfBirthField(),
          const SizedBox(height: 16),

          // Weight
          CommonFormField(
            label: AppStrings.weight,
            controller: _weightController,
            keyboardType: TextInputType.number,
            onChanged: (value) => context.read<PetsBloc>().add(
                  UpdatePetFormField(field: 'weight', value: value),
                ),
            validator: (value) => formState.errors['weight'],
          ),
          const SizedBox(height: 16),

          // Notes
          CommonFormField(
            label: AppStrings.notes,
            controller: _notesController,
            maxLines: 3,
            onChanged: (value) => context.read<PetsBloc>().add(
                  UpdatePetFormField(field: 'notes', value: value),
                ),
          ),
          const SizedBox(height: 24),

          // Vaccinations Section
          const PetVaccinesList(),
          const SizedBox(height: 32),

          // Action Buttons
          PetFormButtons(petToEdit: widget.petToEdit),
        ],
      ),
    );
  }
}
