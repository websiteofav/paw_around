import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/repositories/pet_repository.dart';
import 'package:paw_around/ui/pets/widgets/mark_lost_bottom_sheet.dart';

class PetOverviewLostToggle extends StatelessWidget {
  final PetModel pet;

  const PetOverviewLostToggle({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: smoothDecoration(
        cornerRadius: 24,
        color: AppColors.white,
        side: const BorderSide(color: AppColors.border),
        shadows: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _LostToggleRow(pet: pet),
    );
  }
}

class _LostToggleRow extends StatefulWidget {
  final PetModel pet;

  const _LostToggleRow({required this.pet});

  @override
  State<_LostToggleRow> createState() => _LostToggleRowState();
}

class _LostToggleRowState extends State<_LostToggleRow> {
  bool _isUpdating = false;

  Future<void> _onToggle(bool newValue) async {
    if (_isUpdating) return;
    if (newValue) {
      await MarkLostBottomSheet.show(
        context: context,
        pet: widget.pet,
        onSave: (lastSeenAt, lastSeenLocation) => _updatePetAsLost(
          lastSeenAt: lastSeenAt,
          lastSeenLocation: lastSeenLocation,
        ),
      );
      return;
    }
    await _updatePetAsFound();
  }

  Future<void> _updatePetAsLost({
    required DateTime lastSeenAt,
    required String lastSeenLocation,
  }) async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);
    try {
      await sl<PetRepository>().updatePet(
        widget.pet.copyWith(
          isLost: true,
          lastSeenAt: lastSeenAt,
          lastSeenLocation: lastSeenLocation.isEmpty ? null : lastSeenLocation,
          updatedAt: DateTime.now(),
        ),
      );
      if (mounted) {
        context.read<PetListBloc>().add(const LoadPetList());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.petMarkedAsLost),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _updatePetAsFound() async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);
    try {
      await sl<PetRepository>().updatePet(
        widget.pet.copyWith(
          isLost: false,
          lastSeenAt: null,
          lastSeenLocation: null,
          updatedAt: DateTime.now(),
        ),
      );
      if (mounted) {
        context.read<PetListBloc>().add(const LoadPetList());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.petNoLongerMarkedAsLost),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            AppStrings.markPetAsLost,
            style: AppTextStyles.mediumStyle500(
              fontSize: 14,
              fontColor: AppColors.textPrimary,
            ),
          ),
        ),
        Switch(
          value: widget.pet.isLost,
          onChanged: _isUpdating ? null : (value) => _onToggle(value),
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}
