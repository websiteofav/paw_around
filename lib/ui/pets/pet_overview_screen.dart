import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/ui/pets/widgets/pet_overview_about_section.dart';
import 'package:paw_around/ui/pets/widgets/pet_overview_activity_section.dart';
import 'package:paw_around/ui/pets/widgets/pet_overview_actions.dart';
import 'package:paw_around/ui/pets/widgets/pet_overview_care_section.dart';
import 'package:paw_around/ui/pets/widgets/pet_overview_lost_toggle.dart';
import 'package:paw_around/ui/pets/widgets/pet_overview_personality_section.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

class PetOverviewScreen extends StatelessWidget {
  final PetModel pet;
  const PetOverviewScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PetListBloc, PetListState>(
      buildWhen: (_, current) => current is PetListLoaded,
      builder: (context, state) {
        final currentPet = state is PetListLoaded
            ? state.pets.firstWhere((p) => p.id == pet.id, orElse: () => pet)
            : pet;
        return _PetOverviewContent(pet: currentPet);
      },
    );
  }
}

class _PetOverviewContent extends StatelessWidget {
  final PetModel pet;
  const _PetOverviewContent({required this.pet});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroSection(pet: pet),
                const SizedBox(height: 24),
                _IdentityRow(pet: pet),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: PetOverviewLostToggle(pet: pet),
                ),
                const SizedBox(height: 24),
                PetOverviewAboutSection(pet: pet),
                const SizedBox(height: 24),
                PetOverviewPersonalitySection(pet: pet),
                const SizedBox(height: 24),
                PetOverviewCareSection(pet: pet),
                const SizedBox(height: 32),
                PetOverviewActivitySection(pet: pet),
                const SizedBox(height: 48),
              ],
            ),
          ),
          Positioned(
            top: topPad + 2,
            left: 14,
            right: 14,
            child: _PetOverviewTopControls(pet: pet),
          ),
        ],
      ),
    );
  }
}

class _PetOverviewTopControls extends StatelessWidget {
  final PetModel pet;

  const _PetOverviewTopControls({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HeroIconButton(
          icon: Icons.arrow_back_ios_new,
          onTap: () => context.pop(),
        ),
        const Spacer(),
        _HeroActionsMenu(pet: pet),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  final PetModel pet;
  const _HeroSection({required this.pet});

  @override
  Widget build(BuildContext context) {
    final hasImage = pet.imagePath != null && pet.imagePath!.startsWith('http');
    return Stack(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: hasImage
              ? Image.network(pet.imagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _PhotoPlaceholder())
              : const _PhotoPlaceholder(),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: const Alignment(0, -0.3),
                colors: [
                  AppColors.shadowOverlay.withValues(alpha: 0.45),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        if (pet.isLost)
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: smoothDecoration(
                cornerRadius: 999,
                color: AppColors.error,
              ),
              child: Text(
                AppStrings.missing,
                style: AppTextStyles.interBoldStyle700(
                    fontSize: 12, fontColor: AppColors.white),
              ),
            ),
          ),
      ],
    );
  }
}

class _HeroIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeroIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.shadowOverlay.withValues(alpha: 0.18),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColors.white,
          size: 22,
        ),
      ),
    );
  }
}

class _HeroActionsMenu extends StatelessWidget {
  final PetModel pet;

  const _HeroActionsMenu({required this.pet});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: AppColors.white,
      elevation: 8,
      offset: const Offset(-8, 38),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 132),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      icon: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.shadowOverlay.withValues(alpha: 0.18),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.menu,
          color: AppColors.white,
          size: 24,
        ),
      ),
      onSelected: (value) {
        if (value == 'report_lost') {
          PetOverviewActions.showMarkLostSheet(context, pet);
          return;
        }
        if (value == 'delete') {
          PetOverviewActions.showDeleteConfirmation(context, pet);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'report_lost',
          height: 46,
          child: Text(
            'Report lost',
            style: AppTextStyles.interRegularStyle400(
              fontSize: 12,
              fontColor: AppColors.grey1100,
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          height: 46,
          child: Text(
            'Delete Profile',
            style: AppTextStyles.interRegularStyle400(
              fontSize: 12,
              fontColor: AppColors.grey1100,
            ),
          ),
        ),
      ],
    );
  }
}

class _IdentityRow extends StatelessWidget {
  final PetModel pet;
  const _IdentityRow({required this.pet});

  static String _age(DateTime dob) {
    final months = (DateTime.now().year - dob.year) * 12 +
        (DateTime.now().month - dob.month);
    if (months < 12) return '${months}m';
    final y = months ~/ 12;
    final m = months % 12;
    return m > 0 ? '${y}y ${m}m' : '${y}y';
  }

  @override
  Widget build(BuildContext context) {
    final ageStr = _age(pet.dateOfBirth);
    final subtitle = pet.breed.isNotEmpty ? '${pet.breed} · $ageStr' : ageStr;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.051),
            blurRadius: 43.78,
            offset: const Offset(0, 5.47),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pet.name,
                    style: AppTextStyles.boldStyle700(
                        fontSize: 24, fontColor: AppColors.grey1100)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: AppTextStyles.interRegularStyle400(
                        fontSize: 16, fontColor: AppColors.grey700)),
              ],
            ),
          ),
          ScaleButton(
            onPressed: () => context.pushNamed(AppRoutes.petQr, extra: pet),
            child: Container(
              width: 52,
              height: 52,
              decoration: smoothDecoration(
                  cornerRadius: 12,
                  color: AppColors.background3,
                  shadows: [
                    BoxShadow(
                        color: AppColors.shadowOverlay.withValues(alpha: 0.149),
                        blurRadius: 4,
                        offset: const Offset(1, 1)),
                    BoxShadow(
                        color: AppColors.shadowOverlay.withValues(alpha: 0.129),
                        blurRadius: 8,
                        offset: const Offset(6, 6)),
                    BoxShadow(
                        color: AppColors.shadowOverlay.withValues(alpha: 0.078),
                        blurRadius: 11,
                        offset: const Offset(13, 13)),
                    BoxShadow(
                        color: AppColors.shadowOverlay.withValues(alpha: 0.020),
                        blurRadius: 13,
                        offset: const Offset(23, 23)),
                  ]),
              child: const Icon(Icons.qr_code_2,
                  size: 36, color: AppColors.secondaryCTA),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.iconBgLight,
        child: Center(
          child: Icon(Icons.pets,
              size: 64, color: AppColors.primary.withValues(alpha: 0.3)),
        ),
      );
}
