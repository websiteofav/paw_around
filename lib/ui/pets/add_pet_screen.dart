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
import 'package:paw_around/ui/widgets/scale_button.dart';

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
        appBar: AppBar(
          title: Text(
            widget.petToEdit != null ? 'Edit Pet' : AppStrings.addYourPet,
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Image Picker (Optional)
                _buildImagePicker(context, formState),
                const SizedBox(height: 24),

                // Pet Name Field
                CommonFormField(
                  label: AppStrings.petName,
                  hintText: AppStrings.petNameHint,
                  controller: _nameController,
                  isRequired: true,
                  onChanged: (value) {
                    context.read<PetFormBloc>().add(UpdateName(value));
                  },
                  errorText: formState.errors['name'],
                ),
                const SizedBox(height: 16),

                // Pet Type Selector
                const PetTypeSelector(),
                const SizedBox(height: 16),

                // Birthdate OR Age
                const BirthdateAgeSelector(),
                const SizedBox(height: 16),

                // Gender Selection (Required)
                _buildGenderSection(context, formState),
                const SizedBox(height: 32),

                // Save Button
                CommonButton(
                  text: AppStrings.saveAndContinue,
                  onPressed: formState.status == PetFormStatus.saving
                      ? null
                      : () {
                          context.read<PetFormBloc>().add(SubmitForm(petToEdit: widget.petToEdit));
                        },
                  isLoading: formState.status == PetFormStatus.saving,
                  size: ButtonSize.medium,
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

  Widget _buildGenderSection(BuildContext context, PetFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              AppStrings.gender,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.error,
              ),
            ),
          ],
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
        // Error message
        if (state.errors['gender'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              state.errors['gender']!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGenderButton(BuildContext context, String gender, bool isSelected) {
    return ScaleButton(
      onPressed: () => context.read<PetFormBloc>().add(SelectGender(gender)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
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
    final isLoading = state.isImageLoading;

    return ScaleButton(
      onPressed: isLoading ? null : () => _showImagePickerOptions(context, hasImage: hasImage),
      child: Container(
        height: 160,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Center(
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.iconBgLight,
                  borderRadius: BorderRadius.circular(70),
                  border: Border.all(
                    color: isLoading ? AppColors.primary : AppColors.border,
                    width: isLoading ? 3 : 2,
                  ),
                  image: hasImage && !isLoading
                      ? DecorationImage(
                          image: state.imagePath!.startsWith('http')
                              ? NetworkImage(state.imagePath!) as ImageProvider
                              : FileImage(File(state.imagePath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3,
                        ),
                      )
                    : hasImage
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
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLoading ? 0.5 : 1.0,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context, {bool hasImage = false}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (hasImage) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppColors.error),
                  title: const Text(
                    'Remove photo',
                    style: TextStyle(color: AppColors.error),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.read<PetFormBloc>().add(const SelectImage(null));
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    // Show loading state
    context.read<PetFormBloc>().add(const SetImageLoading(true));

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
      } else if (mounted) {
        // User cancelled, hide loading
        context.read<PetFormBloc>().add(const SetImageLoading(false));
      }
    } catch (e) {
      if (mounted) {
        context.read<PetFormBloc>().add(const SetImageLoading(false));
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
