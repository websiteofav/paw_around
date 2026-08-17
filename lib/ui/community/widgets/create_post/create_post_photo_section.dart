import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/info_banner.dart';

/// Photo picker: a full-width rounded photo area. Shows [localImagePath] if
/// picked, else [existingImageUrl] (e.g. the selected pet's saved photo),
/// else an empty dashed "Add Photo" placeholder.
class CreatePostPhotoSection extends StatelessWidget {
  final String? localImagePath;
  final String? existingImageUrl;
  final ValueChanged<String?> onImagePicked;

  const CreatePostPhotoSection({
    super.key,
    required this.localImagePath,
    required this.existingImageUrl,
    required this.onImagePicked,
  });

  bool get _hasPhoto => localImagePath != null || existingImageUrl != null;

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (image != null) onImagePicked(image.path);
  }

  void _showPhotoOptions(BuildContext context) {
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
                title: const Text(AppStrings.takePhoto),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text(AppStrings.chooseFromGallery),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(context, ImageSource.gallery);
                },
              ),
              if (_hasPhoto) ...[
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
                    onImagePicked(null);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.addAClearPhoto,
          style: AppTextStyles.semiBoldStyle600(
              fontSize: 13, fontColor: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showPhotoOptions(context),
          child: _hasPhoto ? _buildPhoto() : _buildEmptyState(),
        ),
        const SizedBox(height: 12),
        const InfoBanner(text: AppStrings.thisHelpsPetParentsIdentifyPetQuickly),
      ],
    );
  }

  Widget _buildPhoto() {
    return Container(
      height: 220,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: smoothDecoration(cornerRadius: 20),
      child: localImagePath != null
          ? Image.file(File(localImagePath!), fit: BoxFit.cover)
          : Image.network(existingImageUrl!, fit: BoxFit.cover),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: smoothDecoration(
        cornerRadius: 20,
        color: AppColors.surface,
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppIcons.addPhotoIcon, width: 36, height: 36),
          const SizedBox(height: 8),
          Text(
            AppStrings.addPhoto,
            style: AppTextStyles.regularStyle400(
                fontSize: 14, fontColor: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
