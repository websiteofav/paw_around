import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
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
      final lat = result.position!.latitude;
      final lng = result.position!.longitude;

      // Reverse geocode to get readable address
      String locationName = '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
      try {
        final placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          // Format: "Neighborhood, City" or "Street, City"
          final parts = <String>[];
          if (place.subLocality?.isNotEmpty == true) {
            parts.add(place.subLocality!);
          } else if (place.street?.isNotEmpty == true) {
            parts.add(place.street!);
          }
          if (place.locality?.isNotEmpty == true) {
            parts.add(place.locality!);
          }
          if (parts.isNotEmpty) {
            locationName = parts.join(', ');
          }
        }
      } catch (e) {
        // Fallback to coordinates if geocoding fails
      }

      setState(() {
        _latitude = lat;
        _longitude = lng;
        _locationController.text = locationName;
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
          title: const Text(
            AppStrings.createPost,
            style: TextStyle(
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Post Type Toggle
                _buildTypeToggle(),
                const SizedBox(height: 24),

                // Pet Photo
                _buildImagePicker(),
                const SizedBox(height: 28),

                // Pet Details Section
                _buildSectionHeader('PET DETAILS', icon: Icons.pets),
                CommonTextField(
                  controller: _petNameController,
                  hintText: AppStrings.petName,
                  labelText: AppStrings.petName,
                  validator: (value) => Validators.required(value, AppStrings.petName),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CommonTextField(
                  controller: _breedController,
                  hintText: AppStrings.breed,
                  labelText: AppStrings.breed,
                  validator: (value) => Validators.required(value, AppStrings.breed),
                ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CommonTextField(
                  controller: _colorController,
                  hintText: AppStrings.color,
                  labelText: AppStrings.color,
                  validator: (value) => Validators.required(value, AppStrings.color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                CommonTextField(
                  controller: _descriptionController,
                  hintText: AppStrings.describeThePet,
                  labelText: AppStrings.petDescription,
                  maxLines: 3,
                  validator: (value) => Validators.required(value, AppStrings.petDescription),
                ),
                const SizedBox(height: 24),

                // Location Section
                _buildSectionHeader('LOCATION', icon: Icons.location_on_outlined),
                _buildLocationField(),
                const SizedBox(height: 24),

                // Contact Section
                _buildSectionHeader('CONTACT', icon: Icons.phone_outlined),
                CommonTextField(
                  controller: _phoneController,
                  hintText: AppStrings.enterContactPhone,
                  labelText: AppStrings.contactPhone,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                const SizedBox(height: 32),

                // Submit Button
                _buildSubmitButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
      children: [
        Expanded(
            child: _buildTypeButton(PostType.lost, AppStrings.lost, Icons.search, AppColors.error),
        ),
        Expanded(
            child: _buildTypeButton(PostType.found, AppStrings.found, Icons.favorite, AppColors.success),
        ),
      ],
      ),
    );
  }

  Widget _buildTypeButton(PostType type, String label, IconData icon, Color color) {
    final isSelected = _postType == type;
    return GestureDetector(
      onTap: () => setState(() => _postType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: isSelected ? Colors.white : color),
            const SizedBox(width: 8),
            Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector(
      onTap: _pickImage,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
        decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.iconBgLight,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
        ),
        child: _imagePath != null
                      ? ClipOval(
                          child: Image.file(
                            File(_imagePath!),
                            fit: BoxFit.fill,
                            width: 120,
                            height: 120,
                          ),
              )
                      : Icon(
                          Icons.pets,
                          size: 48,
                          color: AppColors.primary.withValues(alpha: 0.6),
                        ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _imagePath != null ? 'Tap to change photo' : AppStrings.addPhoto,
              style: AppTextStyles.regularStyle400(
                fontSize: 13,
                fontColor: AppColors.textSecondary,
              ),
            ),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField() {
    final hasLocation = _latitude != null && _longitude != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonTextField(
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
        ),
        if (hasLocation) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                const SizedBox(width: 6),
                Text(
                  'Location set',
                  style: AppTextStyles.semiBoldStyle600(fontSize: 12, fontColor: AppColors.success),
                ),
              ],
            ),
          ),
        ],
      ],
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
