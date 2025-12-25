import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/services/storage_service.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/ui/widgets/common_text_field.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';
import 'package:paw_around/utils/utils.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  String? _localImagePath;
  String? _currentPhotoUrl;
  String? _originalEmail;
  bool _isSaving = false;
  bool _isImageLoading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(
      text: (user?.displayName).orDefault(''),
    );
    _emailController = TextEditingController(
      text: (user?.email).orDefault(''),
    );
    _originalEmail = user?.email;
    _currentPhotoUrl = user?.photoURL;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    _showImagePickerOptions();
  }

  void _showImagePickerOptions() {
    final hasImage = _localImagePath != null || _currentPhotoUrl != null;

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
                  _selectImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _selectImage(ImageSource.gallery);
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
                    setState(() {
                      _localImagePath = null;
                      _currentPhotoUrl = null;
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

  Future<void> _selectImage(ImageSource source) async {
    setState(() => _isImageLoading = true);

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
          _localImagePath = pickedFile.path;
        });
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
    } finally {
      if (mounted) {
        setState(() => _isImageLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      String? photoUrl = _currentPhotoUrl;

      // Upload new image if selected
      if (_localImagePath != null) {
        final storageService = sl<StorageService>();
        photoUrl = await storageService.uploadProfileImage(
          localPath: _localImagePath!,
          userId: user.uid,
        );

        if (photoUrl == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload image. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
          setState(() => _isSaving = false);
          return;
        }
      }

      // Update Firebase Auth profile
      await user.updateDisplayName(_nameController.text.trim());
      if (photoUrl != null || _localImagePath != null || _currentPhotoUrl == null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Update email if changed
      final newEmail = _emailController.text.trim();
      final emailChanged = newEmail.isNotEmpty && newEmail != _originalEmail;

      if (emailChanged) {
        await user.verifyBeforeUpdateEmail(newEmail);
      }

      // Reload user to get updated info
      await user.reload();

      if (mounted) {
        if (emailChanged) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.emailVerificationSent),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 5),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.profileUpdatedSuccessfully),
              backgroundColor: AppColors.success,
            ),
          );
        }
        context.pop();
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.editProfile,
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Photo Picker
                    _buildImagePicker(),
                    const SizedBox(height: 32),

                    // Display Name Field
                    CommonTextField(
                      controller: _nameController,
                      hintText: AppStrings.displayNameHint,
                      labelText: AppStrings.displayName,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    CommonTextField(
                      controller: _emailController,
                      hintText: AppStrings.emailHint,
                      labelText: AppStrings.emailAddress,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Please enter a valid email';
                          }
                        }
                        return null;
                      },
                    ),
                    if (_emailController.text.isNotEmpty && _emailController.text != _originalEmail) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: AppColors.warning),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                AppStrings.emailChangeNote,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Read-only phone info (if available)
                    if (user?.phoneNumber != null) ...[
                      _buildReadOnlyField(
                        label: 'Phone',
                        value: user!.phoneNumber!,
                        icon: Icons.phone_outlined,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Phone number cannot be changed here',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),

                    // Save Button
                    CommonButton(
                      text: AppStrings.updateProfile,
                      onPressed: _isSaving ? null : _saveProfile,
                      isLoading: _isSaving,
                      variant: ButtonVariant.primary,
                    ),
                  ],
                ),
              ),
            ),

            // Loading overlay
            if (_isSaving)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    final hasImage = _localImagePath != null || _currentPhotoUrl != null;

    return ScaleButton(
      onPressed: _isImageLoading ? null : _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
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
                    color: _isImageLoading ? AppColors.primary : AppColors.border,
                    width: _isImageLoading ? 3 : 2,
                  ),
                  image: hasImage && !_isImageLoading
                      ? DecorationImage(
                          image: _localImagePath != null
                              ? FileImage(File(_localImagePath!))
                              : NetworkImage(_currentPhotoUrl!) as ImageProvider,
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _isImageLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3,
                        ),
                      )
                    : hasImage
                        ? null
                        : const Icon(
                            Icons.person,
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
                  opacity: _isImageLoading ? 0.5 : 1.0,
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

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.lock_outline,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
            size: 18,
          ),
        ],
      ),
    );
  }
}
