import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

class ProfilePetsSection extends StatelessWidget {
  final List<PetModel> pets;

  const ProfilePetsSection({super.key, required this.pets});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.myBabies,
              style: AppTextStyles.boldStyle700(
                  fontSize: 18, fontColor: AppColors.grey1000)),
          const SizedBox(height: 12),
          pets.isEmpty
              ? _EmptyState(onAddTap: () => context.pushNamed(AppRoutes.addPet))
              : _PetsList(
                  pets: pets,
                  onAddTap: () => context.pushNamed(AppRoutes.addPet),
                ),
        ],
      ),
    );
  }
}

// ─── Has-pets state ──────────────────────────────────────────────

class _PetsList extends StatelessWidget {
  final List<PetModel> pets;
  final VoidCallback onAddTap;
  const _PetsList({required this.pets, required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: smoothDecoration(
            cornerRadius: 36,
            color: AppColors.white,
            shadows: [
              BoxShadow(
                  color: AppColors.shadowOverlay.withValues(alpha: 0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < pets.length; i++) ...[
                if (i > 0)
                  const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: AppColors.border),
                _PetRow(pet: pets[i]),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _AddAnotherPetButton(onTap: onAddTap),
      ],
    );
  }
}

class _PetRow extends StatelessWidget {
  final PetModel pet;
  const _PetRow({required this.pet});

  String _age(DateTime dob) {
    final months = (DateTime.now().year - dob.year) * 12 +
        (DateTime.now().month - dob.month);
    if (months < 12) return '${months}m';
    final y = months ~/ 12;
    final m = months % 12;
    return m > 0 ? '${y}y ${m}m' : '${y}y';
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = pet.imagePath != null && pet.imagePath!.startsWith('http');
    return ScaleButton(
      onPressed: () => context.pushNamed(AppRoutes.petOverview, extra: pet),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Pet photo
            ClipSmoothRect(
              radius: AppSmoothRadius.custom(24),
              child: hasImage
                  ? Image.network(pet.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.pets,
                          color: AppColors.primary, size: 86))
                  : const Icon(Icons.pets, color: AppColors.primary, size: 86),
            ),
            const SizedBox(width: 12),
            // Name + breed/age
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pet.name,
                      style: AppTextStyles.interBoldStyle700(
                          fontSize: 16, fontColor: AppColors.grey1000)),
                  const SizedBox(height: 4),
                  Text(
                    pet.breed.isNotEmpty
                        ? '${pet.breed} · ${_age(pet.dateOfBirth)}'
                        : _age(pet.dateOfBirth),
                    style: AppTextStyles.interRegularStyle400(
                        fontSize: 12, fontColor: AppColors.grey600),
                  ),
                ],
              ),
            ),
            // Arrow button
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.grey1000,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_ios,
                  size: 14, color: AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddAnotherPetButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddAnotherPetButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onPressed: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.textSecondary.withValues(alpha: 0.35),
          borderRadius: 20,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add,
                  size: 18,
                  color: AppColors.textSecondary.withValues(alpha: 0.7)),
              const SizedBox(width: 8),
              Text(AppStrings.addAnotherPet,
                  style: AppTextStyles.mediumStyle500(
                      fontSize: 15,
                      fontColor:
                          AppColors.textSecondary.withValues(alpha: 0.7))),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;

  const _DashedBorderPainter({required this.color, this.borderRadius = 20});

  static const double _stroke = 1.5;
  static const double _dash = 7;
  static const double _gap = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = _stroke
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(_stroke / 2, _stroke / 2,
            size.width - _stroke, size.height - _stroke),
        Radius.circular(borderRadius),
      ));

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? _dash : _gap;
        if (draw) {
          canvas.drawPath(metric.extractPath(distance, distance + len), paint);
        }
        distance += len;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.borderRadius != borderRadius;
}

// ─── No-pets state ────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddTap;
  const _EmptyState({required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: smoothDecoration(
        cornerRadius: 20,
        color: AppColors.white,
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.5065, 1.0],
              colors: [Colors.white, Colors.transparent],
            ).createShader(rect),
            blendMode: BlendMode.dstIn,
            child: Image.asset(
              AppIcons.homeCatDogAffectionIcon,
              height: 236,
              width: 298,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.letsMeetYourPet,
            textAlign: TextAlign.center,
            style: AppTextStyles.boldStyle700(
                fontSize: 24, fontColor: AppColors.grey1000),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.trackHealthGroomingCare,
            textAlign: TextAlign.center,
            style: AppTextStyles.interMediumStyle500(
                fontSize: 16, fontColor: AppColors.grey700),
          ),
          const SizedBox(height: 24),
          ScaleButton(
            onPressed: onAddTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration:
                  smoothDecoration(cornerRadius: 999, color: AppColors.primary),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_circle_outline,
                      size: 18, color: AppColors.grey1000),
                  const SizedBox(width: 8),
                  Text(AppStrings.addPet,
                      style: AppTextStyles.interBoldStyle700(
                          fontSize: 16, fontColor: AppColors.grey1000)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
