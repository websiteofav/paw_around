import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_bloc.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_event.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_state.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
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
  final PetModel? petToEdit;

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
    // Form initialization is handled by the router via InitializeForm event
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
        if (didPop) {
          return;
        }

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
        body: BlocListener<PetFormBloc, PetFormState>(
          listener: (context, state) {
            if (state.status == PetFormStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    widget.petToEdit != null ? 'Pet updated successfully!' : AppStrings.petAddedSuccessfully,
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              // Refresh pet list in parent bloc
              context.read<PetListBloc>().add(const LoadPetList());
              context.pushNamed(AppRoutes.home);
            } else if (state.status == PetFormStatus.error && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<PetFormBloc, PetFormState>(
            builder: (context, state) {
              return _buildForm(context, state);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, PetFormState formState) {
    // Sync controllers with BLoC state only if they differ
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

    return Stack(
      children: [
        SingleChildScrollView(
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
                onChanged: (value) => context.read<PetFormBloc>().add(UpdateName(value)),
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
                onChanged: (value) => context.read<PetFormBloc>().add(UpdateBreed(value)),
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
                onChanged: (value) => context.read<PetFormBloc>().add(UpdateWeight(value)),
                validator: (value) => formState.errors['weight'],
              ),
              const SizedBox(height: 16),

              // Notes
              CommonFormField(
                label: AppStrings.notes,
                controller: _notesController,
                maxLines: 3,
                onChanged: (value) => context.read<PetFormBloc>().add(UpdateNotes(value)),
              ),
              const SizedBox(height: 24),

              // Vaccinations Section
              const PetVaccinesList(),
              const SizedBox(height: 32),

              // Action Buttons
              PetFormButtons(petToEdit: widget.petToEdit),
            ],
          ),
        ),
        // Loading overlay
        if (formState.status == PetFormStatus.saving)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
