import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paw_around/bloc/moments/pet_moments_bloc.dart';
import 'package:paw_around/bloc/moments/pet_moments_event.dart';
import 'package:paw_around/bloc/moments/pet_moments_state.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/moments/pet_moment_model.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/services/storage_service.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/ui/widgets/common_text_field.dart';

class CreateMomentScreen extends StatefulWidget {
  const CreateMomentScreen({super.key});

  @override
  State<CreateMomentScreen> createState() => _CreateMomentScreenState();
}

class _CreateMomentScreenState extends State<CreateMomentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _captionController = TextEditingController();

  String? _imagePath;
  PetModel? _selectedPet;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Load pets
    context.read<PetListBloc>().add(const LoadPetList());
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _showImagePickerOptions() {
    final hasImage = _imagePath != null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: Text(
                  AppStrings.takePhoto,
                  style: AppTextStyles.regularStyle400(
                      fontColor: AppColors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: AppColors.primary),
                title: Text(
                  AppStrings.chooseFromGallery,
                  style: AppTextStyles.regularStyle400(
                      fontColor: AppColors.textPrimary),
                ),
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
                    AppStrings.removePhoto,
                    style: AppTextStyles.regularStyle400(
                        fontColor: AppColors.error),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    setState(() => _imagePath = null);
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
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (image != null && mounted) {
      setState(() => _imagePath = image.path);
    }
  }

  Future<void> _submitMoment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.pleaseSelectImage),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (_selectedPet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.pleaseSelectPet),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final currentUser = sl<AuthRepository>().currentUser;
    if (currentUser == null) {
      setState(() => _isSubmitting = false);
      return;
    }

    // Upload image to Firebase Storage
    final storageService = sl<StorageService>();
    final imageUrl = await storageService.uploadMomentImage(
      localPath: _imagePath!,
      userId: currentUser.uid,
    );

    if (imageUrl == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.failedToUploadImage),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    final moment = PetMoment(
      id: '',
      petId: _selectedPet!.id,
      petName: _selectedPet!.name,
      imageUrl: imageUrl ?? '',
      caption: _captionController.text.trim(),
      userId: currentUser.uid,
      userName: currentUser.displayName ?? 'Anonymous',
      createdAt: DateTime.now(),
    );

    if (mounted) {
      context.read<PetMomentsBloc>().add(CreateMoment(moment));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PetMomentsBloc, PetMomentsState>(
      listener: (context, state) {
        if (state is MomentCreated) {
          setState(() => _isSubmitting = false);
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.momentPosted),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        } else if (state is PetMomentsError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            AppStrings.createMoment,
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
        body: BlocBuilder<PetListBloc, PetListState>(
          builder: (context, petListState) {
            List<PetModel> pets = [];
            if (petListState is PetListLoaded) {
              pets = petListState.pets;
              // Auto-select first pet if only one
              if (pets.length == 1 && _selectedPet == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() => _selectedPet = pets.first);
                });
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image picker
                    _buildImagePicker(),
                    const SizedBox(height: 24),

                    // Pet selector (only if multiple pets)
                    if (pets.length > 1) ...[
                      _buildPetSelector(pets),
                      const SizedBox(height: 16),
                    ],

                    // Caption field
                    CommonTextField(
                      controller: _captionController,
                      labelText: AppStrings.addCaption,
                      hintText: AppStrings.momentCaptionHint,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.pleaseEnterCaption;
                        }
                        if (value.length > 200) {
                          return 'Caption must be 200 characters or less';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    CommonButton(
                      text: _isSubmitting
                          ? AppStrings.postingMoment
                          : AppStrings.postMoment,
                      onPressed: _isSubmitting ? null : _submitMoment,
                      variant: ButtonVariant.primary,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _showImagePickerOptions,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: _imagePath == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 64,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.selectImageForMoment,
                    style: AppTextStyles.regularStyle400(
                      fontSize: 14,
                      fontColor: AppColors.textSecondary,
                    ),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.file(
                      File(_imagePath!),
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: AppColors.white),
                          onPressed: () {
                            setState(() => _imagePath = null);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPetSelector(List<PetModel> pets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.selectPet,
          style: AppTextStyles.semiBoldStyle600(
            fontSize: 14,
            fontColor: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonFormField<PetModel>(
            initialValue: _selectedPet,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            hint: Text(
              AppStrings.selectPet,
              style: AppTextStyles.regularStyle400(
                fontSize: 14,
                fontColor: AppColors.textLight,
              ),
            ),
            items: pets.map((pet) {
              return DropdownMenuItem<PetModel>(
                value: pet,
                child: Text(
                  pet.name,
                  style: AppTextStyles.regularStyle400(
                    fontSize: 14,
                    fontColor: AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: (pet) {
              setState(() => _selectedPet = pet);
            },
            validator: (value) {
              if (value == null) {
                return AppStrings.pleaseSelectPet;
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
