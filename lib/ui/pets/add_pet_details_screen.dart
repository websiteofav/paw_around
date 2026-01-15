import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/repositories/pet_repository.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/services/storage_service.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/ui/widgets/common_form_field.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

class AddPetDetailsScreen extends StatelessWidget {
  final PetModel pet;

  const AddPetDetailsScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return _AddPetDetailsView(pet: pet);
  }
}

class _AddPetDetailsView extends StatefulWidget {
  final PetModel pet;

  const _AddPetDetailsView({required this.pet});

  @override
  State<_AddPetDetailsView> createState() => _AddPetDetailsViewState();
}

class _AddPetDetailsViewState extends State<_AddPetDetailsView> {
  late TextEditingController _breedController;
  String? _selectedGender;
  String? _imagePath;
  bool _isImageLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _breedController = TextEditingController(text: widget.pet.breed);
    _selectedGender = widget.pet.gender.isNotEmpty ? widget.pet.gender : null;
    _imagePath = widget.pet.imagePath;
  }

  @override
  void dispose() {
    _breedController.dispose();
    super.dispose();
  }

  Future<void> _saveDetails() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final storageService = sl<StorageService>();
      String? finalImagePath = _imagePath;

      // Upload image if it's a new local file
      if (_imagePath != null &&
          _imagePath != widget.pet.imagePath &&
          !_imagePath!.startsWith('http')) {
        finalImagePath = await storageService.uploadPetImage(
          localPath: _imagePath!,
          petId: widget.pet.id,
        );
        if (finalImagePath == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to upload pet image'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          setState(() {
            _isSaving = false;
          });
          return;
        }
      }

      // Update pet with optional details
      final updatedPet = widget.pet.copyWith(
        breed: _breedController.text.trim(),
        gender: _selectedGender ?? '',
        imagePath: finalImagePath ?? widget.pet.imagePath,
        updatedAt: DateTime.now(),
      );

      final petRepository = sl<PetRepository>();
      await petRepository.updatePet(updatedPet);

      if (mounted) {
        HapticFeedback.mediumImpact();
        context.read<PetListBloc>().add(const LoadPetList());
        context.goNamed(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save details: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _skipForNow() {
    HapticFeedback.mediumImpact();
    context.goNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppStrings.addMoreDetailsOptional,
          style:
              AppTextStyles.boldStyle700(fontColor: AppColors.navigationText),
        ),
        backgroundColor: AppColors.navigationBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              Center(
                child: Text(
                  AppStrings.step2Of2Optional,
                  style: AppTextStyles.regularStyle400(
                    fontSize: 12,
                    fontColor: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Center(
                child: Text(
                  AppStrings.addMoreDetailsSubtitle,
                  style: AppTextStyles.regularStyle400(
                    fontSize: 14,
                    fontColor: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),

              // Image Picker
              _buildImagePicker(),
              const SizedBox(height: 24),

              // Breed Field (Optional)
              CommonFormField(
                label: AppStrings.breed,
                hintText: 'e.g., Golden Retriever, Tabby',
                controller: _breedController,
                isRequired: false,
                enabled: !_isSaving,
              ),
              const SizedBox(height: 16),

              // Gender Selection (Optional)
              _buildGenderSection(),
              const SizedBox(height: 32),

              // Primary CTA: Save details
              CommonButton(
                text: AppStrings.saveDetails,
                onPressed: _isSaving ? null : _saveDetails,
                isLoading: _isSaving,
                size: ButtonSize.medium,
              ),
              const SizedBox(height: 12),

              // Secondary CTA: Skip for now
              CommonButton(
                text: AppStrings.skipForNow,
                onPressed: _isSaving ? null : _skipForNow,
                variant: ButtonVariant.outline,
                size: ButtonSize.medium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.genderOptional,
          style: AppTextStyles.mediumStyle500(
              fontSize: 14, fontColor: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGenderButton(
                  AppStrings.male, _selectedGender == AppStrings.male),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderButton(
                  AppStrings.female, _selectedGender == AppStrings.female),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderButton(String gender, bool isSelected) {
    return ScaleButton(
      onPressed: () {
        setState(() {
          _selectedGender = isSelected ? null : gender;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          gender,
          textAlign: TextAlign.center,
          style: isSelected
              ? AppTextStyles.mediumStyle500(
                  fontSize: 16, fontColor: AppColors.primary)
              : AppTextStyles.regularStyle400(
                  fontSize: 16, fontColor: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    final hasImage = _imagePath != null && _imagePath!.isNotEmpty;
    final isLoading = _isImageLoading;

    return ScaleButton(
      onPressed:
          isLoading ? null : () => _showImagePickerOptions(hasImage: hasImage),
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
                          image: _imagePath!.startsWith('http')
                              ? NetworkImage(_imagePath!) as ImageProvider
                              : FileImage(File(_imagePath!)),
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

  void _showImagePickerOptions({bool hasImage = false}) {
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
                leading:
                    const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (hasImage) ...[
                const Divider(),
                ListTile(
                  leading:
                      const Icon(Icons.delete_outline, color: AppColors.error),
                  title: Text(
                    'Remove photo',
                    style: AppTextStyles.regularStyle400(
                        fontColor: AppColors.error),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    setState(() {
                      _imagePath = null;
                    });
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
    setState(() {
      _isImageLoading = true;
    });

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _imagePath = pickedFile.path;
          _isImageLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _isImageLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isImageLoading = false;
        });
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
