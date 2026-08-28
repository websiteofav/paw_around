import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

class PetImagePickerSheet {
  static void show({
    required BuildContext context,
    required bool hasImage,
    required VoidCallback onCamera,
    required VoidCallback onGallery,
    VoidCallback? onRemove,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: smoothDecoration(
          borderRadius: AppSmoothRadius.topOnly(24),
          color: AppColors.white,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: smoothDecoration(
                    cornerRadius: 2,
                    color: AppColors.border,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                  title: Text(AppStrings.takePhoto,
                      style: AppTextStyles.regularStyle400(fontSize: 16, fontColor: AppColors.textPrimary)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onCamera();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                  title: Text(AppStrings.chooseFromGallery,
                      style: AppTextStyles.regularStyle400(fontSize: 16, fontColor: AppColors.textPrimary)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onGallery();
                  },
                ),
                if (hasImage && onRemove != null) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: AppColors.error),
                    title: Text(AppStrings.removePhoto,
                        style: AppTextStyles.regularStyle400(fontSize: 16, fontColor: AppColors.error)),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      onRemove();
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
