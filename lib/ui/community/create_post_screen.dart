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
import 'package:paw_around/services/location_service.dart';

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

  void _submitPost() {
    if (!_formKey.currentState!.validate()) return;
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set a location')),
      );
      return;
    }

    final post = LostFoundPost(
      id: '',
      type: _postType,
      petName: _petNameController.text.trim(),
      breed: _breedController.text.trim(),
      color: _colorController.text.trim(),
      petDescription: _descriptionController.text.trim(),
      imagePath: _imagePath,
      latitude: _latitude!,
      longitude: _longitude!,
      locationName: _locationController.text.trim(),
      contactPhone: _phoneController.text.trim(),
      userId: 'current_user', // TODO: Replace with actual user ID
      createdAt: DateTime.now(),
    );

    context.read<CommunityBloc>().add(CreatePost(post));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommunityBloc, CommunityState>(
      listener: (context, state) {
        if (state is PostCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.postCreatedSuccessfully)),
          );
          context.pop();
        } else if (state is CommunityError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.createPost, style: AppTextStyles.appBarTitle),
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
                _buildTextField(_petNameController, AppStrings.petName, true),
                const SizedBox(height: 12),
                _buildTextField(_breedController, AppStrings.breed, true),
                const SizedBox(height: 12),
                _buildTextField(_colorController, AppStrings.color, true),
                const SizedBox(height: 12),
                _buildTextField(_descriptionController, AppStrings.petDescription, true, maxLines: 3),
                const SizedBox(height: 12),
                _buildLocationField(),
                const SizedBox(height: 12),
                _buildTextField(_phoneController, AppStrings.contactPhone, true, keyboardType: TextInputType.phone),
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
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, size: 40, color: AppColors.textSecondary),
                  SizedBox(height: 8),
                  Text(AppStrings.addPhoto, style: AppTextStyles.cardSubtitle),
                ],
              ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    bool required, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: required ? (value) => value == null || value.isEmpty ? 'Required' : null : null,
    );
  }

  Widget _buildLocationField() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: AppStrings.location,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _isLoadingLocation ? null : _getCurrentLocation,
          icon: _isLoadingLocation
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.my_location, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<CommunityBloc, CommunityState>(
      builder: (context, state) {
        final isLoading = state is PostCreating;
        return ElevatedButton(
          onPressed: isLoading ? null : _submitPost,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(AppStrings.createPost, style: TextStyle(fontSize: 16, color: Colors.white)),
        );
      },
    );
  }
}
