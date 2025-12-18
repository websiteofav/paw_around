import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_bloc.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_event.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_state.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/ui/pets/widgets/pet_type_selector.dart';
import 'package:paw_around/ui/pets/widgets/birthdate_age_selector.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
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

  @override
  void initState() {
    super.initState();
    final pet = widget.petToEdit;
    _nameController = TextEditingController(text: pet?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
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
        body: BlocListener<PetFormBloc, PetFormState>(
          listener: (context, state) {
            if (state.status == PetFormStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    widget.petToEdit != null ? 'Pet updated successfully!' : AppStrings.petAddedSuccessfully,
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
              context.read<PetListBloc>().add(const LoadPetList());
              context.pushNamed(AppRoutes.home);
            } else if (state.status == PetFormStatus.error && state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
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
    if (_nameController.text != formState.name) {
      _nameController.text = formState.name;
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Image Picker (Optional)
                        _buildImagePicker(context, formState),

                        // Form Card
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Pet Name Field
                              CommonFormField(
                                label: AppStrings.petName,
                                hintText: "Pet's name",
                                controller: _nameController,
                                onChanged: (value) {
                                  context.read<PetFormBloc>().add(UpdateName(value));
                                },
                                validator: (value) => formState.errors['name'],
                              ),
                              const SizedBox(height: 20),

                              // Pet Type Selector
                              const PetTypeSelector(),
                              const SizedBox(height: 20),

                              // Birthdate OR Age
                              const BirthdateAgeSelector(),
                              const SizedBox(height: 20),

                              // Gender Selection (Required)
                              _buildGenderSection(context, formState),
                              const SizedBox(height: 24),

                              // Save Button
                              CommonButton(
                                text: AppStrings.saveAndContinue,
                                onPressed: formState.status == PetFormStatus.saving
                                    ? null
                                    : () {
                                        context.read<PetFormBloc>().add(const SubmitForm());
                                      },
                                isLoading: formState.status == PetFormStatus.saving,
                                size: ButtonSize.medium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading overlay
          if (formState.status == PetFormStatus.saving)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Paw icon
          const Icon(
            Icons.chevron_left,
            color: AppColors.textPrimary,
            size: 28,
          ),
          const Spacer(),
          // Title
          Text(
            widget.petToEdit != null ? 'Edit Pet' : AppStrings.addYourPet,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          // Close button placeholder (for balance)
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildGenderSection(BuildContext context, PetFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.gender,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGenderButton(
                context,
                AppStrings.male,
                state.gender == AppStrings.male,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderButton(
                context,
                AppStrings.female,
                state.gender == AppStrings.female,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderButton(BuildContext context, String gender, bool isSelected) {
    return GestureDetector(
      onTap: () => context.read<PetFormBloc>().add(SelectGender(gender)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          gender,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context, PetFormState state) {
    final hasImage = state.imagePath != null && state.imagePath!.isNotEmpty;

    return GestureDetector(
      onTap: () => _showImagePickerOptions(context),
      child: Container(
        height: 160,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Center(
          child: Stack(
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.iconBgLight,
                  borderRadius: BorderRadius.circular(70),
                  border: Border.all(
                    color: AppColors.border,
                    width: 2,
                  ),
                  image: hasImage
                      ? DecorationImage(
                          image: state.imagePath!.startsWith('http')
                              ? NetworkImage(state.imagePath!) as ImageProvider
                              : FileImage(File(state.imagePath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: hasImage
                    ? null
                    : const Icon(
                        Icons.pets,
                        size: 64,
                        color: AppColors.primary,
                      ),
              ),
              // Camera icon overlay
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.surface,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        context.read<PetFormBloc>().add(SelectImage(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
