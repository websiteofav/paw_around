import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/info_banner.dart';

/// Dashed "Add a Photo" picker; once a photo is picked, shows the preview
/// with an "Edit photo" pill to swap or remove it.
class CreateMomentPhotoSection extends StatelessWidget {
  final String? imagePath;
  final ValueChanged<String?> onImagePicked;

  const CreateMomentPhotoSection({
    super.key,
    required this.imagePath,
    required this.onImagePicked,
  });

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
                leading: Image.asset(
                  AppIcons.addPhotoIcon,
                  width: 24,
                  height: 24,
                  color: AppColors.primary,
                  colorBlendMode: BlendMode.srcIn,
                ),
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
              if (imagePath != null) ...[
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
    final hasPhoto = imagePath != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showPhotoOptions(context),
          child: hasPhoto ? _buildPhoto() : _buildEmptyState(),
        ),
        if (hasPhoto) ...[
          const SizedBox(height: 24),
          _buildEditButton(context),
        ],
        const SizedBox(height: 12),
        const InfoBanner(text: AppStrings.momentPhotoBanner),
      ],
    );
  }

  Widget _buildPhoto() {
    return ClipSmoothRect(
      radius: AppSmoothRadius.custom(24),
      child: Image.file(
        File(imagePath!),
        height: 320,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildEmptyState() {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(24),
      color: AppColors.border,
      strokeWidth: 1.5,
      dashPattern: const [6, 5],
      padding: EdgeInsets.zero,
      child: Container(
        height: 420,
        width: double.infinity,
        decoration:
            smoothDecoration(cornerRadius: 24, color: AppColors.surface),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppIcons.addPhotoIcon, width: 48, height: 48),
            const SizedBox(height: 12),
            Text(
              AppStrings.addAPhotoOrVideo,
              style: AppTextStyles.interRegularStyle400(
                  fontSize: 14, fontColor: AppColors.grey1000),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPhotoOptions(context),
      child: Container(
        height: 36,
        padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
        decoration:
            smoothDecoration(cornerRadius: 999, color: AppColors.background3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            SvgPicture.asset(AppIcons.editIcon,
                colorFilter: const ColorFilter.mode(
                    AppColors.secondaryCTA, BlendMode.srcIn)),
            Text(AppStrings.editPhoto,
                style: AppTextStyles.mediumStyle500(
                    fontSize: 13, fontColor: AppColors.secondaryCTA)),
          ],
        ),
      ),
    );
  }
}
