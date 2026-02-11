import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/repositories/pet_repository.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

class PetOverviewEditButton extends StatelessWidget {
  final PetModel pet;

  const PetOverviewEditButton({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return CommonButton(
      text: AppStrings.editPetDetails,
      variant: ButtonVariant.primary,
      icon: Icons.edit_outlined,
      onPressed: () {
        context.pushNamed(AppRoutes.addPet, extra: pet);
      },
    );
  }
}

class PetOverviewActions {
  PetOverviewActions._();

  static void showDeleteConfirmation(BuildContext context, PetModel pet) {
    bool isDeleting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (builderContext, setDialogState) => AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  size: 32,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.deletePetConfirmTitle,
                style: AppTextStyles.semiBoldStyle600(
                  fontSize: 18,
                  fontColor: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.deletePetConfirmMessage,
                style: AppTextStyles.regularStyle400(
                  fontSize: 14,
                  fontColor: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      text: AppStrings.cancel,
                      variant: ButtonVariant.secondary,
                      size: ButtonSize.small,
                      onPressed: isDeleting
                          ? null
                          : () => Navigator.of(builderContext).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CommonButton(
                      text: AppStrings.delete,
                      variant: ButtonVariant.danger,
                      size: ButtonSize.small,
                      isLoading: isDeleting,
                      onPressed: isDeleting
                          ? null
                          : () async {
                              setDialogState(() => isDeleting = true);
                              await _deletePet(
                                context,
                                pet,
                                dialogContext,
                              );
                            },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _deletePet(
    BuildContext context,
    PetModel pet,
    BuildContext dialogContext,
  ) async {
    try {
      await sl<PetRepository>().deletePet(pet.id);
      if (context.mounted) {
        Navigator.of(dialogContext).pop();
        context.read<PetListBloc>().add(const LoadPetList());
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.petDeletedSuccessfully),
            backgroundColor: AppColors.success,
          ),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.pop();
          }
        });
      }
    } catch (e) {
      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class PetOverviewDeleteButton extends StatelessWidget {
  final PetModel pet;

  const PetOverviewDeleteButton({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return CommonButton(
      text: AppStrings.deletePet,
      variant: ButtonVariant.danger,
      icon: Icons.delete_outline,
      onPressed: () => PetOverviewActions.showDeleteConfirmation(context, pet),
    );
  }
}
