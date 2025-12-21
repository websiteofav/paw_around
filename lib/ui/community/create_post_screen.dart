import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paw_around/bloc/community/community_bloc.dart';
import 'package:paw_around/bloc/community/community_event.dart';
import 'package:paw_around/bloc/community/community_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/community/lost_found_post.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/services/location_service.dart';
import 'package:paw_around/services/storage_service.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/ui/widgets/common_text_field.dart';
import 'package:paw_around/utils/validators.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _petNameController = TextEditingController();
  final _breedController = TextEditingController();
  final _colorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  PostType _postType = PostType.lost;
  String? _imagePath;
  double? _latitude;
  double? _longitude;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _petNameController.dispose();
    _breedController.dispose();
    _colorController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imagePath = image.path);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    final locationService = sl<LocationService>();
    final result = await locationService.getCurrentLocation();

    if (result.isSuccess && result.position != null) {
      setState(() {
        _latitude = result.position!.latitude;
        _longitude = result.position!.longitude;
        _locationController.text = '${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}';
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.errorMessage ?? 'Failed to get location')),
        );
      }
    }
    setState(() => _isLoadingLocation = false);
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.pleaseSetLocation)),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final currentUser = sl<AuthRepository>().currentUser;
    String? imageUrl;

    // Upload image to Firebase Storage if selected
    if (_imagePath != null) {
      final storageService = sl<StorageService>();
      imageUrl = await storageService.uploadPostImage(
        localPath: _imagePath!,
        userId: currentUser?.uid ?? 'anonymous',
      );

      if (imageUrl == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image. Please try again.')),
        );
        setState(() => _isSubmitting = false);
        return;
      }
    }

    final post = LostFoundPost(
      id: '',
      type: _postType,
      petName: _petNameController.text.trim(),
      breed: _breedController.text.trim(),
      color: _colorController.text.trim(),
      petDescription: _descriptionController.text.trim(),
      imagePath: imageUrl,
      latitude: _latitude!,
      longitude: _longitude!,
      locationName: _locationController.text.trim(),
      contactPhone: _phoneController.text.trim(),
      userId: currentUser?.uid ?? '',
      userName: currentUser?.displayName ?? 'Anonymous',
      createdAt: DateTime.now(),
    );

    if (mounted) {
      context.read<CommunityBloc>().add(CreatePost(post));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommunityBloc, CommunityState>(
      listener: (context, state) {
        if (state is PostCreated) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.postCreatedSuccessfully)),
          );
          context.pop();
        } else if (state is CommunityError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(AppStrings.createPost,
              style: AppTextStyles.boldStyle700(fontSize: 18, fontColor: AppColors.navigationText)),
          backgroundColor: AppColors.navigationBackground,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTypeToggle(),
                const SizedBox(height: 16),
                _buildImagePicker(),
                const SizedBox(height: 16),
                CommonTextField(
                  controller: _petNameController,
                  hintText: AppStrings.petName,
                  labelText: AppStrings.petName,
                  validator: (value) => Validators.required(value, AppStrings.petName),
                ),
                const SizedBox(height: 12),
                CommonTextField(
                  controller: _breedController,
                  hintText: AppStrings.breed,
                  labelText: AppStrings.breed,
                  validator: (value) => Validators.required(value, AppStrings.breed),
                ),
                const SizedBox(height: 12),
                CommonTextField(
                  controller: _colorController,
                  hintText: AppStrings.color,
                  labelText: AppStrings.color,
                  validator: (value) => Validators.required(value, AppStrings.color),
                ),
                const SizedBox(height: 12),
                CommonTextField(
                  controller: _descriptionController,
                  hintText: AppStrings.describeThePet,
                  labelText: AppStrings.petDescription,
                  maxLines: 3,
                  validator: (value) => Validators.required(value, AppStrings.petDescription),
                ),
                const SizedBox(height: 12),
                _buildLocationField(),
                const SizedBox(height: 12),
                CommonTextField(
                  controller: _phoneController,
                  hintText: AppStrings.enterContactPhone,
                  labelText: AppStrings.contactPhone,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                const SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Row(
      children: [
        Expanded(
          child: _buildTypeButton(PostType.lost, AppStrings.lost, Colors.red),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTypeButton(PostType.found, AppStrings.found, Colors.green),
        ),
      ],
    );
  }

  Widget _buildTypeButton(PostType type, String label, Color color) {
    final isSelected = _postType == type;
    return GestureDetector(
      onTap: () => setState(() => _postType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.authInputBorder),
        ),
        child: _imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(_imagePath!), fit: BoxFit.cover, width: double.infinity),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo, size: 40, color: AppColors.textSecondary),
                  const SizedBox(height: 8),
                  Text(AppStrings.addPhoto,
                      style: AppTextStyles.regularStyle400(fontSize: 14, fontColor: AppColors.textSecondary)),
                ],
              ),
      ),
    );
  }

  Widget _buildLocationField() {
    return CommonTextField(
      controller: _locationController,
      hintText: AppStrings.useCurrentLocation,
      labelText: AppStrings.location,
      validator: (value) => Validators.required(value, AppStrings.location),
      suffixIcon: IconButton(
        onPressed: _isLoadingLocation ? null : _getCurrentLocation,
        icon: _isLoadingLocation
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.my_location, color: AppColors.primary),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<CommunityBloc, CommunityState>(
      builder: (context, state) {
        final isLoading = _isSubmitting || state is PostCreating;
        return CommonButton(
          text: AppStrings.createPost,
          onPressed: isLoading ? null : _submitPost,
          isLoading: isLoading,
          variant: ButtonVariant.primary,
        );
      },
    );
  }
}
